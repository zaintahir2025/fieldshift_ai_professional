from pathlib import Path
import json
import os
import joblib
import numpy as np
from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field, ConfigDict
from model_config import FEATURES, MODEL_DIR

ROOT = Path(__file__).resolve().parent
MODELS = ROOT / MODEL_DIR
app = FastAPI(title="FIELDSHIFT AI ML API", version="1.0.0")
app.add_middleware(
    CORSMiddleware,
    allow_origins=[origin.strip() for origin in os.getenv("FIELDSHIFT_CORS_ORIGINS", "http://localhost:5173,http://127.0.0.1:5173").split(",") if origin.strip()],
    allow_credentials=False,
    allow_methods=["GET", "POST"],
    allow_headers=["*"],
)

class FarmFeatures(BaseModel):
    model_config = ConfigDict(extra="forbid")

    crop: str = Field(min_length=2, max_length=40)
    latitude: float = Field(ge=-90, le=90)
    longitude: float = Field(ge=-180, le=180)
    year: int = Field(ge=1981, le=2100)
    temp_mean_c: float = Field(ge=-20, le=60)
    temp_max_c: float = Field(ge=-20, le=70)
    rainfall_total_mm: float = Field(ge=0, le=10000)
    solar_mean_kwh_m2_day: float = Field(ge=0, le=50)
    soil_moisture_m3_m3: float = Field(ge=0, le=1)
    ndvi_mean: float = Field(ge=-1, le=1)
    ndvi_change: float = Field(ge=-2, le=2)


def load_bundle(name: str):
    path = MODELS / f"{name}.joblib"
    if not path.exists():
        raise HTTPException(
            status_code=503,
            detail=f"{name.replace('_', ' ').title()} model is not trained yet. Add verified labelled records and run backend/train_models.py.",
        )
    try:
        return joblib.load(path)
    except Exception as exc:
        raise HTTPException(status_code=500, detail=f"Could not load {name} model: {exc}")


def row_from_payload(payload: FarmFeatures):
    return [{key: getattr(payload, key) for key in FEATURES}]

@app.get("/")
def root():
    return {"service": "FIELDSHIFT AI ML API", "docs": "/docs", "health": "/health"}

@app.get("/health")
def health():
    return {"status": "ok", "service": "FIELDSHIFT AI ML API", "version": app.version}

@app.get("/models/status")
def model_status():
    result = {}
    for name in ("crop_stress", "crop_yield"):
        path = MODELS / f"{name}.joblib"
        meta_path = MODELS / f"{name}_metrics.json"
        metrics = None
        if meta_path.exists():
            try:
                metrics = json.loads(meta_path.read_text(encoding="utf-8"))
            except (OSError, json.JSONDecodeError):
                metrics = {"warning": "Metrics file exists but could not be read."}
        result[name] = {"trained": path.exists(), "metrics": metrics}
    return result

@app.post("/predict/stress")
def predict_stress(payload: FarmFeatures):
    bundle = load_bundle("crop_stress")
    X = row_from_payload(payload)
    import pandas as pd
    frame = pd.DataFrame(X)
    prediction = str(bundle["pipeline"].predict(frame)[0])
    probabilities = bundle["pipeline"].predict_proba(frame)[0]
    classes = bundle["pipeline"].named_steps["model"].classes_
    confidence = float(np.max(probabilities))
    return {
        "prediction": prediction,
        "confidence": round(confidence, 4),
        "probabilities": {str(label): round(float(prob), 4) for label, prob in zip(classes, probabilities)},
        "model": bundle.get("model_name", "RandomForestClassifier"),
        "training_rows": bundle.get("training_rows"),
        "warning": "Model output is only as reliable as the geographic, crop and season coverage of its labelled training data.",
    }

@app.post("/predict/yield")
def predict_yield(payload: FarmFeatures):
    bundle = load_bundle("crop_yield")
    import pandas as pd
    value = float(bundle["pipeline"].predict(pd.DataFrame(row_from_payload(payload)))[0])
    return {
        "yield_t_ha": round(max(0.0, value), 2),
        "model": bundle.get("model_name", "RandomForestRegressor"),
        "training_rows": bundle.get("training_rows"),
        "warning": "Indicative estimate, not a guaranteed harvest result. Validate against local field records.",
    }


@app.get("/nasa/observations")
def nasa_observations(latitude: float = Query(..., ge=-84.66, le=84.66),
                      longitude: float = Query(..., ge=-180, le=180),
                      days: int = Query(30, ge=7, le=90)):
    """Fetch NASA POWER daily agroclimate plus SMAP L4 soil moisture through POWER HY aliases."""
    import requests
    from datetime import datetime, timedelta
    end = datetime.utcnow().date() - timedelta(days=3)  # allow near-real-time processing latency
    start = end - timedelta(days=days - 1)
    datefmt = lambda d: d.strftime("%Y%m%d")
    base = "https://power.larc.nasa.gov/api/temporal/daily/point"
    common = {"latitude": latitude, "longitude": longitude,
              "start": datefmt(start), "end": datefmt(end), "format": "JSON"}
    try:
        weather_response = requests.get(base, params={**common, "community": "AG",
            "parameters": "T2M,T2M_MAX,PRECTOTCORR,ALLSKY_SFC_SW_DWN"}, timeout=35)
        weather_response.raise_for_status()
        weather_json = weather_response.json()
        hydro_response = requests.get(base, params={**common, "community": "HY",
            "parameters": "SFMC,RZMC"}, timeout=35)
        hydro_response.raise_for_status()
        hydro_json = hydro_response.json()
    except requests.RequestException as exc:
        raise HTTPException(status_code=502, detail=f"NASA POWER data request failed: {exc}")
    wp = weather_json.get("properties", {}).get("parameter", {})
    hp = hydro_json.get("properties", {}).get("parameter", {})
    def valid_series(series):
        return {k: float(v) for k, v in (series or {}).items()
                if isinstance(v, (int, float)) and v > -90}
    keys = sorted(set(valid_series(wp.get("T2M", {}))) |
                  set(valid_series(hp.get("SFMC", {}))))
    rows = []
    for day in keys:
        row = {"date": day}
        for name, series in [("temp_c", wp.get("T2M")), ("temp_max_c", wp.get("T2M_MAX")),
                             ("rain_mm_day", wp.get("PRECTOTCORR")),
                             ("solar_mj_m2_day", wp.get("ALLSKY_SFC_SW_DWN")),
                             ("smap_surface_soil_moisture_m3_m3", hp.get("SFMC")),
                             ("smap_rootzone_soil_moisture_m3_m3", hp.get("RZMC"))]:
            value = valid_series(series).get(day)
            row[name] = value
        rows.append(row)
    def mean_of(field):
        vals = [r[field] for r in rows if r.get(field) is not None]
        return round(sum(vals)/len(vals), 4) if vals else None
    return {
        "location": {"latitude": latitude, "longitude": longitude},
        "requested_period": {"start": datefmt(start), "end": datefmt(end), "days": days},
        "valid_observation_days": len(rows),
        "summary": {field: mean_of(field) for field in (
            "temp_c", "temp_max_c", "rain_mm_day", "solar_mj_m2_day",
            "smap_surface_soil_moisture_m3_m3", "smap_rootzone_soil_moisture_m3_m3")},
        "observations": rows,
        "sources": [
            {"dataset": "NASA POWER Agroclimatology Daily", "parameters": ["T2M","T2M_MAX","PRECTOTCORR","ALLSKY_SFC_SW_DWN"],
             "url": "https://power.larc.nasa.gov/docs/services/api/temporal/daily/"},
            {"dataset": "NASA SMAP L4 soil moisture served via NASA POWER HY", "parameters": ["SFMC","RZMC"],
             "url": "https://power.larc.nasa.gov/docs/methodology/data/sources_hydrology/"}],
        "caveats": [
            "SMAP L4 soil moisture is approximately 9 km and is not a field-scale soil test.",
            "POWER meteorology and SMAP soil-moisture values have different effective spatial resolutions.",
            "Missing values remain null; they are not imputed. Check product quality and local soil samples before farm decisions."
        ]
    }

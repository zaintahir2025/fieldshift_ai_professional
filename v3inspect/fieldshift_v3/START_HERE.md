# FIELDSHIFT AI — Start Here (Windows)

## What this project does

FIELDSHIFT AI is a climate-aware agriculture decision-support prototype. It combines NASA POWER weather observations, NASA GIBS satellite imagery overlays, crop-rotation heuristics, an experimental 7-day climate-stress indicator, and a transparent rule-based crop assessment. Optional ML training scripts are included for future research but are not used by the dashboard.

## 1) Run the dashboard

Install Node.js 18 or newer. Open PowerShell in this folder:

```powershell
npm install
npm run dev
```

Open the local Vite URL shown in the terminal (normally `http://localhost:5173`).

## 2) Run the Python API

Open a second PowerShell window in this folder:

```powershell
cd backend
py -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
uvicorn app:app --reload --host 127.0.0.1 --port 8000
```

API documentation: `http://127.0.0.1:8000/docs`
Health check: `http://127.0.0.1:8000/health`
Model status: `http://127.0.0.1:8000/models/status`

## 3) ML is intentionally not used in the dashboard

The ZIP does **not** include trained model weights or verified crop-stress/yield labels. To prevent unexpected or misleading results, the dashboard does not call ML prediction endpoints. It uses a transparent rule-based screening calculation instead. Optional ML endpoints remain separate and return HTTP 503 until genuine labelled datasets are supplied and the models are trained successfully.

Do not use invented measurements or synthetic labels as real field evidence. The dashboard requires manually entered numeric soil-moisture and NDVI measurements because numeric SMAP/HLS point extraction is not connected yet.

## 4) Collect climate season features

Edit `data/templates/locations_template.csv`, save a copy as `data/locations.csv`, and enter real locations, coordinates, crops, season months, and year range. Then, from `backend`:

```powershell
python collect_power_season_features.py
```

This creates `data/power_season_features.csv` from NASA POWER daily climate data. It is **not** a labelled ML training dataset by itself. Join quality-screened satellite measurements and matching field observations.

## 5) Train both ML models

Fill these templates with sourced, matching crop-location-season records:

- `data/templates/crop_stress_training_template.csv` → `data/crop_stress_training.csv`
- `data/templates/crop_yield_training_template.csv` → `data/crop_yield_training.csv`

Stress target: observed `Low`, `Moderate`, or `High` crop-stress label.

Yield target: actual harvested `yield_t_ha` value for that same crop, location, and growing season.

The starter training script requires at least 100 usable labelled rows per model. Three or more locations enable a location-group holdout; otherwise it uses a random holdout. For a competition-quality scientific evaluation, prefer multiple years and locations, avoid leakage between repeated farm/season samples, and report limitations.

Run from `backend`:

```powershell
python train_models.py
```

Successful training writes:

- `backend/models/crop_stress.joblib`
- `backend/models/crop_yield.joblib`
- `backend/models/crop_stress_metrics.json`
- `backend/models/crop_yield_metrics.json`

The dashboard does not automatically switch to ML after training; any future ML integration should be explicitly enabled only after reviewing held-out evaluation metrics and data coverage.

## 6) Outputs

- Dashboard: climate indicators, charts, map, satellite imagery overlays, dynamic rule-based crop rotation ranking, crop stress/suitability screening, experimental 7-day stress outlook.
- Crop assessment: rule-based stress category and suitability index. It is not an ML prediction or yield estimate.
- Optional ML API endpoints: disabled from the dashboard and unavailable until genuine models are trained.
- Evaluation: stress accuracy, balanced accuracy, per-class precision/recall/F1; yield MAE, RMSE, and R².

See `README.md` for architecture, data-source links, and scientific limitations.

## 7) API configuration and tests

The frontend defaults to `http://127.0.0.1:8000`. To change it, copy `.env.example` to `.env` and set `VITE_API_BASE_URL` before starting/rebuilding Vite. The API's allowed frontend origins can be set with `FIELDSHIFT_CORS_ORIGINS` as a comma-separated list.

Run backend checks from `backend` after installing `requirements.txt`:

```powershell
pytest -q
```

These tests check the API health route, model-status shape, and input validation. They do not prove NASA service availability, satellite retrieval, model accuracy, or agronomic validity.

## 8) Important limitations and competition materials

- GIBS imagery dates are generated dynamically using conservative offsets from the current UTC date. NASA product availability can lag; if a layer is blank, check that product's current availability in the NASA GIBS documentation.
- NASA POWER HY provides an approximate SMAP L4 root-zone moisture estimate through the backend endpoint; fetch it in the NASA data panel to let the rule-based assessment use it. It is roughly 9 km scale, not a field soil test. Numeric MODIS NDVI point extraction is not implemented; NDVI remains optional manual input. Never enter guessed values.
- The crop-stress and crop-yield models are not trained in the supplied package. Training requires genuine, matched, labelled field records.
- The dashboard's climate index, short-term outlook, and dynamic crop-rotation scores are demonstration logic, not calibrated recommendations. Rotation scores use selected crop, soil, farmer priority and available recent weather/moisture inputs, but need local agronomic validation.

See `SUBMISSION_GUIDE.md`, `DEMO_SCRIPT.md`, and `AI_USAGE_DISCLOSURE.md` before preparing the competition submission. Verify every disclosure against the team's actual tool use.

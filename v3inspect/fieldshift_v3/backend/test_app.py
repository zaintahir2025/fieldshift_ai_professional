from fastapi.testclient import TestClient
from app import app, FarmFeatures

client = TestClient(app)


def sample_payload():
    return {
        "crop": "Wheat", "latitude": 31.45, "longitude": 73.13, "year": 2026,
        "temp_mean_c": 24.0, "temp_max_c": 31.0, "rainfall_total_mm": 80.0,
        "solar_mean_kwh_m2_day": 18.0, "soil_moisture_m3_m3": 0.24,
        "ndvi_mean": 0.62, "ndvi_change": -0.08,
    }


def test_root_and_health():
    assert client.get("/").status_code == 200
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_model_status_reports_both_models():
    data = client.get("/models/status").json()
    assert set(data) == {"crop_stress", "crop_yield"}
    assert all("trained" in item for item in data.values())


def test_feature_contract_accepts_valid_values():
    parsed = FarmFeatures(**sample_payload())
    assert parsed.crop == "Wheat"


def test_feature_contract_rejects_out_of_range_coordinates():
    payload = sample_payload()
    payload["latitude"] = 120
    response = client.post("/predict/stress", json=payload)
    assert response.status_code == 422


def test_feature_contract_rejects_unknown_fields():
    payload = sample_payload()
    payload["made_up_feature"] = 5
    response = client.post("/predict/yield", json=payload)
    assert response.status_code == 422

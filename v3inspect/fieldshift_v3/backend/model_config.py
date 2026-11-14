"""Shared feature contract for FIELDSHIFT AI models."""
NUMERIC_FEATURES = [
    "latitude", "longitude", "year", "temp_mean_c", "temp_max_c",
    "rainfall_total_mm", "solar_mean_kwh_m2_day", "soil_moisture_m3_m3",
    "ndvi_mean", "ndvi_change",
]
CATEGORICAL_FEATURES = ["crop"]
FEATURES = CATEGORICAL_FEATURES + NUMERIC_FEATURES
STRESS_TARGET = "stress_label"
YIELD_TARGET = "yield_t_ha"
MODEL_DIR = "models"

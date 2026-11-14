# FIELDSHIFT AI — Project outputs and technology stack

## Technology stack

### Frontend
- React 18
- Vite 6
- JavaScript (JSX)
- Leaflet + React-Leaflet for interactive maps
- Recharts for climate charts
- Lucide React for interface icons
- CSS for responsive dashboard styling

### Backend and machine learning
- Python
- FastAPI + Uvicorn for REST inference API
- pandas + NumPy for data preparation
- scikit-learn RandomForestClassifier for crop-stress classes
- scikit-learn RandomForestRegressor for yield estimation
- joblib for model serialization
- requests for NASA POWER historical data retrieval

### Earth observation / data
- NASA POWER Daily Point API: T2M, T2M_MAX, PRECTOTCORR, ALLSKY_SFC_SW_DWN
- NASA GIBS WMTS imagery: MODIS true color, SMAP/Sentinel-1 soil-moisture visualization, MODIS NDVI, MODIS land-surface temperature
- Dataset access references: NASA SMAP SPL3SMP_E, Landsat Collection 2 Level-2, NASA HLS, GPM IMERG

## System flow

1. User chooses a saved location or enters coordinates.
2. React requests daily NASA POWER data for that point.
3. Dashboard calculates and plots weather summaries.
4. Leaflet shows location and available satellite imagery overlays.
5. Crop rotation module ranks illustrative options using transparent rules.
6. Experimental outlook calculates a trend-based risk indicator from recent POWER observations.
7. When real training data have been supplied and models trained, React sends aligned farm/season features to FastAPI.
8. FastAPI loads the trained Random Forest pipelines and returns stress probabilities and yield estimate.

## ML input features

`crop`, `latitude`, `longitude`, `year`, `temp_mean_c`, `temp_max_c`, `rainfall_total_mm`, `solar_mean_kwh_m2_day`, `soil_moisture_m3_m3`, `ndvi_mean`, `ndvi_change`.

## ML outputs

### Crop stress classifier
- Class: Low / Moderate / High
- Probability for each class
- Maximum class probability as confidence indicator
- Model name and number of training rows

### Crop yield regressor
- Estimated yield in tonnes/hectare (t/ha)
- Model name and number of training rows

### Evaluation artifacts
- Stress: accuracy, balanced accuracy, per-class precision, recall and F1.
- Yield: mean absolute error (MAE), root mean squared error (RMSE), and R².
- Metrics JSON files are written alongside trained model artifacts.

## Honest implementation status

| Component | Status |
|---|---|
| React dashboard | Implemented in source |
| NASA POWER numeric daily weather | Connected in source; requires internet at runtime |
| NASA GIBS map imagery overlays | Configured visual layers; not point-extracted measurements |
| SMAP / Landsat / HLS catalogue links | Added; numerical extraction not connected |
| Crop rotation ranking | Demonstration heuristic, not validated agronomy |
| 7-day stress outlook | Experimental heuristic, not weather forecast or trained ML |
| Crop-stress ML pipeline | Training code + API integration; awaits verified labelled data and weights |
| Crop-yield ML pipeline | Training code + API integration; awaits observed harvest labels and weights |
| Model metrics | Generated only after real data training; no fabricated metrics included |

## Important scientific notes

- The satellite map tiles are image visualizations, not numeric farm-point observations.
- SMAP soil moisture and NDVI values must be extracted from appropriate products, QA-screened, scaled, and aligned to the crop season before model training or inference.
- A crop-stress label should come from field scouting or a clearly identified proxy-labeling protocol.
- A yield target must be actual harvested yield for the same crop/location/season. Broad national statistics are not farm-level yield labels.
- The current feature contract uses growing-season aggregates. Prediction inputs should use the same temporal window and definitions as training features. The live dashboard's selected-date-range weather summaries are only suitable when aligned with the training period and feature semantics; this is not automated seasonal alignment yet.
- Do not claim a model accuracy, forecast skill, yield improvement, NASA endorsement, or competition win without supporting evidence.

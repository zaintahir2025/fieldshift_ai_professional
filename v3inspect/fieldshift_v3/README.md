# FIELDSHIFT AI

> **Quick start:** see [START_HERE.md](START_HERE.md). For architecture, stack, expected outputs, and implementation status, see [PROJECT_OUTPUTS.md](PROJECT_OUTPUTS.md).

A 24-hour NASA Space Apps Challenge prototype for climate-aware farm exploration and crop-rotation decision support.

## Features
- NASA POWER Daily API integration for T2M, corrected precipitation, and surface solar radiation.
- Coordinate-based farm selection plus example regions in Pakistan and other countries.
- Interactive OpenStreetMap context map with NASA GIBS MODIS true-colour, SMAP soil-moisture, MODIS NDVI and MODIS land-surface-temperature imagery overlays.
- Climate time-series charts.
- Transparent, illustrative risk indicators and crop-rotation ranking.
- Responsive dashboard for desktop and mobile.

## Requirements
- Node.js 18+
- npm
- Internet connection (NASA POWER API, OpenStreetMap tiles, and Google Fonts are fetched online)

## Run locally
```bash
npm install
npm run dev
```
Open the local URL printed by Vite (usually http://localhost:5173).

## Production build
```bash
npm run build
npm run preview
```

## Data and scientific limitations
- The working numeric point-data connection is NASA POWER Daily Point API. The app requests T2M, PRECTOTCORR, and ALLSKY_SFC_SW_DWN for the selected latitude/longitude.
- The map has an OpenStreetMap base layer and selectable NASA GIBS layers: MODIS Terra true-colour, SMAP/Sentinel-1 soil-moisture visualization, MODIS Terra NDVI (8-day), and MODIS daytime land-surface temperature.
- NASA GIBS layers are image tiles for visual context. They are NOT point-extracted values at the selected farm coordinate and must not be used as measured farm soil moisture, NDVI, or temperature readings.
- GPM IMERG is linked to the official NASA product directory. Automated GPM point-value extraction is NOT implemented in this build. NASA lists IMERG V07B as approximately 0.1° / 10 km with 30-minute and daily products; data access is through NASA data services and may require Earthdata registration/authentication.
- Numeric SMAP point extraction is NOT implemented in this build. NASA AppEEARS supports point sampling of SMAP SPL3SMP_E and returns values with quality information; an authenticated AppEEARS workflow must be configured before displaying those values.
- Landsat, SRTM and ECOSTRESS numeric extraction are not implemented.
- The climate suitability score and rotation ranks are transparent demonstration heuristics. They are not validated agronomic models, forecasts, measured soil moisture, yield predictions, or professional agricultural advice.
- Crop recommendations need local crop calendars, verified soil tests, water availability, cultivar details, and agronomist validation. The example crop list is tailored as a demo for Pakistan's broad wheat-based rotations and must be localized before field use.

## NASA POWER API
`https://power.larc.nasa.gov/api/temporal/daily/point`

Parameters used:
- `T2M`: 2 m air temperature
- `PRECTOTCORR`: corrected precipitation
- `ALLSKY_SFC_SW_DWN`: all-sky surface shortwave downward irradiance

NASA POWER documentation: https://power.larc.nasa.gov/docs/

## Next integrations
1. Authenticated NASA AppEEARS point-sample workflow for SMAP SPL3SMP_E numeric soil moisture, including QA filtering.
2. Authenticated GPM IMERG V07B point extraction via NASA GES DISC / Earthdata Cloud services.
3. Numeric MODIS/Landsat vegetation-index extraction and quality masking.
4. SoilGrids or verified local soil survey inputs.
5. Real crop calendars and region-specific agronomic rules.
6. Explainable rotation comparison with confidence and data provenance.

## Additional NASA map overlays
The map uses NASA GIBS public WMTS tile services for:
- `SMAP_Sentinel-1_L2_Active_Passive_Soil_Moisture`
- `MODIS_Terra_NDVI_8Day`
- `MODIS_Terra_Land_Surface_Temp_Day`
- `MODIS_Terra_CorrectedReflectance_TrueColor`

The overlays are visual products. They should not be described as point-level measured values or as a complete field-scale diagnosis. NASA GIBS service documentation: https://nasa-gibs.github.io/gibs-api-docs/access-basics/

GPM IMERG official product documentation: https://gpm.nasa.gov/data/imerg

## NASA references
- NASA POWER: https://power.larc.nasa.gov/docs/
- NASA GIBS access basics: https://nasa-gibs.github.io/gibs-api-docs/access-basics/
- NASA GPM IMERG data directory: https://gpm.nasa.gov/data/directory
- NASA AppEEARS: https://appeears.earthdatacloud.nasa.gov/
- NASA AppEEARS Data Resources: https://github.com/nasa/AppEEARS-Data-Resources
- NSIDC AppEEARS point-sample guide for SMAP: https://nsidc.org/data/user-resources/help-center/how-extract-point-and-area-data-samples-using-appeears


## SMAP and Landsat dataset resources (added)
The dashboard now includes an official resource catalogue for:
- **NASA SMAP L3 Enhanced (SPL3SMP_E):** daily soil-moisture product, approximately 9 km enhanced grid. Dataset details: https://nsidc.org/data/spl3smp_e. AppEEARS point sampling: https://appeears.earthdatacloud.nasa.gov/
- **Landsat 8-9 Collection 2 Level-2:** 30 m surface reflectance and surface temperature. Product guide: https://www.usgs.gov/landsat-missions/landsat-collection-2-level-2-science-products. Data search: https://earthexplorer.usgs.gov/
- **NASA Harmonized Landsat Sentinel-2 (HLS) v2.0:** L30/S30 harmonized surface reflectance at 30 m; HLS-VI includes vegetation indices. Product guide: https://hls.gsfc.nasa.gov/data-products/ and access methods: https://hls.gsfc.nasa.gov/data-access-and-tools/

**Integration status:** these are dataset resources and access links, not active numeric data feeds in this build. SMAP/Landsat/HLS values are not currently extracted at the selected farm coordinates or used by the crop-rotation scoring logic. NASA Earthdata authentication may be required for data download and AppEEARS workflows. Landsat/HLS processing must apply quality/cloud masks and product scaling; SMAP should be interpreted at its native grid scale rather than as a precise single-field measurement.


## Experimental 7-day crop-stress outlook
The dashboard now computes an indicative 7-day risk signal from up to 14 recent daily NASA POWER observations:
- Temperature: linear trend extrapolation over the next 7 days.
- Rainfall: recent daily mean carried forward as a persistence baseline (not a weather forecast).
- Heat and dry-spell risk: transparent heuristic indices combined into a 0–100 demonstration score.
- The UI displays input count, trend direction and low-confidence status.

This is **not** a validated predictive model, numerical weather prediction, yield forecast, irrigation prescription, or crop disease forecast. Crop heat thresholds and risk weights are illustrative assumptions. The score does not yet use numeric SMAP soil-moisture or Landsat/HLS vegetation measurements; those remain resource links/visual context until authenticated extraction and QA processing are implemented. Validate decisions with local agronomists and trusted forecast services.

## Optional machine-learning pipeline (not used by the dashboard)

The project now includes a Python/FastAPI inference service and two Random Forest training pipelines:

- **Crop stress classifier:** predicts `Low`, `Moderate`, or `High` from crop, location, season-level climate, soil-moisture and NDVI features.
- **Crop yield regressor:** estimates harvested yield in tonnes/hectare from the same feature contract.
- **Evaluation:** stress accuracy, balanced accuracy and per-class precision/recall/F1; yield MAE, RMSE and R². When at least three unique `location_id` values are provided, the trainer holds out entire locations for testing.
- **Dashboard:** uses a deterministic rule-based crop assessment. It does not call the optional ML inference endpoints.

### Important training status

**This ZIP contains the complete training code and dashboard/API integration, but does not contain trained model weights.** The current project has NASA POWER weather observations but no verified crop-stress labels or harvest-yield records. Training on fabricated labels would create misleading predictions, so the trainer intentionally stops until real labelled CSV data are supplied. The dashboard reports models as "Not trained yet" until the two `.joblib` files are actually created.

### Setup on Windows

Open two terminals in the `fieldshift-ai` project folder.

Terminal 1 — Python backend:

```powershell
cd backend
py -m venv .venv
.venv\\Scripts\\activate
pip install -r requirements.txt
uvicorn app:app --reload --host 127.0.0.1 --port 8000
```

Terminal 2 — React frontend:

```powershell
npm install
npm run dev
```

### Prepare historical NASA POWER season features

Copy `data/templates/locations_template.csv` to `data/locations.csv`, then add the farm/district locations, crop, coordinates, growing-season start/end months and year range. Run this from the `backend` directory after installing requirements:

```powershell
python collect_power_season_features.py
```

It downloads historical NASA POWER daily weather and aggregates temperature, maximum temperature, rainfall total and solar radiation by crop season into `data/power_season_features.csv`. Join these season records with quality-screened numeric SMAP soil moisture, Landsat/HLS NDVI, and matching observed stress/yield labels. Do not use the visual GIBS tile itself as a numeric feature.

### Train both models after adding sourced labels

Copy the two templates from `data/templates/` into `data/` and rename them exactly:

- `crop_stress_training_template.csv` → `data/crop_stress_training.csv`
- `crop_yield_training_template.csv` → `data/crop_yield_training.csv`

Fill the stress target with observed/curated `Low`, `Moderate`, or `High` labels and the yield target with actual harvested `yield_t_ha` values. Both files require the feature columns shown in the templates. Use matching crop, location, year and growing-season windows. At least 100 usable labelled rows per model are required by this initial pipeline; include three or more distinct `location_id` values to get a spatial holdout evaluation.

Then run from the `backend` directory:

```powershell
python train_models.py
```

The script writes `backend/models/crop_stress.joblib`, `crop_yield.joblib`, and separate metrics JSON files. Keep the metrics with the project and do not report performance without the held-out test results.

### API endpoints

- `GET /health`
- `GET /models/status`
- `POST /predict/stress`
- `POST /predict/yield`

### Feature contract and caveats

The model expects crop, latitude/longitude, year, mean/max temperature, growing-season rainfall total, mean solar radiation, volumetric soil moisture (m³/m³), mean NDVI and NDVI change. NASA POWER can supply climate features. SMAP point extraction and Landsat/HLS numeric NDVI extraction are still separate data-ingestion tasks; the map's NASA GIBS imagery tiles are not numeric measurements. The dashboard asks the user to enter measured satellite values and does not silently substitute invented values.

For yield training, the harvested yield label must correspond to the same crop/location/season as the input features. For stress training, labels should be based on field scouting or documented crop-stress observations. If labels are derived from NDVI anomalies, identify them as proxy labels. A national FAO yield value should not be treated as a farm-level yield label. Keep source, spatial scale, crop stage and observation dates in a provenance file. A high test score does not establish agronomic validity if the dataset is geographically narrow or labels are proxies.

Useful official data references:
- NASA POWER Daily API documentation: https://power.larc.nasa.gov/docs/services/api/temporal/daily/
- FAOSTAT API documentation and crop production statistics: https://www.fao.org/faostat/en/docs/redoc-static.html
- NSIDC AppEEARS point-sampling guide for SMAP: https://nsidc.org/data/user-resources/help-center/how-extract-point-and-area-data-samples-using-appeears
- NASA HLS products: https://hls.gsfc.nasa.gov/data-products/

## Competition preparation and disclosures

See the following project documents before submission:

- `SUBMISSION_GUIDE.md` — evidence checklist organized around Impact, Creativity, Validity, Relevance, and Presentation.
- `DEMO_SCRIPT.md` — a short English demonstration script that accurately describes implemented features and limitations.
- `AI_USAGE_DISCLOSURE.md` — a disclosure draft that the team must verify and complete against actual use.

The frontend API base URL is configurable through `.env` (`VITE_API_BASE_URL`); the backend CORS allow-list is configurable through `FIELDSHIFT_CORS_ORIGINS`. Backend smoke/validation tests are in `backend/test_app.py` and can be run with `pytest -q`.


## NASA Earth-observation data integration (challenge-aligned update)

The challenge asks for a crop-rotation decision-support tool combining NASA Earth observations with local soil information, crop characteristics, and farmer priorities. This build now adds a live backend endpoint and dashboard panel for NASA POWER agroclimate observations plus SMAP L4 soil moisture.

### Live numeric feeds implemented
- **NASA POWER Daily / Agroclimatology (AG):** `T2M`, `T2M_MAX`, `PRECTOTCORR`, `ALLSKY_SFC_SW_DWN`.
- **NASA SMAP L4 via NASA POWER Hydrology (HY):** `SFMC` (surface soil moisture) and `RZMC` (root-zone soil moisture), when available for the requested dates/location.
- Backend endpoint: `GET /nasa/observations?latitude=31.45&longitude=73.13&days=30`.
- The dashboard button “Fetch NASA POWER + SMAP data” retrieves and displays these summaries for the selected coordinates.

### Additional NASA datasets represented in the dashboard/resources
- **MODIS MOD13Q1 NDVI:** 250 m, 16-day vegetation-index product. The project has a NASA GIBS NDVI visual layer and links the official product, but does not yet extract numeric pixel values at the farm point.
- **GPM IMERG:** NASA precipitation product. Official product link is provided; automated point extraction is not yet implemented.
- **ECOSTRESS:** recommended future integration for evapotranspiration / land-surface temperature, not a live feed in this build.

### Scientific caveats
- SMAP L4 soil moisture is approximately 9 km and should not be represented as a field-scale soil test.
- NASA POWER weather and SMAP values have different effective spatial resolutions; do not imply all variables share one grid.
- MODIS NDVI and GPM IMERG are resources/visual context only until numeric extraction and QA are implemented.
- Crop rotation ranking now responds to the selected current crop, soil texture, farmer priority, recent NASA POWER 30-day rainfall/maximum temperature, and NASA POWER HY root-zone moisture when that observation has been fetched. The score rubric is explicit and deterministic, but remains a demonstration heuristic rather than a validated agronomic optimizer.
- The new NASA endpoint does not silently fill the ML model's NDVI input. ML inference remains disabled until training labels and matching seasonal features are sourced and validated.

NASA documentation:
- POWER Daily API: https://power.larc.nasa.gov/docs/services/api/temporal/daily/
- POWER hydrology and SMAP source notes: https://power.larc.nasa.gov/docs/methodology/data/sources_hydrology/
- MODIS MOD13Q1: https://lpdaac.usgs.gov/products/mod13q1v061/
- GPM IMERG: https://gpm.nasa.gov/data/imerg


## Crop assessment and rotation engine
The dashboard uses a transparent rule-based crop stress screening score and crop suitability index so the demo can work without trained ML files. If NASA POWER HY observations have been fetched, the root-zone soil-moisture summary is automatically used by the crop assessment unless a manual value is entered. NDVI remains a manual input; numeric MODIS NDVI point extraction is not implemented.

The crop-rotation ranking is now dynamic: it considers the selected current crop, soil texture, farmer priority, recent NASA POWER rainfall/maximum temperature, and NASA POWER HY root-zone soil moisture when available. Each score is a transparent demonstration ranking (not a probability, validated agronomic suitability rating, or yield estimate). It does not yet incorporate local planting calendars, cultivar, farm-specific irrigation, market price, or verified field trials.

See `RULE_BASED_ENGINE.md` and `ROTATION_SCORING.md` for the calculation assumptions and limitations.

### Global country and city selection
The location bar supports a worldwide country directory (REST Countries) and city lookup (Open-Meteo Geocoding). Choose a country, type a city, select a result, and the app updates the map coordinates and reloads NASA POWER observations. Browser GPS is optional and requires user permission. Manual latitude/longitude remains available as a fallback. Locations beyond NASA POWER's supported latitude range are rejected with a message.

The dashboard also supports 7/30/90/180-day NASA POWER observation windows and CSV export of loaded daily weather records. Country/city lookup and NASA data require internet access; the geocoding service is separate from NASA.


## Reliability and interface update
- The dashboard now checks the backend `/health` route rather than treating ML model availability as backend availability.
- The crop assessment button is explicitly a rule-based calculation; the UI no longer suggests that ML models are running.
- Missing rainfall observations remain missing rather than being silently converted to zero rainfall. Assessment skips rainfall rules when the observation window has no valid rainfall values.
- Manual soil-moisture and NDVI inputs are range-checked before scoring.
- The experimental trend panel is labelled as an indicator, not a weather forecast.
- Optional ML endpoints remain separate and return an explicit not-trained response until genuine labelled datasets are used to train and evaluate models.

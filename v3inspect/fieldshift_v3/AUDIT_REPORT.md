# FIELDSHIFT AI — Source Audit and Upgrade Notes

## Scope

This report is based on inspection of the supplied ZIP archive's source files. It is not a claim that the application was deployed or that external NASA services were live-tested.

## Original project findings

- React 18 + Vite frontend with Leaflet maps and Recharts charts.
- FastAPI backend with input validation and separate crop-stress/crop-yield prediction endpoints.
- NASA POWER daily point API retrieval for temperature, corrected precipitation, and solar radiation.
- NASA GIBS layers for true-colour imagery, soil-moisture visualization, MODIS NDVI, and land-surface temperature.
- Rule-based crop-rotation ranking and retrospective climate indicators.
- ML training pipeline and CSV templates, but no verified labelled datasets or trained model weights in the supplied ZIP.
- Numeric point extraction for SMAP/HLS NDVI is not connected; the map layers are visual overlays only.

## Changes made in this upgraded archive

1. Added working sidebar navigation that scrolls to the relevant dashboard sections; connected Settings to a service-status panel.
2. Replaced fixed November 2026 GIBS tile dates with date offsets generated from the current UTC date. Product availability can lag, so the chosen dates still need checking if a layer is blank.
3. Made the frontend backend URL configurable through `VITE_API_BASE_URL` and added `.env.example`.
4. Made backend CORS origins configurable through `FIELDSHIFT_CORS_ORIGINS`.
5. Added API root metadata and safer model-metrics status handling.
6. Tightened prediction payload validation by rejecting unknown fields.
7. Added backend API tests for health, model-status shape, valid feature parsing, coordinate validation, and unknown fields.
8. Added an English demo script, competition submission checklist, and SI/AI disclosure draft.
9. Added explicit setup instructions for API configuration and backend tests.
10. Changed the top status label so it reflects whether NASA POWER data has actually loaded.

## Verification performed in this environment

- Python source compilation: passed.
- Backend automated tests: 5 passed.
- ZIP archive integrity: to be checked when packaging.
- Frontend dependency installation/build: not completed because npm registry DNS/network access was unavailable (`EAI_AGAIN`). Therefore no successful Vite production build or browser test is claimed.
- Live NASA POWER/GIBS service checks: not performed from this environment.

## Work that still requires real-world data or team action

- Supply genuine, matched crop-season observations with measured soil moisture, vegetation indices, stress labels, and harvested yield before training the ML models.
- Implement and validate numeric satellite point extraction (e.g. NASA AppEEARS / appropriate data services); imagery display alone is not a measurement.
- Align the model input aggregation window with the crop-season feature definitions used for training.
- Calibrate and independently validate climate and crop heuristics with local agronomists/field records before presenting them as actionable recommendations.
- Complete the AI/SI disclosure with the actual tools and contributions from the team. Add visible watermarks to any AI-generated images/videos used in the submission and disclose generated audio/code/data as required by the challenge instructions supplied by the team.
- Prepare final slides, team details, and public demo/submission links; verify current official challenge rules and dates.

## Important

This archive is an improved prototype and competition-preparation package. It is not a scientifically validated crop advisory product, and it is not yet a fully ML-enabled production system.


## NASA challenge alignment update
- Added live NASA POWER AG + NASA SMAP L4 via POWER HY endpoint: `/nasa/observations`.
- Added dashboard action and data summaries for temperature, rainfall, solar radiation, surface soil moisture and root-zone soil moisture.
- Added NASA data catalogue and updated challenge presentation slide.
- Automated backend tests: 5 passed; new NASA endpoint route registered and response parsing smoke-tested with mocked NASA responses.
- Live NASA network response and frontend production build remain unverified in this environment. MODIS NDVI and GPM IMERG numeric point extraction are not implemented; links/visual context only.

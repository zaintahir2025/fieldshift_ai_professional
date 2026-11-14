# Dynamic crop-rotation scoring (prototype)

The dashboard ranks a short list of possible follow-on crops using a transparent deterministic rubric. It does not use a trained ML model.

## Inputs used
- Selected current crop (affects which follow-on sequences receive a small sequence-fit bonus).
- Selected soil texture (Loam, Sandy, Clay) and a crop-specific illustrative soil-fit table.
- Farmer priority: Water conservation, Soil health, or Crop diversification.
- Recent NASA POWER weather window: 30-day total rainfall and maximum temperature, when loaded.
- NASA POWER Hydrology (HY) root-zone soil moisture (`RZMC`) summary, when fetched and available.

## Scoring
Each candidate begins with an illustrative base score. The engine adds/subtracts explicit points for sequence, farmer priority, soil texture, low recent rainfall, low root-zone moisture, and recent heat. Scores are clamped to 0–100 and sorted. The UI shows the leading three candidates and the main factors that contributed.

## Important limitations
- Scores are comparative demonstration values, not probabilities, confidence, yield forecasts, or validated suitability ratings.
- The current crop sequence bonuses are broad prototype rules, not a crop-calendar engine. Local planting/harvest dates, cultivar, disease history, water access, salinity, nutrient tests, market demand and farmer constraints are not yet modelled.
- NASA POWER weather and SMAP L4 root-zone moisture are gridded products at different spatial scales. SMAP L4 is approximately 9 km and is not a field-scale soil test.
- Missing moisture remains missing; the engine does not invent a value. If no NASA root-zone moisture is available and no manual value is supplied, moisture is excluded from the stress score.
- NDVI is still an optional manually entered measurement. Numeric MODIS NDVI extraction and quality filtering are not implemented in this build.
- Have local agronomists validate crop sequence and scoring weights before using the output for real farm decisions.

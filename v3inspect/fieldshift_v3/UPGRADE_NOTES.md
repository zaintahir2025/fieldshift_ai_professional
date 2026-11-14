# FIELDSHIFT AI — Competition upgrade notes

## What changed in this upgrade
1. Crop-rotation ranking is no longer a fixed three-row list. It responds to selected crop, soil texture, farmer priority, recent NASA POWER rainfall/maximum temperature, and NASA POWER HY root-zone moisture when fetched.
2. Ranking factors are exposed beside each suggestion and documented in `ROTATION_SCORING.md`. Scores are illustrative rule scores, not probabilities or validated agronomic recommendations.
3. Crop stress assessment automatically uses NASA POWER HY root-zone soil moisture when available, unless the user enters a manual override.
4. UI and documentation explicitly distinguish NASA gridded estimates, manual measurements, visual satellite tiles, and numeric satellite measurements.
5. Numeric MODIS NDVI point extraction is still not implemented; NDVI remains optional manual input.

## Verification performed
- Python backend syntax compilation: passed.
- Backend test suite: 5 passed.
- Frontend production build: not verified in this environment because npm dependencies could not be installed before the environment timeout. Run `npm install` then `npm run build` on the target Windows laptop.
- NASA live API calls: not independently verified during this packaging run. The user should click “Fetch NASA POWER + SMAP data” in the running app and check the response.

## Before competition submission
- Run frontend build and full browser test.
- Verify NASA API returns data for at least two test locations.
- Test missing-data behaviour and manual overrides.
- Validate rotation choices and thresholds with a local agriculture expert.
- Do not claim numeric MODIS NDVI extraction or farm-scale SMAP measurement.

## Global location explorer update (November 2026)
- Added a global country selector populated from REST Countries (`restcountries.com`).
- Added city search using Open-Meteo Geocoding API; selecting a result updates latitude/longitude, map center, and NASA POWER weather query.
- Added browser geolocation (permission-based) and manual coordinate entry fallback.
- Added 7-day observation window and CSV export for loaded NASA POWER daily observations.
- Location search services require an internet connection. NASA POWER-supported latitude range is enforced (−84.66° to 84.66°); data coverage and quality vary by region.
- No location is sent until the user selects a search result or grants browser location permission. Geocoding requests send the typed city and selected country to Open-Meteo.

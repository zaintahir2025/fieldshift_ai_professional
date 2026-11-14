# FIELDSHIFT V4 — Reliability & Professionalization

## Why the ML interface was changed
The project does not contain verified, labelled crop-stress observations or matched harvested-yield records, and no trained model artifacts are shipped. Calling those endpoints from the primary workflow could create confusing 503 errors or encourage users to treat unvalidated output as a prediction.

## Changes
- Removed ML status/inference from the dashboard's primary workflow.
- Dashboard now checks backend health using `/health`.
- Renamed the primary action to “Assess crop conditions” and made it a synchronous transparent rule-based calculation.
- Preserved optional ML training/API code separately for future use with sourced data.
- Missing rainfall values are no longer converted to zero; rainfall rules are skipped if no valid rainfall observations exist.
- Added input validation for soil moisture and NDVI fields.
- Renamed the experimental “outlook” language to a recent-condition risk indicator and clarified that it is not a weather forecast.
- Updated setup and project documentation to explain the ML limitation clearly.

## Validation
- Python syntax compilation: passed.
- Backend test suite: 5 passed.
- Frontend production build: not verified; npm dependency installation timed out in the build environment.
- Live NASA services: not verified in this build environment; test from the user's machine with internet access.

## Scientific boundary
Rule thresholds and rotation ranks are demonstration heuristics. They are not calibrated agronomic models, yield predictions, probabilities, irrigation prescriptions, or a substitute for local agricultural expertise.

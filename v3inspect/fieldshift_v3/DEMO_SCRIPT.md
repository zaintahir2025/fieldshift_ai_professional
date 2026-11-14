# FIELDSHIFT AI — 3-minute English Demo Script

## 0:00–0:25 — Problem

“Farm planning is affected by changing temperature, rainfall, and vegetation conditions. FIELDSHIFT AI is a prototype that brings location-specific Earth-data context into one simple agricultural planning workspace.”

## 0:25–1:10 — Live climate data

“Here I select a farm region. The dashboard requests daily temperature, corrected precipitation, and surface solar-radiation observations from NASA POWER for the selected coordinates and date range. The charts show the returned observations and their units.”

Show the location selector, date-range selector, chart, observation count, and NASA POWER attribution. If the API is unavailable, use a clearly labelled pre-recorded capture with its date; do not pretend it is live.

## 1:10–1:45 — Satellite context

“The map provides NASA GIBS imagery layers for visual context. These are image overlays, not extracted field measurements. Numeric soil-moisture and vegetation-index extraction is a future integration task.”

Switch the map layers and show the data-source explanation.

## 1:45–2:20 — Planning indicators

“The climate suitability score and short-term stress signal are transparent prototype heuristics derived from recent weather observations. Crop rotation options are illustrative rule-based suggestions. They are not calibrated agronomic advice, and users should validate decisions locally.”

Show the indicators, their method notes, and the limitations.

## 2:20–2:45 — ML readiness

“The project includes a Python API and Random Forest training pipeline. The supplied package intentionally does not invent field labels or claim trained models. The ML endpoints become available only after genuine, matched crop-stress and harvest-yield records are supplied, trained, and evaluated.”

Show model status and the data templates.

## 2:45–3:00 — Close

“Our next steps are field-data validation, numeric satellite-data extraction, and testing with agricultural users. FIELDSHIFT AI demonstrates how open Earth observations can be organized into a transparent local planning workflow.”

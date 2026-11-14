# Rule-Based Crop Intelligence Engine

The dashboard now uses a transparent, deterministic screening heuristic instead of calling untrained Random Forest endpoints.

## Outputs
- Crop stress assessment: Low, Moderate, or High, with a 0–100 screening score and contributing reasons.
- Crop suitability index: 0–100 inverse stress screening index with a qualitative category.

## Inputs
- NASA POWER temperature maximum and accumulated precipitation from the selected date window.
- Optional user-entered soil moisture and NDVI values. Leave these blank unless they are measured or retrieved from a documented source.
- Crop selection, which selects a demonstration heat threshold.

## Important limitations
- This is not machine learning, a probability, a calibrated crop model, a yield estimate, or an irrigation prescription.
- Crop thresholds and weights are prototype assumptions and require validation with local agronomists and field data.
- The suitability index must not be reported as tonnes/hectare.
- The old `/predict/stress` and `/predict/yield` endpoints remain in the backend as optional ML endpoints and still require real labelled training data. The updated dashboard does not call them.

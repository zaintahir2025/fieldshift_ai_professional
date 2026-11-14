# Training data requirements

The CSV templates are intentionally header-only. Do not train from invented/random rows.

## Crop stress labels
`stress_label` must be an observed/curated class: `Low`, `Moderate`, or `High`. Keep the source, date window, crop stage and label methodology in a separate provenance log. Labels can come from field scouting/extension records or a clearly identified satellite proxy (for example, NDVI anomaly); proxy-derived labels must be described as proxy labels, not ground truth.

## Yield labels
`yield_t_ha` must be an observed harvested yield in tonnes/hectare for the same crop, location and season represented by the weather/remote-sensing features. Record the original source and whether it is farm, district, province or national scale. Do not mix scales without documenting it.

## Feature window
Aggregate all climate and satellite features over the crop's defined growing season, not an arbitrary recent 14-day period. `soil_moisture_m3_m3` is volumetric soil moisture (0–1); `ndvi_mean` is mean NDVI (-1 to 1); `ndvi_change` is the change over the selected season/window. Ensure features are available before harvest to avoid target leakage.

Recommended: at least 100 usable labelled rows per task for the initial pipeline; substantially more and multiple years/locations are needed for credible generalisation. Include `location_id` so the training script can hold out entire locations for testing when there are at least three locations.

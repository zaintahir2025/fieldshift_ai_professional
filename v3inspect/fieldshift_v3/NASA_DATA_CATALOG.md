# FIELDSHIFT AI — NASA data catalogue and challenge alignment

## Challenge objective (from the team's supplied challenge screenshot)
Create a decision-support tool that uses NASA Earth observations together with local soil information, crop characteristics, and farmer priorities so farmers can explore crop-rotation strategies that may strengthen soil health and adapt farms to changing conditions.

## What this project now uses

| Resource | Role | Integration status | Key caveat |
|---|---|---|---|
| NASA POWER Daily AG | Temperature, corrected precipitation, solar radiation | Live numeric API in dashboard and backend | Gridded analysis-ready data, not a farm weather station |
| NASA SMAP L4 via POWER HY | Surface and root-zone soil moisture | Live numeric API endpoint when data available | About 9 km; not field-scale soil test |
| NASA MODIS MOD13Q1 | NDVI / vegetation condition | GIBS visual layer + official dataset reference | Numeric point extraction not implemented |
| NASA GPM IMERG | Precipitation | Official dataset reference only | Numeric point extraction not implemented |
| NASA ECOSTRESS | Evapotranspiration / surface temperature | Future-work recommendation | Not integrated |

## Live API
`GET /nasa/observations?latitude=31.45&longitude=73.13&days=30`

Returns daily observations and period summaries, with source metadata and limitations. Valid `days` range is 7–90. Coordinates are validated; the latitude range is restricted to the SMAP coverage limit.

## How the challenge's non-NASA inputs are represented
- **Local soil information:** user-selectable soil texture in the crop-rotation prototype. A soil test upload / measured pH, organic carbon, N-P-K, salinity and texture dataset remains future work.
- **Crop characteristics:** crop selection and rotation candidate characteristics are represented in the prototype; crop calendars, cultivar and local suitability data need agronomic validation.
- **Farmer priorities:** the user can choose a priority such as water conservation or soil health; ranking logic is currently transparent demonstration heuristics, not a validated optimizer.

## Do not overclaim
Do not claim that all NASA resources listed above are live feeds. Do not describe GIBS map tiles as extracted numeric values. Do not claim that a 9 km SMAP cell represents a single farm plot. Do not present heuristic rankings as validated agronomic advice. Keep these limitations visible in demos and submissions.

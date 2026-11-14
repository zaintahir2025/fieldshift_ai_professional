# NASA Space Apps Challenge 2026 — Submission Preparation

This is a preparation guide, not an official eligibility or judging determination. Confirm current rules and deadlines on the challenge website and in the official 2026 Judging and Awards Guide.

## Project summary

FIELDSHIFT AI is a climate-aware agricultural decision-support prototype. It retrieves daily weather observations from NASA POWER, displays NASA GIBS satellite imagery as visual context, and presents transparent prototype indicators and crop-rotation heuristics for a selected location. Its purpose is to help users explore climate conditions and identify questions for local agricultural planning.

## Five judging criteria — evidence to prepare

| Criterion | Evidence the team should demonstrate |
|---|---|
| Impact | A clearly defined farmer/user problem, intended beneficiaries, and a realistic explanation of how timely climate context could support decisions. Do not claim measured impact without user research. |
| Creativity | Explain the team's own idea: connecting location-specific climate context, satellite visual layers, and understandable farm-planning signals in one workflow. |
| Validity | Show NASA POWER source attribution, API response examples, units, date ranges, transparent formulas, limitations, and tests. Separate imagery overlays from extracted measurements. |
| Relevance | Map each implemented feature to the selected challenge theme and explain why each data source is appropriate. |
| Presentation | Provide a concise English slide deck, a working demo, readable charts, clear narration, and a limitations slide. |

## Claims that must remain accurate

- NASA POWER supplies the numeric daily weather observations currently used by the dashboard.
- NASA GIBS layers are map overlays. They are not automatically extracted farm-point SMAP/NDVI measurements.
- The climate suitability index and 7-day stress outlook are demonstration heuristics, not calibrated agronomic forecasts.
- Crop rotation scores are illustrative rules, not validated local recommendations.
- ML API pipelines are present, but no trained model weights or verified labelled training data are included in the starter archive. Predictions remain unavailable until genuine, matched field labels are collected and models are evaluated.

## Submission checklist

- [ ] Team has independently confirmed the challenge's current rules, challenge prompt, and deadline.
- [ ] Project title, challenge selection, team details, and public project link are correct.
- [ ] English project description and English slide deck are complete.
- [ ] Demo link works for reviewers without private credentials where possible.
- [ ] All external data sources, products, units, temporal windows, and caveats are cited.
- [ ] AI/SI usage disclosure is accurate and complete (see `AI_USAGE_DISCLOSURE.md`).
- [ ] Every AI-generated image/video has the required visible watermark.
- [ ] AI-generated audio is disclosed in descriptive text and metadata.
- [ ] AI-generated code/data assistance is disclosed in descriptive text and metadata.
- [ ] No NASA branding, logos, flags, or mission identifiers have been added to generated content.
- [ ] Demo has been tested on a clean machine and on the actual presentation network.
- [ ] No API keys, personal data, or private credentials are committed.

## Suggested English slide structure

1. Title, team, selected challenge, and one-sentence problem.
2. The user problem and intended beneficiaries.
3. The team's original solution concept and workflow.
4. NASA data sources and why they are relevant.
5. Live demo screenshots with dates, locations, units, and attribution.
6. Technical architecture and data flow.
7. Validation evidence, tests, and what is not yet validated.
8. Expected impact, limitations, next steps, and AI/SI disclosure.

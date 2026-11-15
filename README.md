# FIELDSHIFT AI (Flutter Professional Edition)
### Earth Intelligence for Climate-Resilient Farms & Soil Health
**NASA Space Apps Challenge 2026 — Adapting Farms with NASA Data**

<p align="center">
  <img src="assets/images/logo.png" width="140" alt="FieldShift AI Logo" />
</p>

[![Deploy Flutter Web to GitHub Pages](https://github.com/zaintahir2025/fieldshift_ai_professional/actions/workflows/deploy.yml/badge.svg)](https://github.com/zaintahir2025/fieldshift_ai_professional/actions/workflows/deploy.yml)
[![Live Web App](https://img.shields.io/badge/Live%20Web%20App-GitHub%20Pages-brightgreen?logo=google-chrome&logoColor=white)](https://zaintahir2025.github.io/fieldshift_ai_professional/)
[![Flutter](https://img.shields.io/badge/Flutter-3.47.5-blue?logo=flutter)](https://flutter.dev)
[![NASA Earth Observations](https://img.shields.io/badge/NASA%20Data-SMAP%20%7C%20POWER%20%7C%20GRACE%20%7C%20ECOSTRESS%20%7C%20GPM-red?logo=nasa)](https://power.larc.nasa.gov/)

🌐 **Live Web Application**: [https://zaintahir2025.github.io/fieldshift_ai_professional/](https://zaintahir2025.github.io/fieldshift_ai_professional/)  
📂 **GitHub Repository**: [https://github.com/zaintahir2025/fieldshift_ai_professional](https://github.com/zaintahir2025/fieldshift_ai_professional)

---

## 🌾 Executive Summary

**FIELDSHIFT AI** is an agricultural decision-support platform built completely in **Flutter**. It bridges global NASA Earth observation datasets with ground-level agricultural constraints, empowering farmers and extension officers to explore adaptive crop rotation strategies, protect long-term soil health, and strengthen farm resilience against rising temperatures, erratic precipitation, and groundwater depletion.

### Core Guiding Ethos: *Human-in-the-Loop Decision Support*
> **"Intended to support—not replace—local farmer expertise, field soil tests, and extension officer judgment."**  
> FIELDSHIFT AI translates complex gridded satellite measurements into intuitive, interpretable planning options while transparently communicating data resolutions, assumptions, and uncertainties.

---

## 🚀 Key Capabilities & Modules

### 1. Crop Rotation Decision Engine (Comparative Strategy Matrix)
Compares **4 distinct rotation strategies** side-by-side, including the conventional monoculture baseline:
- **Strategy 1: Conventional Intensive Monoculture (Baseline Practice)**
  - *Wheat ➔ Rice / Cotton continuous cycle with 85 days of bare summer fallow.*
  - Highlights soil organic carbon depletion, high synthetic nitrogen requirements (-110 kg N/ha), high water footprint, and persistent pest/weed carryover.
- **Strategy 2: Regenerative Soil Health & Nitrogen-Fixing Legume Strategy**
  - *Current Crop ➔ 60-day Summer Mung Bean catch crop ➔ Deep-rooted Chickpea/Lentil ➔ Cover crop.*
  - Fixes net **+58 kg N/ha**, saves **28.5% irrigation water**, slashes bare fallow to **18 days**, and stimulates mycorrhizae.
- **Strategy 3: Climate-Resilient & Water-Conservation Diverse Rotation**
  - *C4 Sorghum/Millet ➔ Chickpea ➔ Mustard/Canola bio-fumigant.*
  - Engineered for acute water-stress zones (NASA GRACE aquifer depletion); cuts irrigation demand by **46.2%** and bio-fumigates soil against parasitic nematodes.
- **Strategy 4: High-Value Agro-Ecological & Livestock Forage Synergy**
  - *Maize ➔ Multi-cut Berseem Clover / Alfalfa ➔ Deep-taproot Sunflower.*
  - Delivers continuous weekly dairy cash flow (4–6 forage harvests), pumps massive root biomass into topsoil, and attracts pollinators.

#### For Every Strategy, the App Explains:
1. **Why Suggested**: Agronomic reasoning and phenological fit.
2. **NASA Evidence Supported**: Direct linkages to NASA SMAP root-zone moisture, POWER thermal patterns, and GRACE aquifer anomalies.
3. **Agronomic Benefits**: Soil organic matter accumulation, biological N₂ fixation, water savings, pest cycle disruption.
4. **Information Gaps**: Local seed variety purity, Rhizobium inoculant availability, milling/processing access.
5. **Risks Requiring Local Review**: Market price gluts, pod borer scouting, bird depredation.
6. **Vulnerability Windows**: Phenological hazards (terminal heat waves, unseasonal frost, overcast fungal humidity).

---

### 2. Geospatial Mapping & Landscape Vulnerability Visualization
- **Interactive Mapping Engine (`flutter_map`)**: Smooth pan, zoom, coordinate tap, and multi-layer selector.
- **NASA GIBS WMTS Imagery Overlays**:
  - `OpenStreetMap` high-contrast basemap.
  - `NASA MODIS Terra Corrected Reflectance (True Color)`.
  - `NASA SMAP / Sentinel-1 Active-Passive Soil Moisture`.
  - `NASA MODIS Terra 8-day NDVI (Vegetation Index)`.
  - `NASA MODIS Daytime Land Surface Temperature (LST)`.
- **Field-Level Vulnerability Zones & Micro-Topography**:
  - **Zone A (Erosion Swale)**: High runoff risk on 4.8% slope derived from **NASA SRTM 30m DEM** + **GPM IMERG** 95th-percentile storm events.
  - **Zone B (Water Stress Hotspot)**: Severe root-zone desiccation (<0.14 m³/m³) mapped with **NASA SMAP L4** and **ECOSTRESS** Evaporative Stress Index.
  - **Zone C (Frost Drainage Hollow)**: Low-lying concave terrain where nocturnal cold air pools during **NASA POWER** sub-zero winter spells.
  - **Zone D (Bare Ground SOC Loss Zone)**: Summer gap where soil surface exceeds 52°C, causing organic carbon oxidation.
- **Annual Canopy & Bare Ground Timeline Scrubber**: Interactive 12-month slider illustrating seasonal soil cover vs erosion-prone fallow windows.

---

### 3. Climate "What-If" Scenario Simulator
Interactive scenario sliders allow farmers to stress-test their farming systems against future climate shocks:
- **Temperature Anomaly Slider**: `0.0°C` to `+4.0°C`
- **Rainfall Anomaly Slider**: `-40%` to `+40%`
- **Live Re-Scoring**: Evaluates heat-threshold exceedance and updates rotation viability scores in real time.
- **Adaptive Interventions**: Suggests practical farmer adjustments (e.g., advancing sowing date by 12 days, zero-till stubble mulch, switching to C4 sorghum).

---

### 4. Farmer-Centered Design & Local Constraints
- **Adaptive UI**: One-tap toggle between **"Simple Farmer View"** (high-contrast cards, direct advice) and **"Earth Data Specialist View"** (deep satellite parameters).
- **Customizable Farming Constraints**:
  - *Farming Priority*: Water Conservation, Soil Health, Diversification, Cash Flow, Livestock Forage.
  - *Irrigation Infrastructure*: Rotational Canal, Deep Groundwater Tubewell, Drip/Micro, Rainfed.
  - *Equipment Level*: Tractor, Zero-Till Direct Seeder (Happy Seeder), Combine Harvester, Manual/Draft.
  - *Soil Texture*: Loam, Sandy Loam, Clay, Silt Loam.
  - *Market Access*: Local Mandi, Processing Contract, Dairy Integration, Seed Cooperative.
- **In-Situ Sensor Overrides**: Optional inputs for measured capacitive probe soil moisture (m³/m³) or drone NDVI.
- **Transparent Rule-Based Screening**: 0–100 crop stress and suitability calculation without opaque black-box models.

---

### 5. NASA Earth Observations Catalog & Data Transparency
Detailed documentation and live links for official NASA resources:
- **NASA POWER (Agroclimatology Daily)**: Point API for `T2M`, `T2M_MAX`, `T2M_MIN`, `PRECTOTCORR`, `ALLSKY_SFC_SW_DWN`.
- **NASA SMAP (Soil Moisture Active Passive)**: L4 9 km surface (`SFMC`) and root-zone (`RZMC`) soil moisture via POWER HY.
- **NASA MODIS / Terra**: MOD13Q1 NDVI and MOD11A2 Land Surface Temperature.
- **NASA GRACE / GRACE-FO**: Terrestrial Water Storage anomaly tracking deep groundwater depletion.
- **NASA ECOSTRESS**: 70 m Evaporative Stress Index (ESI) on the International Space Station.
- **NASA GPM IMERG**: Multi-satellite extreme precipitation and erosion hazard modeling.
- **NASA SRTM**: 30 m digital elevation, slope gradients, and frost drainage hollow analysis.
- **Landsat 8–9 & HLS (Harmonized Landsat-Sentinel)**: 30 m field-scale vegetation monitoring.

---

### 6. Offline Resilience & Advisory Export
- **Live REST & Calibrated Offline Fallback**: Queries NASA POWER directly; if in remote offline fields, automatically activates a statistically calibrated historical model with clear UI status badges.
- **CSV Data Export**: Export daily meteorological and soil moisture time series for offline spreadsheet analysis.
- **Agronomic Advisory Report**: Formats complete extension advisory documents for local agricultural consultants and farmer cooperatives.

---

## 🛠️ Project Structure

```
lib/
├── main.dart                       # App entry point, MultiProvider & adaptive shell
├── models/
│   ├── farm_location.dart          # Agricultural locations, coordinates & climate zones
│   ├── nasa_observation.dart      # NASA daily series, summary stats & catalog metadata
│   ├── rotation_strategy.dart     # 4 comparative rotation strategies & crop sequences
│   ├── vulnerability_zone.dart     # Field vulnerability polygons, severity & mitigation
│   ├── farmer_constraints.dart     # Priorities, irrigation, equipment & market constraints
│   └── climate_scenario.dart       # Temperature & rainfall anomaly slider states
├── services/
│   ├── nasa_power_service.dart     # Live NASA POWER REST client with offline fallback
│   ├── geocoding_service.dart      # Open-Meteo worldwide city search & preset directory
│   ├── rotation_engine.dart        # Deterministic rotation ranking & agronomic evaluation
│   └── climate_risk_engine.dart    # Climate suitability gauge, trend outlook & stress screening
├── providers/
│   └── farm_provider.dart          # Central ChangeNotifier state manager
├── theme/
│   └── app_theme.dart              # Earth emerald palette, typography & widget styles
├── widgets/
│   ├── climate_chart.dart          # fl_chart temperature area & rainfall dual-axis chart
│   ├── risk_gauge.dart             # Climate Suitability Index meter & sub-score pills
│   ├── rotation_strategy_card.dart # Complete rotation card with evidence, gaps & risks
│   ├── vulnerability_map_card.dart # flutter_map with NASA GIBS overlays & zone polygons
│   ├── scenario_slider_widget.dart # What-If temperature & precipitation sliders
│   ├── stat_card.dart              # Metric cards with units, trends & NASA source tags
│   └── farmer_advisory_banner.dart # Prominent human-in-the-loop ethical AI notice
└── views/
    ├── overview_view.dart          # Farm overview dashboard & recent climate signals
    ├── geospatial_map_view.dart    # Full map, satellite layers & vulnerability zones
    ├── crop_rotation_view.dart     # 4-strategy comparison matrix & detailed cards
    ├── scenario_simulator_view.dart# What-If climate stress simulation & interventions
    ├── farmer_profile_view.dart    # Priorities, constraints & in-situ probe inputs
    └── nasa_catalog_view.dart      # Dataset catalog, scientific caveats & report export
```

---

## 💻 Getting Started

### Prerequisites
- **Flutter SDK**: `^3.47.0` (Dart `^3.13.0`)
- Operating System: Windows, macOS, Linux, Android, iOS, or Web

### Installation & Run

```bash
# Clone the repository and enter the directory
cd fieldshift_ai_professional

# Install dependencies
flutter pub get

# Run static analysis (verifies zero warnings or errors)
flutter analyze

# Run automated tests
flutter test

# Run application on Chrome (Web)
flutter run -d chrome

# Or run application on Windows Desktop
flutter run -d windows
```

### Build for Production Web

```bash
flutter build web
```

---

## 📜 Scientific Limitations & Transparency Notice
- **Gridded Resolution**: NASA POWER (~50 km) and SMAP L4 (~9 km) provide landscape-scale hydrologic and climatological context, not localized on-farm soil probe measurements.
- **Visual Overlays vs Extracted Points**: Map tile layers from NASA GIBS are visual representations; numeric point metrics in this application are derived from NASA POWER Daily APIs.
- **Rule-Based Screening**: The suitability index and rotation rankings are transparent deterministic heuristics based on agronomic thresholds, not black-box unvalidated ML models.
- **Local Validation**: Always cross-verify rotation suggestions with local agricultural extension officers, certified seed suppliers, and in-situ soil chemical tests before purchasing seed or implementing changes.

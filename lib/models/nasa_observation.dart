class DailyObservation {
  final DateTime date;
  final String dateKey; // MM/dd
  final double? tempMean;
  final double? tempMax;
  final double? tempMin;
  final double? rainfall;
  final double? solarRadiation;
  final double? surfaceSoilMoisture; // GWETTOP (0-1)
  final double? rootZoneSoilMoisture; // GWETROOT (0-1)
  final double? evapotranspiration; // EVPTRNS (MJ/m²/day)
  final double? relativeHumidity; // RH2M (%)

  const DailyObservation({
    required this.date,
    required this.dateKey,
    this.tempMean,
    this.tempMax,
    this.tempMin,
    this.rainfall,
    this.solarRadiation,
    this.surfaceSoilMoisture,
    this.rootZoneSoilMoisture,
    this.evapotranspiration,
    this.relativeHumidity,
  });

  bool get isDryDay => (rainfall ?? 0) < 1.0;
  bool get isHeatStressDay => (tempMax ?? 0) >= 35.0;
  bool get isFrostRiskDay => (tempMin ?? 10.0) <= 2.0;
  bool get isHumidFungalRisk => (relativeHumidity ?? 0) >= 75.0 && (tempMean ?? 0) >= 20.0;

  double? get soilMoisture => rootZoneSoilMoisture;
}

class AgroClimateSummary {
  final double meanTemp;
  final double maxTemp;
  final double minTemp;
  final double meanRainfall;
  final double totalRainfall;
  final int dryDaysCount;
  final int heatStressDaysCount;
  final int frostRiskDaysCount;
  final double meanSolar;
  final double? meanSurfaceMoisture;
  final double? meanRootZoneMoisture;
  final double? meanEvapotranspiration;
  final double? meanRelativeHumidity;
  final double? elevationMeters;
  final double? graceWaterStorageTrend; // cm/year LWE
  final int observationDays;
  final bool isLiveNasaData;
  final DateTime fetchTimestamp;
  final String dataSourceAttribution;

  const AgroClimateSummary({
    required this.meanTemp,
    required this.maxTemp,
    required this.minTemp,
    required this.meanRainfall,
    required this.totalRainfall,
    required this.dryDaysCount,
    this.heatStressDaysCount = 0,
    this.frostRiskDaysCount = 0,
    required this.meanSolar,
    this.meanSurfaceMoisture,
    this.meanRootZoneMoisture,
    this.meanEvapotranspiration,
    this.meanRelativeHumidity,
    this.elevationMeters,
    this.graceWaterStorageTrend,
    required this.observationDays,
    required this.isLiveNasaData,
    required this.fetchTimestamp,
    this.dataSourceAttribution = 'NASA POWER Daily Agroclimatology & SMAP L4 via POWER AG',
  });
}

class NasaDatasetMetadata {
  final String id;
  final String shortCode;
  final String fullName;
  final String agency;
  final String spatialResolution;
  final String temporalResolution;
  final String primaryApplication;
  final String parameters;
  final String liveStatus;
  final String officialDocUrl;
  final List<String> scientificCaveats;

  const NasaDatasetMetadata({
    required this.id,
    required this.shortCode,
    required this.fullName,
    required this.agency,
    required this.spatialResolution,
    required this.temporalResolution,
    required this.primaryApplication,
    required this.parameters,
    required this.liveStatus,
    required this.officialDocUrl,
    required this.scientificCaveats,
  });

  static const List<NasaDatasetMetadata> catalog = [
    NasaDatasetMetadata(
      id: 'nasa_power_ag',
      shortCode: 'NASA POWER',
      fullName: 'NASA Prediction of Worldwide Energy Resources (Agroclimatology)',
      agency: 'NASA Langley Research Center',
      spatialResolution: '0.5° × 0.5° (~50 km gridded)',
      temporalResolution: 'Daily (1981 – near present)',
      primaryApplication: 'Daily air temperature, precipitation, surface solar radiation, relative humidity, frost risk',
      parameters: 'T2M, T2M_MAX, T2M_MIN, PRECTOTCORR, ALLSKY_SFC_SW_DWN, RH2M',
      liveStatus: 'Active Live Numeric REST API',
      officialDocUrl: 'https://power.larc.nasa.gov/',
      scientificCaveats: [
        'Gridded analysis-ready data from assimilation models (MERRA-2/GEOS), not an on-farm weather station.',
        'Rainfall amounts reflect regional grid averages; localized convective downpours may vary.',
      ],
    ),
    NasaDatasetMetadata(
      id: 'nasa_smap_l4',
      shortCode: 'NASA SMAP',
      fullName: 'Soil Moisture Active Passive (L4 Global 9 km Root-Zone Soil Moisture)',
      agency: 'NASA Jet Propulsion Laboratory / GSFC',
      spatialResolution: '9 km gridded (enhanced)',
      temporalResolution: 'Daily / 3-hourly assimilation',
      primaryApplication: 'Top 5 cm surface soil moisture and 0–100 cm root-zone available water capacity',
      parameters: 'GWETTOP (surface), GWETROOT (root-zone 0-100cm profile wetness)',
      liveStatus: 'Active Live Numeric API (via NASA POWER AG) & GIBS WMTS Layer',
      officialDocUrl: 'https://smap.jpl.nasa.gov/',
      scientificCaveats: [
        '9 km spatial resolution provides landscape hydrologic context, not a field-scale soil probe.',
        'Validation against in-situ capacitive soil probes recommended for precision irrigation scheduling.',
      ],
    ),
    NasaDatasetMetadata(
      id: 'nasa_modis_terra',
      shortCode: 'MODIS / Terra',
      fullName: 'Moderate Resolution Imaging Spectroradiometer (NDVI & Surface Temp)',
      agency: 'NASA Goddard Space Flight Center',
      spatialResolution: '250 m – 1 km',
      temporalResolution: '1–2 days revisit / 8-day composite',
      primaryApplication: 'Vegetation greenness (NDVI), canopy vigor, Land Surface Temperature (LST)',
      parameters: 'MOD13Q1 (NDVI), MOD11A2 (LST Daytime / Nighttime)',
      liveStatus: 'Interactive NASA GIBS Tile Layer & Reference Catalog',
      officialDocUrl: 'https://modis.gsfc.nasa.gov/',
      scientificCaveats: [
        'Cloud cover can obscure optical scenes; multi-day compositing reduces gaps but introduces temporal smoothing.',
        'Tile overlays in map view represent satellite imagery layers, not extracted point values.',
      ],
    ),
    NasaDatasetMetadata(
      id: 'nasa_grace_fo',
      shortCode: 'GRACE / GRACE-FO',
      fullName: 'Gravity Recovery and Climate Experiment Follow-On',
      agency: 'NASA JPL / GFZ German Research Centre',
      spatialResolution: '~300 km footprint',
      temporalResolution: 'Monthly anomalies',
      primaryApplication: 'Deep groundwater aquifer depletion trends and total terrestrial water storage (TWS)',
      parameters: 'Liquid Water Equivalent (LWE) thickness anomalies (cm)',
      liveStatus: 'Trend Analysis & Regional Groundwater Stress Indices',
      officialDocUrl: 'https://gracefo.jpl.nasa.gov/',
      scientificCaveats: [
        'Measures gravitational mass variations over large regional aquifer basins.',
        'Cannot resolve single-well drawdowns, but provides indispensable warning of regional water table declines.',
      ],
    ),
    NasaDatasetMetadata(
      id: 'nasa_ecostress',
      shortCode: 'ECOSTRESS',
      fullName: 'Ecosystem Spaceborne Thermal Radiometer Experiment on Space Station',
      agency: 'NASA JPL (ISS payload)',
      spatialResolution: '70 m × 70 m',
      temporalResolution: 'Varying ISS orbit pass (1–5 days)',
      primaryApplication: 'Evaporative Stress Index (ESI) and plant canopy water stress before visible wilting',
      parameters: 'EVPTRNS (Evapotranspiration), Evaporative Stress Index, Canopy Surface Temperature',
      liveStatus: 'Vulnerability Hotspot Integration & NASA AppEEARS Catalog',
      officialDocUrl: 'https://ecostress.jpl.nasa.gov/',
      scientificCaveats: [
        'High-resolution thermal imaging captures field-level stress, but ISS orbit means non-sun-synchronous revisit.',
      ],
    ),
    NasaDatasetMetadata(
      id: 'nasa_gpm_imerg',
      shortCode: 'GPM IMERG',
      fullName: 'Global Precipitation Measurement Integrated Multi-satellitE Retrievals',
      agency: 'NASA GSFC / JAXA',
      spatialResolution: '0.1° × 0.1° (~10 km)',
      temporalResolution: 'Half-hourly / Daily',
      primaryApplication: 'Extreme precipitation events, rainfall intensity, soil runoff and erosion hazards',
      parameters: 'PrecipitationCal (mm/hr), accumulation',
      liveStatus: 'Erosion Risk Zone Modeling & GPM Directory Catalog',
      officialDocUrl: 'https://gpm.nasa.gov/',
      scientificCaveats: [
        'Radar and radiometer multi-satellite constellation with rain gauge calibration.',
      ],
    ),
    NasaDatasetMetadata(
      id: 'nasa_srtm_elevation',
      shortCode: 'NASA SRTM',
      fullName: 'Shuttle Radar Topography Mission Digital Elevation Model',
      agency: 'NASA / NGA / USGS',
      spatialResolution: '1 arc-second (~30 m)',
      temporalResolution: 'Global static baseline elevation',
      primaryApplication: 'Topographic slope, aspect, runoff concentration channels, cold-air frost drainage hollows',
      parameters: 'Elevation above sea level (meters), Slope gradient (%)',
      liveStatus: 'Topographic Elevation & Micro-Relief Integration',
      officialDocUrl: 'https://www2.jpl.nasa.gov/srtm/',
      scientificCaveats: [
        'Provides 30m digital terrain surface; micro-relief (<1m bunds or furrows) requires local laser leveling data.',
      ],
    ),
    NasaDatasetMetadata(
      id: 'landsat_hls',
      shortCode: 'Landsat 8-9 & HLS',
      fullName: 'Harmonized Landsat and Sentinel-2 (HLS v2.0)',
      agency: 'NASA GSFC / USGS / ESA',
      spatialResolution: '30 m high-resolution',
      temporalResolution: '2–3 day combined revisit',
      primaryApplication: 'Field-scale bare ground detection, crop cover timelines, residue monitoring',
      parameters: 'Surface Reflectance, HLS-VI (NDVI, EVI, NDRE)',
      liveStatus: 'Field-Scale Bare Ground Analysis & USGS EarthExplorer Catalog',
      officialDocUrl: 'https://hls.gsfc.nasa.gov/',
      scientificCaveats: [
        'Atmospherically corrected surface reflectance at 30 m pixel resolution.',
      ],
    ),
  ];
}

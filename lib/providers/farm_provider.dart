import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latlong2/latlong.dart';
import '../models/farm_location.dart';
import '../models/nasa_observation.dart';
import '../models/rotation_strategy.dart';
import '../models/vulnerability_zone.dart';
import '../models/farmer_constraints.dart';
import '../models/climate_scenario.dart';
import '../services/nasa_power_service.dart';
import '../services/rotation_engine.dart';
import '../services/climate_risk_engine.dart';
import '../services/localization_service.dart';
import '../services/geocoding_service.dart';

enum ChartMetricMode {
  tempAndRain('Temperature & Rainfall', 'T2M (°C) + PRECTOTCORR (mm/day)'),
  moistureAndEvp('Soil Wetness & Evapotranspiration', 'SMAP Root Wetness (0-1) + EVPTRNS'),
  heatAndHumidity('Heat Extremes & Humidity', 'T2M_MAX (°C) + RH2M (%)'),
  solarAndRain('Solar Radiation & Rain', 'ALLSKY_SFC (kWh/m²) + Precipitation');

  final String label;
  final String description;
  const ChartMetricMode(this.label, this.description);
}

class FarmProvider extends ChangeNotifier {
  final NasaPowerService _nasaService = NasaPowerService();

  FarmLocation _location = FarmLocation.presetLocations.first;
  int _rangeDays = 30;
  bool _isLoading = false;
  bool _isLocating = false;
  String? _errorMessage;

  AgroClimateSummary? _summary;
  List<DailyObservation> _observations = [];
  FarmRiskScore? _riskScore;
  PredictiveOutlook? _predictiveOutlook;
  CropAssessmentResult? _cropAssessment;
  List<RotationStrategy> _strategies = [];
  List<FieldVulnerabilityZone> _vulnerabilityZones = [];

  FarmerConstraints _constraints = const FarmerConstraints();
  ClimateScenario _scenario = const ClimateScenario();

  bool _isSimpleFarmerMode = false;
  String _activeMapLayer = 'OpenStreetMap';
  double _mapLayerOpacity = 0.70;
  int _activeTimelineMonth = DateTime.now().month;
  String _selectedStrategyId = 'regenerative_legume';

  ChartMetricMode _chartMetricMode = ChartMetricMode.tempAndRain;
  final Set<VulnerabilityType> _visibleVulnerabilityTypes = VulnerabilityType.values.toSet();
  String _language = 'en';

  FarmLocation get location => _location;
  int get rangeDays => _rangeDays;
  bool get isLoading => _isLoading;
  bool get isLocating => _isLocating;
  String? get errorMessage => _errorMessage;

  AgroClimateSummary? get summary => _summary;
  List<DailyObservation> get observations => _observations;
  FarmRiskScore? get riskScore => _riskScore;
  PredictiveOutlook? get predictiveOutlook => _predictiveOutlook;
  CropAssessmentResult? get cropAssessment => _cropAssessment;
  List<RotationStrategy> get strategies => _strategies;
  List<FieldVulnerabilityZone> get vulnerabilityZones => _vulnerabilityZones;

  FarmerConstraints get constraints => _constraints;
  ClimateScenario get scenario => _scenario;

  bool get isSimpleFarmerMode => _isSimpleFarmerMode;
  String get activeMapLayer => _activeMapLayer;
  double get mapLayerOpacity => _mapLayerOpacity;
  int get activeTimelineMonth => _activeTimelineMonth;
  String get selectedStrategyId => _selectedStrategyId;

  ChartMetricMode get chartMetricMode => _chartMetricMode;
  Set<VulnerabilityType> get visibleVulnerabilityTypes => _visibleVulnerabilityTypes;
  Set<VulnerabilityType> get activeVulnerabilityTypes => _visibleVulnerabilityTypes;
  String get language => _language;
  String get currentLanguage => _language;

  String tr(String key) => AppLocale.get(key, _language);
  String exportAdvisoryReportText() => generateAdvisoryReport();

  RotationStrategy? get selectedStrategy =>
      _strategies.firstWhere((s) => s.id == _selectedStrategyId, orElse: () => _strategies.isNotEmpty ? _strategies.first : _strategies.first);

  FarmProvider() {
    _initPreferencesAndLoad();
  }

  Future<void> _initPreferencesAndLoad() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _language = prefs.getString('pref_language') ?? 'en';
      _isSimpleFarmerMode = prefs.getBool('pref_simple_mode') ?? false;

      final savedLat = prefs.getDouble('pref_farm_lat');
      final savedLon = prefs.getDouble('pref_farm_lon');
      final savedName = prefs.getString('pref_farm_name');
      final savedCrop = prefs.getString('pref_current_crop');
      final savedSoil = prefs.getString('pref_soil_texture');

      if (savedLat != null && savedLon != null && savedName != null) {
        _location = FarmLocation(
          id: 'saved_farm',
          name: savedName,
          region: prefs.getString('pref_farm_region') ?? 'My Saved Parcel',
          country: prefs.getString('pref_farm_country') ?? 'Local',
          latitude: savedLat,
          longitude: savedLon,
          defaultCrop: savedCrop ?? 'Wheat',
          defaultSoil: savedSoil ?? 'Loam',
          climateZone: 'Local Agroecological Zone',
          groundwaterStatus: 'Aquifer Monitored',
        );
        if (savedCrop != null || savedSoil != null) {
          _constraints = _constraints.copyWith(
            currentCrop: savedCrop,
            soilTexture: savedSoil,
          );
        }
      }
    } catch (_) {
      // Preferences failure fallback
    }

    loadFarmData();
  }

  Future<void> _persistPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pref_language', _language);
      await prefs.setBool('pref_simple_mode', _isSimpleFarmerMode);
      await prefs.setDouble('pref_farm_lat', _location.latitude);
      await prefs.setDouble('pref_farm_lon', _location.longitude);
      await prefs.setString('pref_farm_name', _location.name);
      await prefs.setString('pref_farm_region', _location.region);
      await prefs.setString('pref_farm_country', _location.country);
      await prefs.setString('pref_current_crop', _constraints.currentCrop);
      await prefs.setString('pref_soil_texture', _constraints.soilTexture);
    } catch (_) {
      // Silent error
    }
  }

  Future<void> loadFarmData({FarmLocation? newLocation}) async {
    if (newLocation != null) {
      _location = newLocation;
      _constraints = _constraints.copyWith(
        currentCrop: newLocation.defaultCrop,
        soilTexture: newLocation.defaultSoil,
      );
      _persistPreferences();
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _nasaService.fetchAgroClimateData(
        latitude: _location.latitude,
        longitude: _location.longitude,
        days: _rangeDays,
      );

      _summary = result.summary;
      _observations = result.observations;

      _vulnerabilityZones = FieldVulnerabilityZone.generateForLocation(
        _location.latitude,
        _location.longitude,
        baseElevation: _summary?.elevationMeters ?? 185.0,
        weather: _summary,
      );

      _recalculateIntelligence();
    } catch (e) {
      _errorMessage = 'Failed to load NASA Earth observations: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _recalculateIntelligence() {
    if (_summary == null) return;

    _riskScore = ClimateRiskEngine.evaluateRisk(
      summary: _summary!,
      scenario: _scenario,
    );

    _predictiveOutlook = ClimateRiskEngine.computePredictiveOutlook(
      _observations,
      _constraints.currentCrop,
    );

    _strategies = RotationEngine.generateStrategies(
      currentCrop: _constraints.currentCrop,
      soilTexture: _constraints.soilTexture,
      constraints: _constraints,
      weather: _summary!,
      scenario: _scenario,
    );

    if (!_strategies.any((s) => s.id == _selectedStrategyId) && _strategies.isNotEmpty) {
      _selectedStrategyId = _strategies.first.id;
    }

    _cropAssessment = ClimateRiskEngine.assessCropConditions(
      weather: _summary!,
      crop: _constraints.currentCrop,
      manualSoilMoisture: _constraints.manualSoilMoisture,
      manualNdvi: _constraints.manualNdvi,
      manualNdviChange: _constraints.manualNdviChange,
      scenario: _scenario,
    );
  }

  void setLocation(FarmLocation newLoc) {
    loadFarmData(newLocation: newLoc);
  }

  /// Automatically locates user using browser or device GPS and resolves address via OpenStreetMap
  Future<bool> locateUserCurrentGps() async {
    _isLocating = true;
    notifyListeners();

    try {
      final pos = await GeocodingService.getCurrentDevicePosition();
      if (pos != null) {
        final loc = await GeocodingService.reverseGeocode(
          latitude: pos.latitude,
          longitude: pos.longitude,
          isGpsOrigin: true,
        );
        setLocation(loc);
        _isLocating = false;
        notifyListeners();
        return true;
      }
    } catch (_) {}

    _isLocating = false;
    notifyListeners();
    return false;
  }

  /// Sets location when a farmer taps anywhere on OpenStreetMap with instant Nominatim reverse geocoding
  void setFarmCoordinateFromMap(LatLng point, {String? customName}) async {
    final lat = point.latitude;
    final lon = point.longitude;

    if (customName != null && customName.isNotEmpty) {
      final loc = FarmLocation(
        id: 'map_pin_${lat.toStringAsFixed(3)}_${lon.toStringAsFixed(3)}',
        name: customName,
        region: 'OpenStreetMap Pin',
        country: 'Regional Farmland',
        latitude: lat,
        longitude: lon,
        defaultCrop: _constraints.currentCrop,
        defaultSoil: _constraints.soilTexture,
        climateZone: 'Micro-Topographical Parcel',
        groundwaterStatus: 'Aquifer Inferred from NASA GRACE',
      );
      setLocation(loc);
      return;
    }

    // Set immediate responsive placeholder
    final tempLoc = FarmLocation(
      id: 'map_pin_${lat.toStringAsFixed(3)}_${lon.toStringAsFixed(3)}',
      name: 'Resolving Location via OpenStreetMap...',
      region: 'Fetching Address & NASA Data',
      country: 'Global Farmland',
      latitude: lat,
      longitude: lon,
      defaultCrop: _constraints.currentCrop,
      defaultSoil: _constraints.soilTexture,
      climateZone: 'Agro-climatic Basin',
      groundwaterStatus: 'OpenStreetMap Selected Pin',
    );
    setLocation(tempLoc);

    // Asynchronously resolve real human-friendly place name via OpenStreetMap
    final resolvedLoc = await GeocodingService.reverseGeocode(
      latitude: lat,
      longitude: lon,
    );

    // Update with human-friendly place name
    if (_location.latitude == lat && _location.longitude == lon) {
      _location = resolvedLoc;
      notifyListeners();
    }
  }

  Future<List<FarmLocation>> searchOnlineLocations(String query) async {
    return await GeocodingService.searchPlaces(query);
  }

  void setCustomCoordinates(double lat, double lon, {String name = 'Custom Location'}) {
    setFarmCoordinateFromMap(LatLng(lat, lon), customName: name);
  }

  void setRangeDays(int days) {
    if (_rangeDays == days) return;
    _rangeDays = days;
    loadFarmData();
  }

  void setConstraints(FarmerConstraints newConstraints) {
    _constraints = newConstraints;
    _recalculateIntelligence();
    _persistPreferences();
    notifyListeners();
  }

  void updateCurrentCrop(String crop) {
    _constraints = _constraints.copyWith(currentCrop: crop);
    _recalculateIntelligence();
    _persistPreferences();
    notifyListeners();
  }

  void updateSoilTexture(String soil) {
    _constraints = _constraints.copyWith(soilTexture: soil);
    _recalculateIntelligence();
    _persistPreferences();
    notifyListeners();
  }

  void updatePriority(FarmerPriority priority) {
    _constraints = _constraints.copyWith(priority: priority);
    _recalculateIntelligence();
    notifyListeners();
  }

  void updateScenario(ClimateScenario newScenario) {
    _scenario = newScenario;
    _recalculateIntelligence();
    notifyListeners();
  }

  void resetScenario() {
    _scenario = const ClimateScenario();
    _recalculateIntelligence();
    notifyListeners();
  }

  void toggleSimpleFarmerMode() {
    _isSimpleFarmerMode = !_isSimpleFarmerMode;
    _persistPreferences();
    notifyListeners();
  }

  void setLanguage(String lang) {
    _language = lang;
    _persistPreferences();
    notifyListeners();
  }

  void setActiveMapLayer(String layer) {
    _activeMapLayer = layer;
    notifyListeners();
  }

  void setMapLayerOpacity(double opacity) {
    _mapLayerOpacity = opacity.clamp(0.0, 1.0);
    notifyListeners();
  }

  void toggleVulnerabilityType(VulnerabilityType type) {
    if (_visibleVulnerabilityTypes.contains(type)) {
      if (_visibleVulnerabilityTypes.length > 1) {
        _visibleVulnerabilityTypes.remove(type);
      }
    } else {
      _visibleVulnerabilityTypes.add(type);
    }
    notifyListeners();
  }

  void setChartMetricMode(ChartMetricMode mode) {
    _chartMetricMode = mode;
    notifyListeners();
  }

  void setActiveTimelineMonth(int month) {
    _activeTimelineMonth = month;
    notifyListeners();
  }

  void selectStrategy(String strategyId) {
    _selectedStrategyId = strategyId;
    notifyListeners();
  }

  /// Adds a custom user-designed rotation strategy to the comparison list
  void addCustomStrategy(dynamic input) {
    if (input is RotationStrategy) {
      _strategies.removeWhere((s) => s.id.startsWith('custom_rotation_'));
      _strategies.add(input);
      _selectedStrategyId = input.id;
      notifyListeners();
      return;
    }
    if (input is List<String>) {
      if (_summary == null) return;
      final custom = RotationEngine.evaluateCustomSequence(
        cropNames: input,
        constraints: _constraints,
        weather: _summary!,
        scenario: _scenario,
      );
      _strategies.removeWhere((s) => s.id.startsWith('custom_rotation_'));
      _strategies.add(custom);
      _selectedStrategyId = custom.id;
      notifyListeners();
    }
  }

  /// Exports NASA POWER Daily Observations as CSV
  String exportObservationsCsv() {
    final buffer = StringBuffer();
    buffer.writeln('date,temp_mean_c,temp_max_c,temp_min_c,precipitation_mm,solar_kwh_m2_day,smap_surface_wetness,smap_rootzone_wetness,evapotranspiration_mj_m2,relative_humidity_pct');
    for (final obs in _observations) {
      buffer.writeln(
        '${obs.date.toIso8601String().substring(0, 10)},'
        '${obs.tempMean ?? ""},'
        '${obs.tempMax ?? ""},'
        '${obs.tempMin ?? ""},'
        '${obs.rainfall ?? ""},'
        '${obs.solarRadiation ?? ""},'
        '${obs.surfaceSoilMoisture ?? ""},'
        '${obs.rootZoneSoilMoisture ?? ""},'
        '${obs.evapotranspiration ?? ""},'
        '${obs.relativeHumidity ?? ""}',
      );
    }
    return buffer.toString();
  }

  /// Generates a comprehensive extension advisory document
  String generateAdvisoryReport() {
    final buffer = StringBuffer();
    buffer.writeln('================================================================');
    buffer.writeln('FIELDSHIFT AI — CLIMATE-AWARE CROP ROTATION ADVISORY REPORT');
    buffer.writeln('NASA Space Apps Challenge 2026: Adapting Farms with NASA Data');
    buffer.writeln('================================================================\n');

    buffer.writeln('FARM LOCATION & CONTEXT:');
    buffer.writeln('Location: ${_location.name} (${_location.latitude.toStringAsFixed(4)}°, ${_location.longitude.toStringAsFixed(4)}°)');
    buffer.writeln('SRTM Elevation: ${_summary?.elevationMeters?.toStringAsFixed(0) ?? "185"} meters MSL');
    buffer.writeln('GRACE-FO Aquifer Trend: ${_summary?.graceWaterStorageTrend?.toStringAsFixed(1) ?? "-1.5"} cm/year LWE');
    buffer.writeln('Current Sown Crop: ${_constraints.currentCrop}');
    buffer.writeln('Soil Texture: ${_constraints.soilTexture}');
    buffer.writeln('Farmer Priority: ${_constraints.priority.label}');
    buffer.writeln('Irrigation Type: ${_constraints.irrigation.label}');
    buffer.writeln('');

    if (_summary != null) {
      buffer.writeln('NASA EARTH OBSERVATIONS (Past $_rangeDays Days):');
      buffer.writeln('Data Source: ${_summary!.dataSourceAttribution}');
      buffer.writeln('Mean Air Temp: ${_summary!.meanTemp.toStringAsFixed(1)}°C (Max: ${_summary!.maxTemp.toStringAsFixed(1)}°C, Min: ${_summary!.minTemp.toStringAsFixed(1)}°C)');
      buffer.writeln('Heat Stress Days (Tmax >= 35°C): ${_summary!.heatStressDaysCount}');
      buffer.writeln('Frost Risk Days (Tmin <= 2°C): ${_summary!.frostRiskDaysCount}');
      buffer.writeln('Accumulated Rainfall: ${_summary!.totalRainfall.toStringAsFixed(1)} mm (${_summary!.dryDaysCount} dry days)');
      buffer.writeln('Mean Solar Radiation: ${_summary!.meanSolar.toStringAsFixed(1)} kWh/m²/day');
      if (_summary!.meanRootZoneMoisture != null) {
        buffer.writeln('NASA SMAP L4 Root-Zone Wetness: ${(_summary!.meanRootZoneMoisture! * 100).toStringAsFixed(1)}% available profile');
      }
      if (_summary!.meanEvapotranspiration != null) {
        buffer.writeln('ECOSTRESS Evapotranspiration Flux: ${_summary!.meanEvapotranspiration!.toStringAsFixed(2)} MJ/m²/day');
      }
      buffer.writeln('');
    }

    if (_riskScore != null) {
      buffer.writeln('AGROCLIMATIC RISK ASSESSMENT:');
      buffer.writeln('Climate Suitability Index: ${_riskScore!.overallSuitabilityScore}/100 (${_riskScore!.statusLabel})');
      buffer.writeln('Heat Stress Score: ${_riskScore!.heatExposureScore}/100');
      buffer.writeln('Drought Deficit Score: ${_riskScore!.droughtDeficitScore}/100');
      buffer.writeln('');
    }

    buffer.writeln('COMPARATIVE CROP ROTATION STRATEGIES:');
    for (int i = 0; i < _strategies.length; i++) {
      final s = _strategies[i];
      buffer.writeln('--- STRATEGY ${i + 1}: ${s.title} ---');
      buffer.writeln('Suitability Score: ${s.overallScore}/100 | Tag: ${s.tag}');
      buffer.writeln('Water Savings: ${s.waterSavingsPercentage >= 0 ? "+" : ""}${s.waterSavingsPercentage.toStringAsFixed(1)}%');
      buffer.writeln('Nitrogen Balance: ${s.nitrogenBalanceKgPerHa >= 0 ? "+" : ""}${s.nitrogenBalanceKgPerHa.toStringAsFixed(0)} kg N/ha');
      buffer.writeln('Bare Soil Exposure Days: ${s.bareFieldDaysPerYear} days/year');
      buffer.writeln('Pest Break Rating: ${s.pestBreakRating}/5 stars');
      buffer.writeln('Why Suggested: ${s.whySuggested}');
      buffer.writeln('Evidence Supported:');
      for (final ev in s.evidenceSupported) {
        buffer.writeln('  • $ev');
      }
      buffer.writeln('Benefits:');
      for (final ben in s.agronomicBenefits) {
        buffer.writeln('  • $ben');
      }
      buffer.writeln('Information Gaps:');
      for (final gap in s.informationGaps) {
        buffer.writeln('  • $gap');
      }
      buffer.writeln('Risks Requiring Farmer/Agronomist Review:');
      for (final r in s.risksRequiringLocalReview) {
        buffer.writeln('  • $r');
      }
      buffer.writeln('');
    }

    buffer.writeln('================================================================');
    buffer.writeln('DISCLAIMER & TRANSPARENCY:');
    buffer.writeln('This tool is intended to support—not replace—local farmer expertise,');
    buffer.writeln('field soil tests, and extension officer judgment. NASA data represent');
    buffer.writeln('gridded satellite observations (~9 km to 50 km) and should be verified');
    buffer.writeln('with local agricultural conditions before making investment decisions.');
    buffer.writeln('================================================================');

    return buffer.toString();
  }
}

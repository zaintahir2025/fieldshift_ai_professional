import 'package:latlong2/latlong.dart';

class FarmLocation {
  final String id;
  final String name;
  final String region;
  final String country;
  final double latitude;
  final double longitude;
  final String defaultCrop;
  final String defaultSoil;
  final String climateZone;
  final String groundwaterStatus;

  const FarmLocation({
    required this.id,
    required this.name,
    required this.region,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.defaultCrop,
    required this.defaultSoil,
    required this.climateZone,
    required this.groundwaterStatus,
  });

  LatLng get toLatLng => LatLng(latitude, longitude);

  static const List<FarmLocation> presetLocations = [
    FarmLocation(
      id: 'faisalabad_pk',
      name: 'Faisalabad, Pakistan',
      region: 'Punjab, Pakistan',
      country: 'Pakistan',
      latitude: 31.4504,
      longitude: 73.1350,
      defaultCrop: 'Wheat',
      defaultSoil: 'Loam',
      climateZone: 'Semi-arid subtropical',
      groundwaterStatus: 'Moderate stress · Falling water table',
    ),
    FarmLocation(
      id: 'multan_pk',
      name: 'Multan, Pakistan',
      region: 'Southern Punjab, Pakistan',
      country: 'Pakistan',
      latitude: 30.1575,
      longitude: 71.5249,
      defaultCrop: 'Cotton',
      defaultSoil: 'Sandy Loam',
      climateZone: 'Arid · High summer heat (>45°C)',
      groundwaterStatus: 'High stress · Brackish aquifer zones',
    ),
    FarmLocation(
      id: 'lahore_pk',
      name: 'Lahore, Pakistan',
      region: 'Central Punjab, Pakistan',
      country: 'Pakistan',
      latitude: 31.5204,
      longitude: 74.3587,
      defaultCrop: 'Rice',
      defaultSoil: 'Clay Loam',
      climateZone: 'Semi-arid · High monsoon humidity',
      groundwaterStatus: 'Intensive tubewell extraction',
    ),
    FarmLocation(
      id: 'sahiwal_pk',
      name: 'Sahiwal, Pakistan',
      region: 'Punjab, Pakistan',
      country: 'Pakistan',
      latitude: 30.6682,
      longitude: 73.1114,
      defaultCrop: 'Maize',
      defaultSoil: 'Loam',
      climateZone: 'Semi-arid · Mixed grain & dairy forage',
      groundwaterStatus: 'Moderate aquifer level',
    ),
    FarmLocation(
      id: 'hyderabad_pk',
      name: 'Hyderabad, Pakistan',
      region: 'Sindh, Pakistan',
      country: 'Pakistan',
      latitude: 25.3960,
      longitude: 68.3578,
      defaultCrop: 'Sugarcane',
      defaultSoil: 'Clay',
      climateZone: 'Arid southern basin',
      groundwaterStatus: 'Saline intrusion risk · Canal dependent',
    ),
    FarmLocation(
      id: 'sacramento_us',
      name: 'Sacramento, USA',
      region: 'Central Valley, California, USA',
      country: 'United States',
      latitude: 38.5816,
      longitude: -121.4944,
      defaultCrop: 'Rice',
      defaultSoil: 'Clay Loam',
      climateZone: 'Mediterranean · Seasonal drought',
      groundwaterStatus: 'Regulated SGMA groundwater basin',
    ),
    FarmLocation(
      id: 'des_moines_us',
      name: 'Des Moines, USA',
      region: 'Iowa Corn Belt, USA',
      country: 'United States',
      latitude: 41.5868,
      longitude: -93.6250,
      defaultCrop: 'Maize',
      defaultSoil: 'Silt Loam',
      climateZone: 'Humid continental · Rainfed',
      groundwaterStatus: 'Stable · Tile-drainage management',
    ),
    FarmLocation(
      id: 'nairobi_ke',
      name: 'Nairobi, Kenya',
      region: 'Rift Valley / Central Kenya',
      country: 'Kenya',
      latitude: -1.2921,
      longitude: 36.8219,
      defaultCrop: 'Maize',
      defaultSoil: 'Loam',
      climateZone: 'Highland tropical bimodal',
      groundwaterStatus: 'Rainfed vulnerability · Variable seasons',
    ),
    FarmLocation(
      id: 'sao_paulo_br',
      name: 'São Paulo, Brazil',
      region: 'Cerrado / Southeast Brazil',
      country: 'Brazil',
      latitude: -23.5505,
      longitude: -46.6333,
      defaultCrop: 'Soybean',
      defaultSoil: 'Clay Loam (Oxisol)',
      climateZone: 'Tropical wet/dry',
      groundwaterStatus: 'High seasonal recharge',
    ),
    FarmLocation(
      id: 'punjab_in',
      name: 'Ludhiana, India',
      region: 'Punjab, India',
      country: 'India',
      latitude: 30.9010,
      longitude: 75.8573,
      defaultCrop: 'Wheat',
      defaultSoil: 'Loam',
      climateZone: 'Semi-arid Indo-Gangetic Plains',
      groundwaterStatus: 'Critical overdraft (GRACE negative anomaly)',
    ),
  ];
}

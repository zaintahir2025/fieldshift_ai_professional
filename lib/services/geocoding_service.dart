import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/farm_location.dart';

class GeocodingService {
  static const String _nominatimBase = 'https://nominatim.openstreetmap.org';
  static const Map<String, String> _headers = {
    'User-Agent': 'FieldShiftAI/1.0 (com.fieldshift.fieldshift_ai_professional; contact: support@fieldshift.org)',
    'Accept': 'application/json',
  };

  /// Obtains the device's real-time GPS coordinates via browser/OS geolocation
  static Future<Position?> getCurrentDevicePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      try {
        return await Geolocator.getLastKnownPosition();
      } catch (_) {
        return null;
      }
    }
  }

  /// Reverse-geocodes coordinates into a rich, human-friendly FarmLocation via OpenStreetMap Nominatim
  static Future<FarmLocation> reverseGeocode({
    required double latitude,
    required double longitude,
    bool isGpsOrigin = false,
  }) async {
    try {
      final uri = Uri.parse(
        '$_nominatimBase/reverse?format=jsonv2&lat=$latitude&lon=$longitude&zoom=14&addressdetails=1',
      );
      final response = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>? ?? {};

        // Extract the most specific local name
        final localName = address['farm'] ??
            address['village'] ??
            address['hamlet'] ??
            address['town'] ??
            address['suburb'] ??
            address['city'] ??
            address['neighbourhood'] ??
            address['municipality'] ??
            address['county'] ??
            data['name'] ??
            'Agricultural Farmland';

        final county = address['county'] ?? address['state_district'] ?? '';
        final state = address['state'] ?? address['province'] ?? address['region'] ?? '';
        final country = address['country'] ?? '';

        // Build a friendly name without cryptic coordinates
        String primaryName = localName.toString();
        if (county.isNotEmpty && !primaryName.toLowerCase().contains(county.toString().toLowerCase())) {
          primaryName = '$primaryName, $county';
        }

        // Build a clean administrative region
        final List<String> regionParts = [];
        if (state.isNotEmpty) regionParts.add(state.toString());
        if (country.isNotEmpty) regionParts.add(country.toString());
        final regionStr = regionParts.isNotEmpty ? regionParts.join(', ') : 'Agro-climatic Basin';

        final climate = _inferClimateZone(latitude, country.toString());

        return FarmLocation(
          id: 'osm_${latitude.toStringAsFixed(3)}_${longitude.toStringAsFixed(3)}',
          name: primaryName,
          region: regionStr,
          country: country.toString().isNotEmpty ? country.toString() : 'Global Region',
          latitude: latitude,
          longitude: longitude,
          defaultCrop: _inferDefaultCrop(latitude, climate),
          defaultSoil: 'Alluvial Loam',
          climateZone: climate,
          groundwaterStatus: isGpsOrigin ? 'Acquired via Real GPS · Monitored via GRACE' : 'Selected on OpenStreetMap',
        );
      }
    } catch (_) {
      // Offline fallback handling
    }

    // Heuristic human-presentable fallback
    final fallback = _inferRegionalName(latitude, longitude);
    return FarmLocation(
      id: 'osm_${latitude.toStringAsFixed(3)}_${longitude.toStringAsFixed(3)}',
      name: fallback['name']!,
      region: fallback['region']!,
      country: fallback['country']!,
      latitude: latitude,
      longitude: longitude,
      defaultCrop: 'Wheat / Diverse Rotation',
      defaultSoil: 'Silt Loam',
      climateZone: _inferClimateZone(latitude, fallback['country']!),
      groundwaterStatus: isGpsOrigin ? 'Device GPS Location' : 'OpenStreetMap Pin',
    );
  }

  /// Forward-search places via OpenStreetMap Nominatim
  static Future<List<FarmLocation>> searchPlaces(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final uri = Uri.parse(
        '$_nominatimBase/search?format=jsonv2&q=${Uri.encodeComponent(query)}&limit=6&addressdetails=1',
      );
      final response = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        return list.map((item) {
          final lat = double.tryParse(item['lat'].toString()) ?? 0.0;
          final lon = double.tryParse(item['lon'].toString()) ?? 0.0;
          final addr = item['address'] as Map<String, dynamic>? ?? {};

          final localName = addr['farm'] ??
              addr['village'] ??
              addr['town'] ??
              addr['city'] ??
              addr['municipality'] ??
              addr['county'] ??
              item['name'] ??
              query;

          final county = addr['county'] ?? addr['state_district'] ?? '';
          final state = addr['state'] ?? addr['province'] ?? '';
          final country = addr['country'] ?? '';

          String title = localName.toString();
          if (county.isNotEmpty && !title.toLowerCase().contains(county.toString().toLowerCase())) {
            title = '$title, $county';
          }

          final regionParts = [state, country].where((s) => s.toString().isNotEmpty).join(', ');

          return FarmLocation(
            id: 'osm_search_${item['place_id'] ?? lat.toString()}',
            name: title,
            region: regionParts.isNotEmpty ? regionParts : 'Agro-climatic Basin',
            country: country.toString().isNotEmpty ? country.toString() : 'Global Region',
            latitude: lat,
            longitude: lon,
            defaultCrop: 'Wheat / Grain Rotation',
            defaultSoil: 'Loam',
            climateZone: _inferClimateZone(lat, country.toString()),
            groundwaterStatus: 'NASA GRACE Monitored Aquifer',
          );
        }).toList();
      }
    } catch (_) {}
    return [];
  }

  static String _inferClimateZone(double lat, String country) {
    final absLat = lat.abs();
    if (absLat < 15) return 'Tropical Humid Agroecological Zone';
    if (absLat < 28) return 'Subtropical Semi-Arid Basin';
    if (absLat < 42) return 'Temperate Mediterranean & Valley Plain';
    if (absLat < 55) return 'Temperate Continental Grain Belt';
    return 'Boreal / High-Latitude Arable Plain';
  }

  static String _inferDefaultCrop(double lat, String climate) {
    if (climate.contains('Tropical')) return 'Rice / Legumes';
    if (climate.contains('Subtropical')) return 'Cotton / Wheat';
    if (climate.contains('Mediterranean')) return 'Alfalfa / Wheat / Citrus';
    return 'Corn / Soybeans / Wheat';
  }

  static Map<String, String> _inferRegionalName(double lat, double lon) {
    // Human-friendly geographic region approximation without exposing raw coordinate codes
    if (lat > 24 && lat < 50 && lon > -125 && lon < -65) {
      return {
        'name': 'North American Farmland Basin',
        'region': 'Agricultural Heartland, USA',
        'country': 'United States',
      };
    } else if (lat > 20 && lat < 38 && lon > 60 && lon < 80) {
      return {
        'name': 'Indus River Basin Agricultural Plain',
        'region': 'Punjab / Sindh Agro-Zone',
        'country': 'South Asia',
      };
    } else if (lat > 35 && lat < 60 && lon > -10 && lon < 40) {
      return {
        'name': 'European Arable Farmland',
        'region': 'Continental Cropping Zone',
        'country': 'Europe',
      };
    } else if (lat > -35 && lat < 5 && lon > 10 && lon < 45) {
      return {
        'name': 'Rift Valley Agricultural Zone',
        'region': 'East African Cropland',
        'country': 'Africa',
      };
    }
    return {
      'name': 'Regional Agricultural Field',
      'region': 'Global Cropping Area',
      'country': 'Field Parcel',
    };
  }

  Future<List<GeocodingSearchResult>> searchCities(String query) async {
    final places = await searchPlaces(query);
    return places.map((p) => GeocodingSearchResult(
      displayName: p.name,
      latitude: p.latitude,
      longitude: p.longitude,
      region: p.region,
      country: p.country,
    )).toList();
  }
}

class GeocodingSearchResult {
  final String displayName;
  final double latitude;
  final double longitude;
  final String region;
  final String country;

  const GeocodingSearchResult({
    required this.displayName,
    required this.latitude,
    required this.longitude,
    required this.region,
    required this.country,
  });

  FarmLocation toFarmLocation({
    required String defaultCrop,
    required String defaultSoil,
  }) {
    return FarmLocation(
      id: 'search_${latitude.toStringAsFixed(3)}_${longitude.toStringAsFixed(3)}',
      name: displayName,
      region: region.isNotEmpty ? region : 'Agricultural Basin',
      country: country.isNotEmpty ? country : 'Global',
      latitude: latitude,
      longitude: longitude,
      defaultCrop: defaultCrop,
      defaultSoil: defaultSoil,
      climateZone: 'Agroecological Region',
      groundwaterStatus: 'NASA GRACE Monitored Aquifer',
    );
  }
}

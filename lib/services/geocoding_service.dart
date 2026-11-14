import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/farm_location.dart';

class GeocodingSearchResult {
  final String name;
  final String country;
  final String? admin1;
  final double latitude;
  final double longitude;

  const GeocodingSearchResult({
    required this.name,
    required this.country,
    this.admin1,
    required this.latitude,
    required this.longitude,
  });

  String get displayName {
    final parts = [name, admin1, country].where((s) => s != null && s.isNotEmpty).toList();
    return parts.join(', ');
  }

  FarmLocation toFarmLocation({String defaultCrop = 'Wheat', String defaultSoil = 'Loam'}) {
    return FarmLocation(
      id: 'custom_${latitude.toStringAsFixed(2)}_${longitude.toStringAsFixed(2)}',
      name: displayName,
      region: [admin1, country].whereType<String>().join(', '),
      country: country,
      latitude: latitude,
      longitude: longitude,
      defaultCrop: defaultCrop,
      defaultSoil: defaultSoil,
      climateZone: 'Custom Location',
      groundwaterStatus: 'Regional Aquifer Check Recommended',
    );
  }
}

class GeocodingService {
  static const String _endpoint = 'https://geocoding-api.open-meteo.com/v1/search';

  Future<List<GeocodingSearchResult>> searchCities(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.length < 2) return [];

    try {
      final uri = Uri.parse('$_endpoint?name=${Uri.encodeComponent(cleanQuery)}&count=15&language=en&format=json');
      final res = await http.get(uri).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>? ?? [];

        return results.map((item) {
          final map = item as Map<String, dynamic>;
          return GeocodingSearchResult(
            name: map['name'] as String? ?? '',
            country: map['country'] as String? ?? '',
            admin1: map['admin1'] as String?,
            latitude: (map['latitude'] as num).toDouble(),
            longitude: (map['longitude'] as num).toDouble(),
          );
        }).where((r) => r.latitude.abs() <= 84.66).toList(); // SMAP & NASA POWER latitude boundary
      }
    } catch (_) {
      // Fallback to searching preset locations offline
    }

    // Filter preset locations
    final qLower = cleanQuery.toLowerCase();
    return FarmLocation.presetLocations
        .where((loc) =>
            loc.name.toLowerCase().contains(qLower) ||
            loc.region.toLowerCase().contains(qLower) ||
            loc.country.toLowerCase().contains(qLower))
        .map((loc) => GeocodingSearchResult(
              name: loc.name,
              country: loc.country,
              admin1: loc.region,
              latitude: loc.latitude,
              longitude: loc.longitude,
            ))
        .toList();
  }
}

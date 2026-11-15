import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fieldshift_ai_professional/main.dart';
import 'package:fieldshift_ai_professional/models/app_user.dart';
import 'package:fieldshift_ai_professional/models/farmer_constraints.dart';
import 'package:fieldshift_ai_professional/models/nasa_observation.dart';
import 'package:fieldshift_ai_professional/models/climate_scenario.dart';
import 'package:fieldshift_ai_professional/providers/auth_provider.dart';
import 'package:fieldshift_ai_professional/services/rotation_engine.dart';
import 'package:fieldshift_ai_professional/services/climate_risk_engine.dart';
import 'package:fieldshift_ai_professional/services/localization_service.dart';
import 'package:fieldshift_ai_professional/views/auth/login_view.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  final sampleWeather = AgroClimateSummary(
    meanTemp: 24.5,
    maxTemp: 34.0,
    minTemp: 15.0,
    meanRainfall: 1.2,
    totalRainfall: 36.0,
    dryDaysCount: 22,
    meanSolar: 18.5,
    meanSurfaceMoisture: 0.20,
    meanRootZoneMoisture: 0.22,
    observationDays: 30,
    isLiveNasaData: false,
    fetchTimestamp: DateTime.now(),
  );

  group('Rotation Engine Tests', () {
    test('Generates at least 3 comparative rotation strategies including baseline', () {
      final strategies = RotationEngine.generateStrategies(
        currentCrop: 'Wheat',
        soilTexture: 'Loam',
        constraints: const FarmerConstraints(priority: FarmerPriority.soilHealth),
        weather: sampleWeather,
      );

      expect(strategies.length, greaterThanOrEqualTo(3));
      expect(strategies.any((s) => s.isBaseline), isTrue);

      final baseline = strategies.firstWhere((s) => s.isBaseline);
      expect(baseline.bareFieldDaysPerYear, greaterThan(60));

      final legume = strategies.firstWhere((s) => s.id == 'regenerative_legume');
      expect(legume.nitrogenBalanceKgPerHa, greaterThan(0));
      expect(legume.bareFieldDaysPerYear, lessThan(30));
    });

    test('Regional Strategy Engine tailors rotations for US Corn Belt and California', () {
      final iowaWeather = AgroClimateSummary(
        meanTemp: 18.0,
        maxTemp: 28.0,
        minTemp: 8.0,
        meanRainfall: 2.8,
        totalRainfall: 84.0,
        dryDaysCount: 12,
        meanSolar: 19.0,
        latitude: 41.5868,
        longitude: -93.6250, // Iowa
        observationDays: 30,
        isLiveNasaData: true,
        fetchTimestamp: DateTime.now(),
      );

      final iowaStrategies = RotationEngine.generateStrategies(
        currentCrop: 'Maize',
        soilTexture: 'Silt Loam',
        constraints: const FarmerConstraints(priority: FarmerPriority.soilHealth),
        weather: iowaWeather,
      );

      final legumeStrategy = iowaStrategies.firstWhere((s) => s.id == 'regenerative_legume');
      expect(legumeStrategy.title, contains('Corn-Rye-Soybean-Clover'));
      expect(legumeStrategy.steps.any((s) => s.cropName.contains('Cereal Rye')), isTrue);
    });

    test('Custom Sequence Evaluation accurately computes nitrogen, water, and soil metrics', () {
      final custom = RotationEngine.evaluateCustomSequence(
        cropNames: ['Wheat', 'Mung bean', 'Chickpea'],
        constraints: const FarmerConstraints(priority: FarmerPriority.soilHealth),
        weather: sampleWeather,
      );

      expect(custom.nitrogenBalanceKgPerHa, isNotNull);
      expect(custom.overallScore, greaterThan(60));
      expect(custom.bareFieldDaysPerYear, lessThan(120));
      expect(custom.steps.length, equals(3));
    });

    test('Climate Scenario adjustment dynamically changes risk and strategy scores', () {
      final baselineRisk = ClimateRiskEngine.evaluateRisk(
        summary: sampleWeather,
        scenario: const ClimateScenario(),
      );

      final stressedRisk = ClimateRiskEngine.evaluateRisk(
        summary: sampleWeather,
        scenario: const ClimateScenario(temperatureAnomalyC: 3.0, rainfallAnomalyPercent: -30.0),
      );

      expect(stressedRisk.heatExposureScore, greaterThan(baselineRisk.heatExposureScore));
      expect(stressedRisk.overallSuitabilityScore, lessThanOrEqualTo(baselineRisk.overallSuitabilityScore));
    });
  });

  group('Localization Engine Tests', () {
    test('Supports English, Urdu, Hindi, Spanish, and Swahili translations', () {
      expect(LocalizationService.supportedLanguages.containsKey('en'), isTrue);
      expect(LocalizationService.supportedLanguages.containsKey('ur'), isTrue);
      expect(LocalizationService.supportedLanguages.containsKey('hi'), isTrue);
      expect(LocalizationService.supportedLanguages.containsKey('es'), isTrue);
      expect(LocalizationService.supportedLanguages.containsKey('sw'), isTrue);

      expect(AppLocale.get('app_title', 'en'), 'FIELDSHIFT AI');
      expect(AppLocale.get('app_title', 'ur'), contains('فیلڈ شفٹ'));
      expect(AppLocale.get('app_title', 'hi'), contains('फील्डशिफ्ट'));
      expect(AppLocale.get('overview', 'es'), contains('Resumen'));
      expect(AppLocale.get('overview', 'sw'), contains('Muhtasari'));
    });
  });

  group('Authentication Architecture Tests', () {
    test('AppUser model handles guest instantiation and JSON roundtrip', () {
      final guest = AppUser.guest();
      expect(guest.isAnonymous, isTrue);
      expect(guest.displayName, contains('Guest'));

      final registered = AppUser(
        uid: 'user_test_123',
        email: 'farmer@test.com',
        displayName: 'John Doe',
        farmName: 'Sunset Valley',
        isAnonymous: false,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      final map = registered.toMap();
      final roundtrip = AppUser.fromMap(map);
      expect(roundtrip.uid, equals('user_test_123'));
      expect(roundtrip.email, equals('farmer@test.com'));
      expect(roundtrip.farmName, equals('Sunset Valley'));
      expect(roundtrip.isAnonymous, isFalse);
    });

    test('AuthProvider supports guest session and logout lifecycle', () async {
      final auth = AuthProvider();
      expect(auth.isAuthenticated, isFalse);

      final success = await auth.loginAsGuest();
      expect(success, isTrue);
      expect(auth.isAuthenticated, isTrue);
      expect(auth.isGuest, isTrue);

      await auth.logout();
      expect(auth.isAuthenticated, isFalse);
      expect(auth.currentUser, isNull);
    });
  });

  group('Widget Smoke Test', () {
    testWidgets('FieldShiftApp builds and displays login / workspace interface', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const FieldShiftApp());
      await tester.pumpAndSettle();

      expect(find.byType(FieldShiftApp), findsOneWidget);
      expect(find.byType(LoginView), findsOneWidget);
      expect(find.text('Sign In to Farm Workspace'), findsOneWidget);
      expect(find.text('Explore Demo in Field Guest Mode'), findsOneWidget);
    });
  });
}

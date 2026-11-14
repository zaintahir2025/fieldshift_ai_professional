import 'dart:math';
import '../models/nasa_observation.dart';
import '../models/climate_scenario.dart';

class FarmRiskScore {
  final int overallSuitabilityScore; // 0-100
  final int heatExposureScore; // 0-100
  final int droughtDeficitScore; // 0-100
  final int solarScore; // 0-100
  final String statusLabel; // Favorable, Watch, High Stress
  final List<String> contributingFactors;

  const FarmRiskScore({
    required this.overallSuitabilityScore,
    required this.heatExposureScore,
    required this.droughtDeficitScore,
    required this.solarScore,
    required this.statusLabel,
    required this.contributingFactors,
  });
}

class PredictiveOutlook {
  final double projectedMeanTemp;
  final double projected7DayRain;
  final double recentRainTotal;
  final int dryDays;
  final int heatRisk;
  final int dryRisk;
  final int combinedRisk;
  final String riskLevel; // Lower, Moderate, High
  final String confidence;
  final int observationCount;
  final String direction;
  final double dailyTempSlope;

  const PredictiveOutlook({
    required this.projectedMeanTemp,
    required this.projected7DayRain,
    required this.recentRainTotal,
    required this.dryDays,
    required this.heatRisk,
    required this.dryRisk,
    required this.combinedRisk,
    required this.riskLevel,
    required this.confidence,
    required this.observationCount,
    required this.direction,
    required this.dailyTempSlope,
  });
}

class CropAssessmentResult {
  final String stressPrediction; // Low stress, Moderate stress, High stress
  final int stressScore; // 0-100
  final int suitabilityIndex; // 0-100
  final String suitabilityCategory; // More suitable, Mixed / monitor, Less suitable
  final List<String> reasons;
  final String moistureSource;
  final String ndviSource;

  const CropAssessmentResult({
    required this.stressPrediction,
    required this.stressScore,
    required this.suitabilityIndex,
    required this.suitabilityCategory,
    required this.reasons,
    required this.moistureSource,
    required this.ndviSource,
  });
}

class ClimateRiskEngine {
  /// Computes retrospective agroclimatic risk scores (0-100)
  static FarmRiskScore evaluateRisk({
    required AgroClimateSummary summary,
    ClimateScenario scenario = const ClimateScenario(),
  }) {
    final effectiveTemp = summary.meanTemp + scenario.temperatureAnomalyC;
    final effectiveRain = max(0.0, summary.meanRainfall * (1.0 + scenario.rainfallAnomalyPercent / 100.0));

    final heat = max(0.0, min(100.0, (effectiveTemp - 18.0) * 5.0));
    final dry = max(0.0, min(100.0, 65.0 - effectiveRain * 2.2));
    final solarScore = max(0.0, min(100.0, summary.meanSolar / 0.25));

    final overall = max(0.0, min(100.0, 100.0 - heat * 0.45 - dry * 0.55)).round();

    final factors = <String>[];
    if (heat > 50) factors.add('Elevated mean air temperatures (${effectiveTemp.toStringAsFixed(1)}°C)');
    if (dry > 50) factors.add('Limited precipitation (${effectiveRain.toStringAsFixed(1)} mm/day)');
    if (summary.meanRootZoneMoisture != null && summary.meanRootZoneMoisture! < 0.18) {
      factors.add('Low SMAP root-zone soil moisture (${summary.meanRootZoneMoisture!.toStringAsFixed(2)} m³/m³)');
    }
    if (factors.isEmpty) factors.add('Balanced climate conditions detected in observation window');

    final status = overall >= 70
        ? 'Favorable'
        : (overall >= 45 ? 'Watch / Mixed' : 'High Stress');

    return FarmRiskScore(
      overallSuitabilityScore: overall,
      heatExposureScore: heat.round(),
      droughtDeficitScore: dry.round(),
      solarScore: solarScore.round(),
      statusLabel: status,
      contributingFactors: factors,
    );
  }

  /// Linear trend extrapolation from up to 14 recent daily observations
  static PredictiveOutlook? computePredictiveOutlook(List<DailyObservation> rows, String cropName) {
    final recent = rows.length > 14 ? rows.sublist(rows.length - 14) : rows;
    if (recent.length < 7) return null;

    final temps = recent.map((r) => r.tempMean).whereType<double>().toList();
    final rains = recent.map((r) => r.rainfall).whereType<double>().toList();
    if (temps.length < 7 || rains.length < 7) return null;

    final n = temps.length;
    final xMean = (n - 1) / 2.0;
    final yMean = temps.reduce((a, b) => a + b) / n;

    double numerator = 0.0;
    double denominator = 0.0;
    for (int i = 0; i < n; i++) {
      final xDiff = i - xMean;
      final yDiff = temps[i] - yMean;
      numerator += xDiff * yDiff;
      denominator += xDiff * xDiff;
    }

    final dailyTempSlope = denominator != 0 ? numerator / denominator : 0.0;
    final lastTemp = temps.last;
    final projectedMeanTemp = lastTemp + dailyTempSlope * 4.0;
    final recentRainTotal = rains.reduce((a, b) => a + b);
    final projected7DayRain = (recentRainTotal / rains.length) * 7.0;
    final dryDays = rains.where((v) => v < 1.0).length;

    const heatThresholds = {'Wheat': 30.0, 'Rice': 35.0, 'Cotton': 35.0, 'Maize': 32.0, 'Sugarcane': 35.0, 'Chickpea': 30.0};
    final threshold = heatThresholds[cropName] ?? 32.0;

    final heatRisk = max(0.0, min(100.0, ((projectedMeanTemp - (threshold - 5.0)) * 10.0))).round();
    final dryRisk = max(0.0, min(100.0, (dryDays / rains.length) * 65.0 + max(0.0, 14.0 - recentRainTotal) * 2.5)).round();
    final combined = (heatRisk * 0.55 + dryRisk * 0.45).round();

    final level = combined >= 70 ? 'High' : (combined >= 40 ? 'Moderate' : 'Lower');
    final confidence = recent.length >= 14 ? 'Low · Trend-only (14 days)' : 'Very low · Limited history';
    final direction = dailyTempSlope > 0.15
        ? 'Warming trend (+${dailyTempSlope.toStringAsFixed(2)}°C/day)'
        : (dailyTempSlope < -0.15
            ? 'Cooling trend (${dailyTempSlope.toStringAsFixed(2)}°C/day)'
            : 'Temperature trend stable');

    return PredictiveOutlook(
      projectedMeanTemp: projectedMeanTemp,
      projected7DayRain: projected7DayRain,
      recentRainTotal: recentRainTotal,
      dryDays: dryDays,
      heatRisk: heatRisk,
      dryRisk: dryRisk,
      combinedRisk: combined,
      riskLevel: level,
      confidence: confidence,
      observationCount: recent.length,
      direction: direction,
      dailyTempSlope: dailyTempSlope,
    );
  }

  /// Transparent rule-based crop stress and suitability screening
  static CropAssessmentResult assessCropConditions({
    required AgroClimateSummary weather,
    required String crop,
    double? manualSoilMoisture,
    double? manualNdvi,
    double? manualNdviChange,
    ClimateScenario scenario = const ClimateScenario(),
  }) {
    final effectiveMaxTemp = weather.maxTemp + scenario.temperatureAnomalyC;
    final effectiveRain = max(0.0, weather.totalRainfall * (1.0 + scenario.rainfallAnomalyPercent / 100.0));

    final moisture = manualSoilMoisture ?? weather.meanRootZoneMoisture;
    final moistureSource = manualSoilMoisture != null
        ? 'Manually entered in-situ probe measurement'
        : (weather.meanRootZoneMoisture != null
            ? 'NASA SMAP L4 root-zone satellite estimate'
            : 'No moisture input available');

    final ndvi = manualNdvi;
    final ndviDelta = manualNdviChange;
    final ndviSource = ndvi != null ? 'User entered field measurement' : 'Not supplied';

    const heatThresholds = {
      'wheat': 30.0,
      'rice': 35.0,
      'cotton': 35.0,
      'maize': 32.0,
      'sugarcane': 35.0,
      'chickpea': 30.0,
      'mung bean': 32.0,
      'mustard': 28.0,
      'sorghum': 38.0,
    };
    final threshold = heatThresholds[crop.toLowerCase()] ?? 32.0;

    int stress = 0;
    final reasons = <String>[];

    if (effectiveMaxTemp >= threshold) {
      stress += 35;
      reasons.add('Maximum temperature (${effectiveMaxTemp.toStringAsFixed(1)}°C) exceeds the $crop tolerance threshold (${threshold.toInt()}°C)');
    } else if (effectiveMaxTemp >= threshold - 4.0) {
      stress += 18;
      reasons.add('Maximum temperature (${effectiveMaxTemp.toStringAsFixed(1)}°C) is approaching the crop heat threshold');
    }

    if (effectiveRain < 10.0) {
      stress += 25;
      reasons.add('Low rainfall (${effectiveRain.toStringAsFixed(1)} mm) during observation period');
    } else if (effectiveRain < 30.0) {
      stress += 12;
      reasons.add('Limited precipitation (${effectiveRain.toStringAsFixed(1)} mm) observed');
    }

    if (moisture != null) {
      if (moisture < 0.15) {
        stress += 25;
        reasons.add('Root-zone soil moisture (${moisture.toStringAsFixed(2)} m³/m³) is below critical wilting threshold');
      } else if (moisture < 0.25) {
        stress += 12;
        reasons.add('Root-zone soil moisture (${moisture.toStringAsFixed(2)} m³/m³) is relatively low');
      }
    }

    if (ndvi != null && ndvi < 0.3) {
      stress += 15;
      reasons.add('Low vegetative index (NDVI: ${ndvi.toStringAsFixed(2)}) suggests canopy stress or sparse emergence');
    }
    if (ndviDelta != null && ndviDelta < -0.1) {
      stress += 10;
      reasons.add('Negative NDVI trend indicates canopy vigor decline');
    }

    stress = min(100, stress);
    final level = stress >= 60 ? 'High stress' : (stress >= 30 ? 'Moderate stress' : 'Low stress');
    final suitability = max(0, 100 - stress);
    final suitabilityCategory = suitability >= 70
        ? 'More suitable conditions'
        : (suitability >= 45 ? 'Mixed / monitor conditions' : 'Less suitable conditions');

    return CropAssessmentResult(
      stressPrediction: level,
      stressScore: stress,
      suitabilityIndex: suitability,
      suitabilityCategory: suitabilityCategory,
      reasons: reasons.isNotEmpty ? reasons : ['No severe agroclimatic stress signals detected in current window'],
      moistureSource: moistureSource,
      ndviSource: ndviSource,
    );
  }
}

class ClimateScenario {
  final double temperatureAnomalyC; // 0.0 to +4.0°C
  final double rainfallAnomalyPercent; // -40% to +40%
  final int additionalHeatWaveDays; // 0 to 18 days
  final int extendedDrySpellDays; // 0 to 14 days

  const ClimateScenario({
    this.temperatureAnomalyC = 0.0,
    this.rainfallAnomalyPercent = 0.0,
    this.additionalHeatWaveDays = 0,
    this.extendedDrySpellDays = 0,
  });

  bool get isBaseline =>
      temperatureAnomalyC == 0.0 &&
      rainfallAnomalyPercent == 0.0 &&
      additionalHeatWaveDays == 0 &&
      extendedDrySpellDays == 0;

  ClimateScenario copyWith({
    double? temperatureAnomalyC,
    double? rainfallAnomalyPercent,
    int? additionalHeatWaveDays,
    int? extendedDrySpellDays,
  }) {
    return ClimateScenario(
      temperatureAnomalyC: temperatureAnomalyC ?? this.temperatureAnomalyC,
      rainfallAnomalyPercent: rainfallAnomalyPercent ?? this.rainfallAnomalyPercent,
      additionalHeatWaveDays: additionalHeatWaveDays ?? this.additionalHeatWaveDays,
      extendedDrySpellDays: extendedDrySpellDays ?? this.extendedDrySpellDays,
    );
  }
}

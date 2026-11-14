import 'package:flutter/material.dart';
import '../models/climate_scenario.dart';
import '../theme/app_theme.dart';

class ScenarioSliderWidget extends StatelessWidget {
  final ClimateScenario scenario;
  final ValueChanged<ClimateScenario> onScenarioChanged;
  final VoidCallback onReset;

  const ScenarioSliderWidget({
    super.key,
    required this.scenario,
    required this.onScenarioChanged,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final hasChanges = !scenario.isBaseline;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasChanges ? const Color(0xFFF4A261) : AppColors.borderLight,
          width: hasChanges ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4A261).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.tune, color: Color(0xFFE76F51), size: 18),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'CLIMATE "WHAT-IF" SCENARIO SIMULATOR',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: Color(0xFFE76F51)),
                  ),
                ],
              ),
              if (hasChanges)
                TextButton.icon(
                  onPressed: onReset,
                  icon: const Icon(Icons.refresh, size: 14),
                  label: const Text('Reset Baseline', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFE76F51),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Simulate future climate shifts or extreme seasons. The crop rotation scoring and vulnerability models update instantly to test resilience.',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.35),
          ),
          const SizedBox(height: 16),

          // Temperature Anomaly Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.thermostat, size: 16, color: AppColors.warningAmber),
                  SizedBox(width: 6),
                  Text(
                    'Temperature Anomaly Shift:',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textDark),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: scenario.temperatureAnomalyC > 0 ? const Color(0xFFFFF3E0) : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: scenario.temperatureAnomalyC > 0 ? AppColors.warningAmber : AppColors.borderLight),
                ),
                child: Text(
                  '+${scenario.temperatureAnomalyC.toStringAsFixed(1)}°C',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: scenario.temperatureAnomalyC > 0 ? AppColors.warningAmber : AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.warningAmber,
              thumbColor: AppColors.warningAmber,
              overlayColor: AppColors.warningAmber.withValues(alpha: 0.15),
              trackHeight: 4,
            ),
            child: Slider(
              value: scenario.temperatureAnomalyC,
              min: 0.0,
              max: 4.0,
              divisions: 8,
              label: '+${scenario.temperatureAnomalyC.toStringAsFixed(1)}°C',
              onChanged: (val) {
                onScenarioChanged(scenario.copyWith(temperatureAnomalyC: val));
              },
            ),
          ),

          // Rainfall Anomaly Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.cloud_outlined, size: 16, color: AppColors.waterBlue),
                  SizedBox(width: 6),
                  Text(
                    'Seasonal Rainfall Adjustment:',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textDark),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: scenario.rainfallAnomalyPercent != 0 ? const Color(0xFFE1F5FE) : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: scenario.rainfallAnomalyPercent != 0 ? AppColors.waterBlue : AppColors.borderLight),
                ),
                child: Text(
                  '${scenario.rainfallAnomalyPercent >= 0 ? "+" : ""}${scenario.rainfallAnomalyPercent.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: scenario.rainfallAnomalyPercent != 0 ? AppColors.waterBlue : AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.waterBlue,
              thumbColor: AppColors.waterBlue,
              overlayColor: AppColors.waterBlue.withValues(alpha: 0.15),
              trackHeight: 4,
            ),
            child: Slider(
              value: scenario.rainfallAnomalyPercent,
              min: -40.0,
              max: 40.0,
              divisions: 8,
              label: '${scenario.rainfallAnomalyPercent >= 0 ? "+" : ""}${scenario.rainfallAnomalyPercent.toStringAsFixed(0)}%',
              onChanged: (val) {
                onScenarioChanged(scenario.copyWith(rainfallAnomalyPercent: val));
              },
            ),
          ),

          if (hasChanges) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9C4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFF176)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 15, color: Color(0xFFF57F17)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Scenario active: Under +${scenario.temperatureAnomalyC.toStringAsFixed(1)}°C and ${scenario.rainfallAnomalyPercent.toStringAsFixed(0)}% rainfall, high-water rotations lose score while drought-tolerant legumes and C4 sorghum gain ranking precedence.',
                      style: const TextStyle(fontSize: 10.5, color: Color(0xFF5D4037), height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/farm_provider.dart';
import '../widgets/scenario_slider_widget.dart';
import '../theme/app_theme.dart';

class ScenarioSimulatorView extends StatelessWidget {
  const ScenarioSimulatorView({super.key});

  @override
  Widget build(BuildContext context) {
    final farm = context.watch<FarmProvider>();
    final sc = farm.scenario;
    final summary = farm.summary;

    final simHeatDays = ((summary?.heatStressDaysCount ?? 2) + (sc.temperatureAnomalyC * 3.8)).round();
    final simMoisture = ((summary?.meanRootZoneMoisture ?? 0.22) * (1.0 + sc.rainfallAnomalyPercent / 100.0)).clamp(0.04, 0.50);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                farm.tr('climate_simulator'),
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.primary),
              ),
              const SizedBox(height: 3),
              const Text(
                'What-If Climate Scenario Simulator',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Scenario Sliders
          ScenarioSliderWidget(
            scenario: sc,
            onScenarioChanged: (newSc) => farm.updateScenario(newSc),
            onReset: () => farm.resetScenario(),
          ),
          const SizedBox(height: 14),

          // Dynamic Impact Stat Bar
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Simulated Heat Stress Days', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSubtle)),
                      const SizedBox(height: 2),
                      Text(
                        '$simHeatDays days / season',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: simHeatDays > 8 ? AppColors.alertRed : AppColors.warningAmber,
                        ),
                      ),
                      Text('T_max ≥ 35°C (+${(sc.temperatureAnomalyC * 3.8).round()}d shift)', style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted)),
                    ],
                  ),
                ),
                Container(width: 1, height: 38, color: AppColors.borderLight),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Projected Root Wetness', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSubtle)),
                      const SizedBox(height: 2),
                      Text(
                        '${simMoisture.toStringAsFixed(3)} m³/m³',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: simMoisture < 0.16 ? AppColors.alertRed : AppColors.waterBlue,
                        ),
                      ),
                      Text('SMAP 0–100cm (${sc.rainfallAnomalyPercent >= 0 ? "+" : ""}${sc.rainfallAnomalyPercent.toStringAsFixed(0)}% rain)', style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Simulation Outcomes & Strategy Viability
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.assessment_outlined, size: 18, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'SIMULATED ROTATION VIABILITY UNDER CLIMATE STRESS',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'How each rotation strategy performs under the selected temperature and precipitation anomalies:',
                  style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                ),
                const SizedBox(height: 14),
                ...farm.strategies.map((strategy) {
                  final isBase = strategy.isBaseline;
                  // Dynamic vulnerability indicator based on scenario
                  final isAtRisk = isBase && (sc.temperatureAnomalyC >= 1.5 || sc.rainfallAnomalyPercent <= -15);
                  final isResilient = !isBase && (strategy.waterSavingsPercentage >= 25 || strategy.nitrogenBalanceKgPerHa > 30);

                  final statusColor = isAtRisk
                      ? AppColors.alertRed
                      : (isResilient ? AppColors.resilientGreen : AppColors.warningAmber);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: statusColor.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isAtRisk ? Icons.warning : (isResilient ? Icons.verified : Icons.help_outline),
                            color: statusColor,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                strategy.title,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isAtRisk
                                    ? 'High Vulnerability: Monoculture suffers severe heat shock and water exhaustion.'
                                    : (isResilient
                                        ? 'High Resilience: Water savings (+${strategy.waterSavingsPercentage.toStringAsFixed(0)}%) and deep taproots buffer drought.'
                                        : 'Moderate Resilience: Requires supplemental irrigation adjustment.'),
                                style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${strategy.overallScore}/100',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: statusColor),
                            ),
                            const Text('FIT SCORE', style: TextStyle(fontSize: 8, color: AppColors.textSubtle, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Actionable Agronomic Adaptation Prescriptions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8F4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFC7E2D1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.tips_and_updates_outlined, color: AppColors.primary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'FARMER ADAPTIVE INTERVENTIONS FOR THIS SCENARIO',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildAdaptiveItem(
                  'Advance Sowing Date by 10–14 Days:',
                  'Plant winter pulses earlier to ensure flowering and pod-fill occur before high spring temperatures trigger terminal heat abortion.',
                ),
                _buildAdaptiveItem(
                  'Retain 30% Stubble Mulch / Zero-Till:',
                  'Standing residue shields the topsoil from direct solar radiation, lowering surface temperatures by 5–8°C and cutting evaporation.',
                ),
                _buildAdaptiveItem(
                  'Switch to C4 Sorghum or Pearl Millet:',
                  'If rainfall deficits exceed -20%, replace water-intensive summer cereals with C4 crops that maintain photosynthesis up to 42°C.',
                ),
                _buildAdaptiveItem(
                  'Inoculate Pulses with Rhizobium Strains:',
                  'Biological nitrogen fixation continues during drought conditions where synthetic granular urea would remain unactivated in dry topsoil.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAdaptiveItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.arrow_right, color: AppColors.resilientGreen, size: 18),
          const SizedBox(width: 4),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 11.5, color: AppColors.textDark, height: 1.35),
                children: [
                  TextSpan(text: '$title ', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                  TextSpan(text: desc),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

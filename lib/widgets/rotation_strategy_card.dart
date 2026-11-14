import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/rotation_strategy.dart';
import '../providers/farm_provider.dart';
import '../theme/app_theme.dart';

class RotationStrategyCard extends StatefulWidget {
  final RotationStrategy strategy;
  final bool isSelected;
  final VoidCallback? onSelect;

  const RotationStrategyCard({
    super.key,
    required this.strategy,
    this.isSelected = false,
    this.onSelect,
  });

  @override
  State<RotationStrategyCard> createState() => _RotationStrategyCardState();
}

class _RotationStrategyCardState extends State<RotationStrategyCard> {
  bool _expanded = false;

  void _showCropDetails(BuildContext context, RotationCropStep step) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryMuted,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  step.isBareFallow ? Icons.terrain_outlined : Icons.eco,
                  color: step.isBareFallow ? AppColors.alertRed : AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.cropName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${step.category} · ${step.seasonName}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildModalDetailRow('Growing Window', step.monthWindow, Icons.calendar_today_outlined),
                _buildModalDetailRow('Rooting Depth', '${step.rootingDepthCm} cm profile', Icons.straighten_outlined),
                _buildModalDetailRow('Seasonal Water Demand', '${step.waterDemandMm} mm', Icons.water_drop_outlined),
                _buildModalDetailRow('Primary Agronomic Benefit', step.primaryBenefit, Icons.verified_outlined),
                _buildModalDetailRow('Pest & Disease Break', step.pestDisruptionMechanism, Icons.pest_control_outlined),
                _buildModalDetailRow('Soil Biomass Impact', step.biomassContribution, Icons.layers_outlined),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildModalDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSubtle)),
                const SizedBox(height: 1),
                Text(value, style: const TextStyle(fontSize: 12, color: AppColors.textDark, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final farm = context.watch<FarmProvider>();
    final isSimple = farm.isSimpleFarmerMode;
    final s = widget.strategy;
    final isBase = s.isBaseline;
    final badgeColor = isBase
        ? AppColors.textMuted
        : (s.overallScore >= 85 ? AppColors.resilientGreen : AppColors.primaryLight);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isSelected
              ? AppColors.primary
              : (isBase ? AppColors.borderLight : const Color(0xFFC7E2D1)),
          width: widget.isSelected ? 2.2 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.isSelected
                ? AppColors.primary.withValues(alpha: 0.10)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row with Tag and Score
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          s.tag,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: badgeColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        s.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        s.subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: badgeColor.withValues(alpha: 0.25)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${s.overallScore}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: badgeColor,
                        ),
                      ),
                      const Text(
                        'FIT SCORE',
                        style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.textSubtle),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 12-Month Gantt Bar Timeline
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '12-MONTH CANOPY & ROTATION TIMELINE:',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5, color: AppColors.textSubtle),
                ),
                Text(
                  'Tap any crop for details',
                  style: TextStyle(fontSize: 9.5, color: AppColors.primary, fontStyle: FontStyle.italic),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _build12MonthGanttBar(s),
            const SizedBox(height: 10),

            // Sequence Step Chips / List
            _buildSequenceFlow(s.steps),
            const SizedBox(height: 14),

            // Key Agricultural Metric Pills
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetricItem(
                    label: isSimple ? 'Water Impact' : 'Water Shift',
                    value: s.waterSavingsPercentage >= 0
                        ? '+${s.waterSavingsPercentage.toStringAsFixed(0)}% saved'
                        : '${s.waterSavingsPercentage.toStringAsFixed(0)}% extra',
                    color: s.waterSavingsPercentage >= 20 ? AppColors.waterBlue : AppColors.textMuted,
                    icon: Icons.water_drop_outlined,
                  ),
                  _buildMetricItem(
                    label: isSimple ? 'Natural Fertilizer' : 'N₂ Fixation',
                    value: s.nitrogenBalanceKgPerHa >= 0
                        ? '+${s.nitrogenBalanceKgPerHa.toStringAsFixed(0)} kg/ha'
                        : '${s.nitrogenBalanceKgPerHa.toStringAsFixed(0)} kg/ha',
                    color: s.nitrogenBalanceKgPerHa > 0 ? AppColors.resilientGreen : AppColors.alertRed,
                    icon: Icons.eco_outlined,
                  ),
                  _buildMetricItem(
                    label: isSimple ? 'Bare Soil Risk' : 'Bare Soil Gap',
                    value: '${s.bareFieldDaysPerYear} days/yr',
                    color: s.bareFieldDaysPerYear <= 25 ? AppColors.resilientGreen : AppColors.warningAmber,
                    icon: Icons.terrain_outlined,
                  ),
                  _buildMetricItem(
                    label: 'Pest Break',
                    value: '${s.pestBreakRating}/5 stars',
                    color: s.pestBreakRating >= 4 ? AppColors.resilientGreen : AppColors.textMuted,
                    icon: Icons.pest_control_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Why Suggested
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FBF8),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFD4E8DA)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isSimple ? 'Why This Rotation Works for Your Farm:' : 'Why Suggested by Agroclimatology Model:',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          s.whySuggested,
                          style: const TextStyle(fontSize: 11.5, color: AppColors.textDark, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Evidence Pills (NASA Earth Observations)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: s.evidenceSupported.map((ev) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF5F0),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFCFE4D6)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.satellite_alt_outlined, size: 13, color: AppColors.primaryLight),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          ev,
                          style: const TextStyle(fontSize: 10.5, color: Color(0xFF264936), fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            // Expandable details (Benefits, Gaps, Risks, Vulnerability periods)
            if (_expanded) ...[
              const SizedBox(height: 16),
              const Divider(color: AppColors.borderLight),
              const SizedBox(height: 10),

              _buildSectionTitle('Agronomic Benefits & Soil Impacts:'),
              ...s.agronomicBenefits.map((b) => _buildBulletPoint(b, Icons.check_circle_outline, AppColors.resilientGreen)),

              const SizedBox(height: 12),
              _buildSectionTitle('Known Information Gaps:'),
              ...s.informationGaps.map((g) => _buildBulletPoint(g, Icons.help_outline, AppColors.warningAmber)),

              const SizedBox(height: 12),
              _buildSectionTitle('Risks Requiring Local Farmer / Extension Review:'),
              ...s.risksRequiringLocalReview.map((r) => _buildBulletPoint(r, Icons.warning_amber_rounded, AppColors.alertRed)),

              if (s.vulnerabilityPeriods.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildSectionTitle('Phenological Vulnerability Windows:'),
                ...s.vulnerabilityPeriods.map((v) => _buildVulnerabilityCard(v)),
              ],
            ],

            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () => setState(() => _expanded = !_expanded),
                  icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more, size: 16),
                  label: Text(_expanded ? 'Hide Deep Analysis' : 'Explore Evidence & Risks (${s.agronomicBenefits.length + s.risksRequiringLocalReview.length})'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
                if (widget.onSelect != null)
                  ElevatedButton.icon(
                    onPressed: widget.onSelect,
                    icon: Icon(widget.isSelected ? Icons.check : Icons.touch_app, size: 15),
                    label: Text(widget.isSelected ? 'Selected Strategy' : 'Select Strategy'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.isSelected ? AppColors.resilientGreen : AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _build12MonthGanttBar(RotationStrategy s) {
    const monthLetters = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 22,
            child: Row(
              children: List.generate(12, (i) {
                final monthNum = i + 1;
                RotationCropStep? activeStep;
                for (final step in s.steps) {
                  if (step.monthSpan.contains(monthNum)) {
                    activeStep = step;
                    break;
                  }
                }

                Color blockColor;
                if (activeStep == null || activeStep.isBareFallow) {
                  blockColor = const Color(0xFFEF9A9A); // Fallow bare soil
                } else if (activeStep.category.contains('Legume') || activeStep.category.contains('Pulse')) {
                  blockColor = const Color(0xFF2E86AB); // Nitrogen fixer
                } else if (activeStep.category.contains('Oilseed') || activeStep.category.contains('Cash')) {
                  blockColor = const Color(0xFFF4A261); // Oilseed/Cash
                } else if (activeStep.category.contains('Cover') || activeStep.category.contains('Forage')) {
                  blockColor = const Color(0xFF81C784); // Cover/Forage
                } else {
                  blockColor = const Color(0xFF2D6A4F); // Main cereal
                }

                return Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: blockColor,
                      border: Border(
                        right: BorderSide(
                          color: Colors.white.withValues(alpha: 0.6),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        monthLetters[i],
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildGanttLegendDot('Cereal', const Color(0xFF2D6A4F)),
            _buildGanttLegendDot('N₂ Legume', const Color(0xFF2E86AB)),
            _buildGanttLegendDot('Oilseed', const Color(0xFFF4A261)),
            _buildGanttLegendDot('Cover', const Color(0xFF81C784)),
            _buildGanttLegendDot('Bare Soil', const Color(0xFFEF9A9A)),
          ],
        ),
      ],
    );
  }

  Widget _buildGanttLegendDot(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 3),
        Text(label, style: const TextStyle(fontSize: 8.5, color: AppColors.textSubtle)),
      ],
    );
  }

  Widget _buildSequenceFlow(List<RotationCropStep> steps) {
    return Column(
      children: steps.map((step) {
        final isFallow = step.isBareFallow;
        final color = isFallow
            ? const Color(0xFF8D6E63)
            : (step.category.contains('Legume')
                ? AppColors.resilientGreen
                : (step.category.contains('Oilseed') ? AppColors.solarYellow : AppColors.primaryLight));

        return InkWell(
          onTap: () => _showCropDetails(context, step),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isFallow ? const Color(0xFFFBE9E7) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isFallow ? const Color(0xFFFFCCBC) : AppColors.borderLight,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            step.cropName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isFallow ? AppColors.alertRed : AppColors.textDark,
                            ),
                          ),
                          Text(
                            step.monthWindow,
                            style: const TextStyle(fontSize: 10.5, color: AppColors.textSubtle, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              step.primaryBenefit,
                              style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.info_outline, size: 12, color: AppColors.primaryLight),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMetricItem({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 9, color: AppColors.textSubtle),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textDark),
      ),
    );
  }

  Widget _buildBulletPoint(String text, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVulnerabilityCard(VulnerabilityPeriod v) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${v.crop} (${v.monthWindow})',
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFFE65100)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE65100),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  v.hazardType,
                  style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Hazard: ${v.impactMechanism}', style: const TextStyle(fontSize: 10.5, color: AppColors.textDark)),
          const SizedBox(height: 2),
          Text('Action: ${v.recommendedMitigation}', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF2E7D32))),
          const SizedBox(height: 2),
          Text('Source: ${v.nasaDataSource}', style: const TextStyle(fontSize: 9, color: AppColors.textSubtle, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}

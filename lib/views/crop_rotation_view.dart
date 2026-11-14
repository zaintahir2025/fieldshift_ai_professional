import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/farm_provider.dart';
import '../models/farmer_constraints.dart';
import '../models/nasa_observation.dart';
import '../models/rotation_strategy.dart';
import '../services/rotation_engine.dart';
import '../widgets/rotation_strategy_card.dart';
import '../theme/app_theme.dart';

enum StrategySortOrder {
  byScore('Fit Score'),
  byWater('Water Savings'),
  byNitrogen('N₂ Fixation'),
  byBareDays('Lowest Bare Days');

  final String label;
  const StrategySortOrder(this.label);
}

class CropRotationView extends StatefulWidget {
  const CropRotationView({super.key});

  @override
  State<CropRotationView> createState() => _CropRotationViewState();
}

class _CropRotationViewState extends State<CropRotationView> {
  StrategySortOrder _sortOrder = StrategySortOrder.byScore;

  void _showCustomRotationDialog(BuildContext context, FarmProvider farm) {
    String crop1 = farm.constraints.currentCrop;
    String crop2 = 'Mungbean (Pulse)';
    String crop3 = 'Chickpea (Legume)';

    final mainCrops = ['Wheat', 'Rice', 'Cotton', 'Maize', 'Soybeans', 'Sorghum'];
    final catchCrops = ['Mungbean (Pulse)', 'Cowpea (Forage)', 'Mustard (Brassica)', 'Sunn Hemp (Cover)', 'Clover (Cover)'];
    final coverCrops = ['Chickpea (Legume)', 'Field Pea (Pulse)', 'Lentil (Pulse)', 'Tillage Radish (Bio-drill)', 'Sunflower (Taproot)'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            // Live calculate sandbox metrics
            final fallbackWeather = AgroClimateSummary(
              meanTemp: 24.0,
              maxTemp: 32.0,
              minTemp: 16.0,
              meanRainfall: 1.5,
              totalRainfall: 45.0,
              dryDaysCount: 20,
              meanSolar: 18.0,
              observationDays: 30,
              isLiveNasaData: false,
              fetchTimestamp: DateTime.now(),
            );
            final customEval = RotationEngine.evaluateCustomSequence(
              cropNames: [crop1, crop2, crop3],
              constraints: farm.constraints,
              weather: farm.summary ?? fallbackWeather,
              scenario: farm.scenario,
            );

            return Container(
              height: MediaQuery.of(ctx).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.borderLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CUSTOM ROTATION BUILDER',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.primary),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Design & Benchmark a 3-Crop Sequence',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textDark),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Select 3 sequential crops suited to your soil and equipment to simulate water savings, biological nitrogen fixation, and soil organic matter improvements against NASA Earth benchmarks.',
                    style: TextStyle(fontSize: 11.5, color: AppColors.textMuted, height: 1.35),
                  ),
                  const SizedBox(height: 16),

                  // Crop Selectors
                  Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    children: [
                      _buildCropPicker(
                        label: 'Phase 1: Main Cash Crop',
                        value: crop1,
                        items: mainCrops,
                        onChanged: (val) {
                          if (val != null) setModalState(() => crop1 = val);
                        },
                      ),
                      _buildCropPicker(
                        label: 'Phase 2: Transition / Catch',
                        value: crop2,
                        items: catchCrops,
                        onChanged: (val) {
                          if (val != null) setModalState(() => crop2 = val);
                        },
                      ),
                      _buildCropPicker(
                        label: 'Phase 3: Deep Taproot / Pulse',
                        value: crop3,
                        items: coverCrops,
                        onChanged: (val) {
                          if (val != null) setModalState(() => crop3 = val);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Real-Time Simulated Performance Preview
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7FBF8),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFC7E2D1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'REAL-TIME ROTATION SIMULATION:',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: AppColors.primary),
                            ),
                            Text(
                              'BASED ON NASA AGROCLIMATOLOGY',
                              style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: AppColors.textSubtle),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildSandboxMetric(
                              'Fit Score',
                              '${customEval.overallScore}/100',
                              customEval.overallScore >= 80 ? AppColors.resilientGreen : AppColors.primary,
                            ),
                            _buildSandboxMetric(
                              'Water Shift',
                              '${customEval.waterSavingsPercentage >= 0 ? "+" : ""}${customEval.waterSavingsPercentage.toStringAsFixed(0)}%',
                              customEval.waterSavingsPercentage >= 15 ? AppColors.waterBlue : AppColors.textMuted,
                            ),
                            _buildSandboxMetric(
                              'N₂ Fixation',
                              '${customEval.nitrogenBalanceKgPerHa >= 0 ? "+" : ""}${customEval.nitrogenBalanceKgPerHa.toStringAsFixed(0)} kg/ha',
                              customEval.nitrogenBalanceKgPerHa > 0 ? AppColors.resilientGreen : AppColors.alertRed,
                            ),
                            _buildSandboxMetric(
                              'Bare Ground',
                              '${customEval.bareFieldDaysPerYear} days',
                              customEval.bareFieldDaysPerYear <= 25 ? AppColors.resilientGreen : AppColors.warningAmber,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add_task, size: 18),
                      label: const Text('Add This Custom Sequence to Strategy Comparison'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: AppColors.primary,
                      ),
                      onPressed: () {
                        farm.addCustomStrategy(customEval);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Custom Rotation "${customEval.title}" added to comparison table!'),
                            backgroundColor: AppColors.primary,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCropPicker({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.textDark)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value) ? value : items.first,
              isDense: true,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark),
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSandboxMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 9.5, color: AppColors.textSubtle, fontWeight: FontWeight.w600)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final farm = context.watch<FarmProvider>();
    final rawStrategies = List<RotationStrategy>.from(farm.strategies);

    // Apply sorting
    rawStrategies.sort((a, b) {
      switch (_sortOrder) {
        case StrategySortOrder.byScore:
          return b.overallScore.compareTo(a.overallScore);
        case StrategySortOrder.byWater:
          return b.waterSavingsPercentage.compareTo(a.waterSavingsPercentage);
        case StrategySortOrder.byNitrogen:
          return b.nitrogenBalanceKgPerHa.compareTo(a.nitrogenBalanceKgPerHa);
        case StrategySortOrder.byBareDays:
          return a.bareFieldDaysPerYear.compareTo(b.bareFieldDaysPerYear);
      }
    });

    final strategies = rawStrategies;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Heading
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    farm.tr('crop_rotation'),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.primary),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Climate-Resilient Crop Rotation Strategies',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: () => _showCustomRotationDialog(context, farm),
                icon: const Icon(Icons.tune, size: 15, color: AppColors.primary),
                label: const Text('Build Custom Rotation'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Parameter Controls Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ADAPTIVE PLANNING CONSTRAINTS & PRIORITIES:',
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: AppColors.textSubtle),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    // Current Crop Dropdown
                    _buildDropdown(
                      label: 'Current Sown Crop',
                      value: farm.constraints.currentCrop,
                      items: const ['Wheat', 'Rice', 'Cotton', 'Maize', 'Sugarcane'],
                      onChanged: (val) {
                        if (val != null) farm.updateCurrentCrop(val);
                      },
                    ),
                    // Soil Texture Dropdown
                    _buildDropdown(
                      label: 'Soil Texture',
                      value: farm.constraints.soilTexture,
                      items: const ['Loam', 'Sandy Loam', 'Clay', 'Silt Loam'],
                      onChanged: (val) {
                        if (val != null) farm.updateSoilTexture(val);
                      },
                    ),
                    // Farmer Priority Dropdown
                    _buildPriorityDropdown(
                      label: 'Farmer Priority',
                      value: farm.constraints.priority,
                      onChanged: (val) {
                        if (val != null) farm.updatePriority(val);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Side-by-Side Comparison Table / Matrix
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.table_chart_outlined, size: 18, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text(
                          'STRATEGY COMPARISON MATRIX (AT A GLANCE)',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: AppColors.primary),
                        ),
                      ],
                    ),
                    // Sort order dropdown
                    Row(
                      children: [
                        const Text('Sort: ', style: TextStyle(fontSize: 10.5, color: AppColors.textSubtle, fontWeight: FontWeight.bold)),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<StrategySortOrder>(
                            value: _sortOrder,
                            isDense: true,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                            items: StrategySortOrder.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label))).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _sortOrder = val);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 22,
                    headingRowHeight: 38,
                    dataRowMinHeight: 44,
                    dataRowMaxHeight: 52,
                    headingTextStyle: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.textSubtle),
                    columns: const [
                      DataColumn(label: Text('STRATEGY')),
                      DataColumn(label: Text('SCORE')),
                      DataColumn(label: Text('WATER SHIFT')),
                      DataColumn(label: Text('N₂ FIXATION')),
                      DataColumn(label: Text('BARE FALLOW')),
                      DataColumn(label: Text('SOIL HEALTH')),
                      DataColumn(label: Text('PEST BREAK')),
                    ],
                    rows: strategies.map((s) {
                      final isSel = farm.selectedStrategyId == s.id;
                      final titleLabel = s.title.contains(':')
                          ? s.title.split(':')[1].trim().split('&')[0]
                          : s.title;

                      return DataRow(
                        selected: isSel,
                        onSelectChanged: (_) => farm.selectStrategy(s.id),
                        cells: [
                          DataCell(
                            Row(
                              children: [
                                if (s.isBaseline)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    margin: const EdgeInsets.only(right: 6),
                                    decoration: BoxDecoration(color: AppColors.textMuted.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                                    child: const Text('BASE', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                                  ),
                                Text(
                                  titleLabel,
                                  style: TextStyle(fontSize: 11.5, fontWeight: isSel ? FontWeight.bold : FontWeight.w600, color: AppColors.textDark),
                                ),
                              ],
                            ),
                          ),
                          DataCell(Text('${s.overallScore}/100', style: const TextStyle(fontWeight: FontWeight.bold))),
                          DataCell(Text(
                            '${s.waterSavingsPercentage >= 0 ? "+" : ""}${s.waterSavingsPercentage.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: s.waterSavingsPercentage >= 20 ? AppColors.waterBlue : AppColors.textMuted,
                            ),
                          )),
                          DataCell(Text(
                            '${s.nitrogenBalanceKgPerHa >= 0 ? "+" : ""}${s.nitrogenBalanceKgPerHa.toStringAsFixed(0)} kg',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: s.nitrogenBalanceKgPerHa > 0 ? AppColors.resilientGreen : AppColors.alertRed,
                            ),
                          )),
                          DataCell(Text(
                            '${s.bareFieldDaysPerYear} days',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: s.bareFieldDaysPerYear <= 25 ? AppColors.resilientGreen : AppColors.warningAmber,
                            ),
                          )),
                          DataCell(Text('${s.soilHealthScore}/100')),
                          DataCell(Row(
                            children: List.generate(
                              5,
                              (idx) => Icon(
                                idx < s.pestBreakRating ? Icons.star : Icons.star_border,
                                size: 13,
                                color: const Color(0xFFF4A261),
                              ),
                            ),
                          )),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    icon: const Icon(Icons.copy, size: 14),
                    label: const Text('Copy Strategy Summary to Clipboard', style: TextStyle(fontSize: 11)),
                    onPressed: () {
                      final text = farm.exportAdvisoryReportText();
                      Clipboard.setData(ClipboardData(text: text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Agronomic decision report copied to clipboard!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Full Rotation Strategy Cards
          ...strategies.map((s) {
            return RotationStrategyCard(
              strategy: s,
              isSelected: farm.selectedStrategyId == s.id,
              onSelect: () => farm.selectStrategy(s.id),
            );
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isDense: true,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark),
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityDropdown({
    required String label,
    required FarmerPriority value,
    required ValueChanged<FarmerPriority?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<FarmerPriority>(
              value: value,
              isDense: true,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark),
              items: FarmerPriority.values.map((e) => DropdownMenuItem(value: e, child: Text(e.label))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

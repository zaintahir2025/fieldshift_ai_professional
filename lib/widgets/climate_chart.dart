import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/nasa_observation.dart';
import '../theme/app_theme.dart';

enum ChartMetricMode {
  tempAndRain('Temp & Rain', 'T2M vs PRECTOTCORR', Icons.thermostat),
  moistureAndEvp('Moisture & Evap', 'SMAP Wetness vs EVPTRNS', Icons.water_drop),
  heatAndHumidity('Heat & Humidity', 'T2M_MAX vs RH2M', Icons.wb_sunny),
  solarAndRain('Solar & Rain', 'ALLSKY_SFC vs PRECTOTCORR', Icons.wb_twilight);

  final String label;
  final String sublabel;
  final IconData icon;
  const ChartMetricMode(this.label, this.sublabel, this.icon);
}

class ClimateChart extends StatefulWidget {
  final List<DailyObservation> observations;
  final bool isLoading;

  const ClimateChart({
    super.key,
    required this.observations,
    this.isLoading = false,
  });

  @override
  State<ClimateChart> createState() => _ClimateChartState();
}

class _ClimateChartState extends State<ClimateChart> {
  ChartMetricMode _mode = ChartMetricMode.tempAndRain;

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const SizedBox(
        height: 280,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 12),
              Text(
                'Retrieving NASA POWER daily agroclimate observations…',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    if (widget.observations.isEmpty) {
      return const SizedBox(
        height: 280,
        child: Center(
          child: Text(
            'No observation records loaded. Please refresh or select a location.',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ),
      );
    }

    final obs = widget.observations;

    // Build series based on active mode
    final primarySpots = <FlSpot>[];
    final secondarySpots = <FlSpot>[];

    String primaryName = '';
    String secondaryName = '';
    String primaryUnit = '';
    String secondaryUnit = '';
    Color primaryColor = const Color(0xFFC77B3C);
    Color secondaryColor = const Color(0xFF4C91A5);

    double minP = 1000.0, maxP = -1000.0;
    double minS = 1000.0, maxS = -1000.0;

    for (int i = 0; i < obs.length; i++) {
      final o = obs[i];
      double pVal = 0.0;
      double sVal = 0.0;

      switch (_mode) {
        case ChartMetricMode.tempAndRain:
          primaryName = 'Mean Temp';
          secondaryName = 'Precipitation';
          primaryUnit = '°C';
          secondaryUnit = 'mm';
          primaryColor = const Color(0xFFD97724);
          secondaryColor = const Color(0xFF2E86AB);
          pVal = o.tempMean ?? 0.0;
          sVal = o.rainfall ?? 0.0;
          break;

        case ChartMetricMode.moistureAndEvp:
          primaryName = 'Root-Zone Moisture';
          secondaryName = 'Evapotranspiration';
          primaryUnit = 'm³/m³';
          secondaryUnit = 'MJ/m²';
          primaryColor = const Color(0xFF2D6A4F);
          secondaryColor = const Color(0xFFE07A5F);
          pVal = o.soilMoisture ?? 0.22;
          sVal = o.evapotranspiration ?? 3.5;
          break;

        case ChartMetricMode.heatAndHumidity:
          primaryName = 'Daily Max Temp';
          secondaryName = 'Relative Humidity';
          primaryUnit = '°C';
          secondaryUnit = '%';
          primaryColor = const Color(0xFFC0392B);
          secondaryColor = const Color(0xFF16A085);
          pVal = o.tempMax ?? (o.tempMean != null ? o.tempMean! + 4.0 : 30.0);
          sVal = o.relativeHumidity ?? 55.0;
          break;

        case ChartMetricMode.solarAndRain:
          primaryName = 'Solar Radiation';
          secondaryName = 'Precipitation';
          primaryUnit = 'kWh/m²';
          secondaryUnit = 'mm';
          primaryColor = const Color(0xFFF39C12);
          secondaryColor = const Color(0xFF2980B9);
          pVal = o.solarRadiation ?? 18.0;
          sVal = o.rainfall ?? 0.0;
          break;
      }

      primarySpots.add(FlSpot(i.toDouble(), pVal));
      secondarySpots.add(FlSpot(i.toDouble(), sVal));

      if (pVal < minP) minP = pVal;
      if (pVal > maxP) maxP = pVal;
      if (sVal < minS) minS = sVal;
      if (sVal > maxS) maxS = sVal;
    }

    if (maxP == minP) {
      maxP += 1.0;
      minP -= 1.0;
    }
    if (maxS == minS) {
      maxS += 1.0;
      minS -= 1.0;
    }

    // Safety margins
    final yMinPrimary = (minP - (maxP - minP) * 0.1).floorToDouble();
    final yMaxPrimary = (maxP + (maxP - minP) * 0.15).ceilToDouble();

    // Secondary scaling onto primary Y-axis range
    final scaledSecondarySpots = secondarySpots.map((s) {
      final norm = (s.y - minS) / max(0.001, (maxS - minS));
      final scaledY = yMinPrimary + norm * (yMaxPrimary - yMinPrimary) * 0.8;
      return FlSpot(s.x, scaledY);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dataset Metric Mode Selector Tabs
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ChartMetricMode.values.map((mode) {
              final isSel = _mode == mode;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                child: ChoiceChip(
                  avatar: Icon(
                    mode.icon,
                    size: 14,
                    color: isSel ? Colors.white : AppColors.primary,
                  ),
                  label: Text(mode.label),
                  selected: isSel,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surfaceLight,
                  labelStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                    color: isSel ? Colors.white : AppColors.textDark,
                  ),
                  side: BorderSide(
                    color: isSel ? AppColors.primary : AppColors.borderLight,
                  ),
                  onSelected: (val) {
                    if (val) setState(() => _mode = mode);
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 6),

        // Legend & Record Count Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Wrap(
                spacing: 14,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _buildLegendItem(
                    '$primaryName ($primaryUnit)',
                    primaryColor,
                    isLine: true,
                  ),
                  _buildLegendItem(
                    '$secondaryName ($secondaryUnit)',
                    secondaryColor,
                    isLine: false,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Text(
                '${obs.length} Daily Obs',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Chart Area
        SizedBox(
          height: 230,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: max(1.0, (yMaxPrimary - yMinPrimary) / 5),
                getDrawingHorizontalLine: (value) => FlLine(
                  color: AppColors.borderLight.withValues(alpha: 0.8),
                  strokeWidth: 1,
                  dashArray: [4, 4],
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 42,
                    getTitlesWidget: (value, meta) {
                      // Map scaled Y back to secondary unit
                      final frac = (value - yMinPrimary) /
                          max(0.001, (yMaxPrimary - yMinPrimary) * 0.8);
                      if (frac < 0 || frac > 1.05) {
                        return const SizedBox.shrink();
                      }
                      final origSec = minS + frac * (maxS - minS);
                      final formatted = origSec >= 10
                          ? origSec.toStringAsFixed(0)
                          : origSec.toStringAsFixed(1);
                      return Text(
                        '$formatted$secondaryUnit',
                        style: TextStyle(
                          fontSize: 9,
                          color: secondaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: max(1.0, (yMaxPrimary - yMinPrimary) / 4),
                    reservedSize: 36,
                    getTitlesWidget: (value, meta) {
                      final formatted = value >= 10 || value <= -10
                          ? value.toStringAsFixed(0)
                          : value.toStringAsFixed(1);
                      return Text(
                        '$formatted$primaryUnit',
                        style: TextStyle(
                          fontSize: 9.5,
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    interval: max(1.0, (obs.length / 6).floorToDouble()),
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < obs.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(
                            obs[index].dateKey,
                            style: const TextStyle(
                              fontSize: 9.5,
                              color: AppColors.textSubtle,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: (obs.length - 1).toDouble(),
              minY: yMinPrimary,
              maxY: yMaxPrimary,
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final idx = spot.x.toInt();
                      final o = idx >= 0 && idx < obs.length ? obs[idx] : null;
                      if (spot.barIndex == 0) {
                        final rawP = primarySpots[idx].y;
                        final pStr = rawP >= 10
                            ? rawP.toStringAsFixed(1)
                            : rawP.toStringAsFixed(2);
                        return LineTooltipItem(
                          '${o?.dateKey ?? ""}\n$primaryName: $pStr $primaryUnit',
                          const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      } else {
                        final rawS = secondarySpots[idx].y;
                        final sStr = rawS >= 10
                            ? rawS.toStringAsFixed(1)
                            : rawS.toStringAsFixed(2);
                        return LineTooltipItem(
                          '$secondaryName: $sStr $secondaryUnit',
                          TextStyle(
                            color: secondaryColor.withValues(alpha: 0.9),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }
                    }).toList();
                  },
                ),
              ),
              lineBarsData: [
                // Primary Bar Data (Curved line with gradient fill)
                LineChartBarData(
                  spots: primarySpots,
                  isCurved: true,
                  curveSmoothness: 0.28,
                  color: primaryColor,
                  barWidth: 2.4,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        primaryColor.withValues(alpha: 0.25),
                        primaryColor.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
                // Secondary Bar Data
                LineChartBarData(
                  spots: scaledSecondarySpots,
                  isCurved: false,
                  color: secondaryColor,
                  barWidth: 1.8,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: secondaryColor.withValues(alpha: 0.12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, {required bool isLine}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: isLine ? 3 : 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(isLine ? 1.5 : 2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

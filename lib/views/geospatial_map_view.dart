import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/farm_provider.dart';
import '../widgets/vulnerability_map_card.dart';
import '../models/vulnerability_zone.dart';
import '../theme/app_theme.dart';

class GeospatialMapView extends StatelessWidget {
  const GeospatialMapView({super.key});

  @override
  Widget build(BuildContext context) {
    final farm = context.watch<FarmProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    farm.tr('map_and_zones'),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.primary),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Interactive Satellite Overlays & Micro-Topography',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    onPressed: farm.isLocating
                        ? null
                        : () async {
                            final ok = await farm.locateUserCurrentGps();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(ok
                                      ? 'Detected GPS: ${farm.location.name} · ${farm.location.region}'
                                      : 'Could not access GPS location. Check device permissions.'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                    icon: farm.isLocating
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.my_location, size: 14),
                    label: Text(farm.isLocating ? 'Locating...' : 'Use My GPS'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          farm.activeMapLayer.contains('Satellite')
                              ? Icons.satellite_alt
                              : (farm.activeMapLayer.contains('Topo') ? Icons.terrain : Icons.map_outlined),
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Layer: ${farm.activeMapLayer}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textDark),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Main Interactive Map Card with Tap-to-Place, Opacity Slider & Overlays
          VulnerabilityMapCard(
            location: farm.location,
            vulnerabilityZones: farm.vulnerabilityZones,
            activeLayer: farm.activeMapLayer,
            layerOpacity: farm.mapLayerOpacity,
            visibleZoneTypes: farm.activeVulnerabilityTypes,
            onLayerChanged: (layer) => farm.setActiveMapLayer(layer),
            onOpacityChanged: (val) => farm.setMapLayerOpacity(val),
            onGpsRequested: () async {
              final ok = await farm.locateUserCurrentGps();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ok
                        ? 'Detected GPS: ${farm.location.name} · ${farm.location.region}'
                        : 'Could not access GPS location. Check device permissions.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            isLocating: farm.isLocating,
            onMapTapped: (point) {
              farm.setFarmCoordinateFromMap(point);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Farm pin relocated. Identifying place and recalculating satellite data...'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 3),
                ),
              );
            },
          ),
          const SizedBox(height: 18),

          // Micro-Topography & Elevation Profile Summary (NASA SRTM 30m + GRACE-FO)
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
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.terrain, color: AppColors.primary, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'PARCEL ELEVATION & CONCAVITY',
                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: AppColors.primary),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('NASA SRTM 30M', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: AppColors.resilientGreen)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTerrainStat(
                        label: 'Mean Elevation',
                        value: '${farm.summary?.elevationMeters?.toStringAsFixed(1) ?? "214.0"} m',
                        sub: 'Above Sea Level',
                        color: AppColors.primary,
                      ),
                    ),
                    Expanded(
                      child: _buildTerrainStat(
                        label: 'Aquifer Trend (GRACE-FO)',
                        value: farm.summary?.graceWaterStorageTrend != null
                            ? '${farm.summary!.graceWaterStorageTrend!.toStringAsFixed(1)} cm/yr'
                            : '-1.4 cm/yr',
                        sub: 'Terrestrial Storage',
                        color: AppColors.alertRed,
                      ),
                    ),
                    Expanded(
                      child: _buildTerrainStat(
                        label: 'Erosion Risk Swale',
                        value: 'Zone A (East)',
                        sub: '5.2% Concave Slope',
                        color: AppColors.warningAmber,
                      ),
                    ),
                    Expanded(
                      child: _buildTerrainStat(
                        label: 'Frost Accumulation Hollow',
                        value: 'Zone C (North)',
                        sub: 'Cold Air Drainage',
                        color: AppColors.waterBlue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Monthly Phenological & Cover Timeline Scrubber
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.calendar_month_outlined, color: AppColors.primary, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'ANNUAL VEGETATIVE CANOPY & BARE GROUND TIMELINE',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: AppColors.primary),
                        ),
                      ],
                    ),
                    Text(
                      _getMonthName(farm.activeTimelineMonth),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryLight),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Scrub through months to observe vegetative canopy cover vs bare fallow risk windows across the year.',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
                const SizedBox(height: 12),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.primary,
                    thumbColor: AppColors.primary,
                    overlayColor: AppColors.primary.withValues(alpha: 0.15),
                    trackHeight: 6,
                  ),
                  child: Slider(
                    value: farm.activeTimelineMonth.toDouble(),
                    min: 1,
                    max: 12,
                    divisions: 11,
                    label: _getMonthName(farm.activeTimelineMonth),
                    onChanged: (val) {
                      farm.setActiveTimelineMonth(val.toInt());
                    },
                  ),
                ),
                const SizedBox(height: 8),
                _buildTimelineStateBar(farm.activeTimelineMonth),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Field Vulnerabilities Grid / Deep Dive
          const Text(
            'FIELD-LEVEL VULNERABILITY ZONES & REMEDIATION ACTIONS',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.7, color: AppColors.primary),
          ),
          const SizedBox(height: 10),
          ...farm.vulnerabilityZones.map((zone) => _buildVulnerabilityExpandedCard(zone)),
          const SizedBox(height: 36),
        ],
      ),
    );
  }

  static String _getMonthName(int month) {
    const names = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return names[(month - 1).clamp(0, 11)];
  }

  Widget _buildTerrainStat({
    required String label,
    required String value,
    required String sub,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppColors.textSubtle), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 3),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: color), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(sub, style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildTimelineStateBar(int month) {
    // Determine condition for conventional vs resilient in this month
    final isSummerFallow = month >= 5 && month <= 6;
    final isMonsoon = month >= 7 && month <= 9;
    final isWinter = month >= 11 || month <= 2;

    String statusText;
    Color statusColor;
    String recommendation;

    if (isSummerFallow) {
      statusText = 'CRITICAL BARE GROUND EXPOSURE GAP';
      statusColor = AppColors.alertRed;
      recommendation = 'Field is bare under high solar irradiance (>50°C soil surface). Plant short-duration Mung bean or keep stubble mulch to prevent SOC loss.';
    } else if (isMonsoon) {
      statusText = 'MONSOON PRECIPITATION & RUNOFF RISK';
      statusColor = AppColors.waterBlue;
      recommendation = 'High GPM IMERG rainfall intensity. Contour vegetative barriers in Zone A swale will prevent sheet erosion.';
    } else if (isWinter) {
      statusText = 'WINTER GROWING CANOPY & FROST RISK';
      statusColor = AppColors.resilientGreen;
      recommendation = 'Vegetative canopy active. Monitor nocturnal low-lying hollows (Zone C) for freeze damage during cold waves.';
    } else {
      statusText = 'SEASON TRANSITION & HARVEST WINDOW';
      statusColor = AppColors.warningAmber;
      recommendation = 'Terminal grain filling. Watch for temperature spikes exceeding 35°C (NASA POWER).';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info, color: statusColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                ),
                const SizedBox(height: 2),
                Text(
                  recommendation,
                  style: const TextStyle(fontSize: 11, color: AppColors.textDark, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVulnerabilityExpandedCard(FieldVulnerabilityZone z) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(color: z.badgeColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        z.name,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: z.badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  z.severity,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: z.badgeColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(z.primaryThreat, style: const TextStyle(fontSize: 12, color: AppColors.textDark, height: 1.35)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildSmallBadge(Icons.landscape_outlined, z.elevationProfile),
              _buildSmallBadge(Icons.show_chart, z.slopeGradient),
              _buildSmallBadge(Icons.straighten, z.areaHectares),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.satellite_outlined, size: 15, color: AppColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'NASA Evidence: ${z.nasaObservationEvidence}',
                    style: const TextStyle(fontSize: 10.5, fontStyle: FontStyle.italic, color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8F4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFC7E2D1)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle_outline, size: 15, color: AppColors.resilientGreen),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Mitigation Prescription: ${z.mitigationStrategy}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF1B4332)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallBadge(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textSubtle),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

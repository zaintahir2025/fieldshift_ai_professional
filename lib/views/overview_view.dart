import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/farm_provider.dart';
import '../models/farm_location.dart';
import '../widgets/stat_card.dart';
import '../widgets/risk_gauge.dart';
import '../widgets/climate_chart.dart';
import '../widgets/farmer_advisory_banner.dart';
import '../theme/app_theme.dart';
import '../services/geocoding_service.dart';

class OverviewView extends StatefulWidget {
  final ValueChanged<int> onNavigateToTab;

  const OverviewView({super.key, required this.onNavigateToTab});

  @override
  State<OverviewView> createState() => _OverviewViewState();
}

class _OverviewViewState extends State<OverviewView> {
  final TextEditingController _searchController = TextEditingController();
  final GeocodingService _geocoding = GeocodingService();
  List<GeocodingSearchResult> _searchResults = [];
  bool _isSearching = false;

  void _showLocationDialog(BuildContext context, FarmProvider farm) {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.travel_explore, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('Select Farm Region or City', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              content: SizedBox(
                width: 480,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // GPS Detect Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: farm.isLocating
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.my_location, size: 16),
                        label: Text(
                          farm.isLocating ? 'Detecting GPS position...' : 'Use My Current GPS Location',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        onPressed: farm.isLocating
                            ? null
                            : () async {
                                setDialogState(() {});
                                final success = await farm.locateUserCurrentGps();
                                if (ctx.mounted) {
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        success
                                            ? 'Detected GPS: ${farm.location.name} · ${farm.location.region}'
                                            : 'Could not access GPS location. Please check device permissions.',
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('OR SEARCH PLACE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSubtle)),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search city or region worldwide…',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _isSearching
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                              )
                            : null,
                      ),
                      onChanged: (val) async {
                        setDialogState(() => _isSearching = true);
                        final r = await _geocoding.searchCities(val);
                        setDialogState(() {
                          _searchResults = r;
                          _isSearching = false;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    if (_searchResults.isNotEmpty) ...[
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Search Results:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSubtle)),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 180,
                        child: ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (ctx, i) {
                            final item = _searchResults[i];
                            return ListTile(
                              dense: true,
                              leading: const Icon(Icons.place, size: 18, color: AppColors.primaryLight),
                              title: Text(item.displayName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              subtitle: Text(
                                item.region.isNotEmpty ? item.region : 'OpenStreetMap Global Geocoder',
                                style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                              ),
                              onTap: () {
                                farm.setLocation(item.toFarmLocation(
                                  defaultCrop: farm.constraints.currentCrop,
                                  defaultSoil: farm.constraints.soilTexture,
                                ));
                                Navigator.pop(ctx);
                              },
                            );
                          },
                        ),
                      ),
                    ] else ...[
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Preset Major Agricultural Basins:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSubtle)),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 220,
                        child: ListView.builder(
                          itemCount: FarmLocation.presetLocations.length,
                          itemBuilder: (ctx, i) {
                            final loc = FarmLocation.presetLocations[i];
                            final isSel = farm.location.id == loc.id;
                            return ListTile(
                              dense: true,
                              leading: Icon(Icons.agriculture, size: 20, color: isSel ? AppColors.primary : AppColors.textSubtle),
                              title: Text(loc.name, style: TextStyle(fontSize: 12, fontWeight: isSel ? FontWeight.bold : FontWeight.w500)),
                              subtitle: Text('${loc.region} · ${loc.defaultCrop} / ${loc.defaultSoil}', style: const TextStyle(fontSize: 10.5)),
                              trailing: isSel ? const Icon(Icons.check, size: 16, color: AppColors.primary) : null,
                              onTap: () {
                                farm.setLocation(loc);
                                Navigator.pop(ctx);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSatelliteSourceModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.75,
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
                  decoration: BoxDecoration(color: AppColors.borderLight, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.satellite_alt, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'NASA Earth Observation Datasets Applied in FieldShift AI',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: const [
                    _DatasetExplainerCard(
                      title: 'NASA POWER Agroclimatology (AG)',
                      tag: 'Daily Weather & Solar Flux',
                      description: 'Provides live daily surface air temperature (T2M), maximums (T2M_MAX), minimums (T2M_MIN), bias-corrected precipitation (PRECTOTCORR), surface relative humidity (RH2M), and solar irradiance (ALLSKY_SFC_SW_DWN) via MERRA-2 assimilation.',
                    ),
                    _DatasetExplainerCard(
                      title: 'NASA SMAP (Soil Moisture Active Passive)',
                      tag: 'Root-Zone & Surface Wetness',
                      description: 'Supplies L4 root-zone (0–100 cm) and surface (0–5 cm) soil moisture estimates to detect seasonal moisture depletion and calibrate drought stress without requiring expensive in-ground probes.',
                    ),
                    _DatasetExplainerCard(
                      title: 'NASA ECOSTRESS & MERRA-2 EVPTRNS',
                      tag: 'Evaporation & Water Stress',
                      description: 'Captures thermal plant evapotranspiration energy flux to flag canopy water stress before visible foliar wilting occurs.',
                    ),
                    _DatasetExplainerCard(
                      title: 'NASA SRTM 30m Digital Elevation Model',
                      tag: 'Terrain & Concavity Mapping',
                      description: 'Determines parcel-level elevation, slope curvature, and drainage lines to delineate erosion swales and nocturnal frost accumulation hollows.',
                    ),
                    _DatasetExplainerCard(
                      title: 'NASA GRACE & GRACE-FO',
                      tag: 'Groundwater & Aquifer Storage',
                      description: 'Tracks multidecadal terrestrial water storage anomalies, warning farmers of depleted aquifers and impending regional groundwater overdraft.',
                    ),
                    _DatasetExplainerCard(
                      title: 'NASA MODIS & Landsat GIBS Overlays',
                      tag: 'Satellite Imagery & NDVI',
                      description: 'Provides true-color imagery and NDVI vegetation index overlays to pinpoint seasonal bare soil gaps and vegetative vigor.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final farm = context.watch<FarmProvider>();
    final summary = farm.summary;
    final outlook = farm.predictiveOutlook;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Farmer advisory banner
          FarmerAdvisoryBanner(
            onLearnMore: () => widget.onNavigateToTab(5), // Navigate to NASA catalog & transparency
          ),
          const SizedBox(height: 12),

          // Location and quick status bar
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: LayoutBuilder(
              builder: (ctx, boxConstraints) {
                final isNarrow = boxConstraints.maxWidth < 720;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.location_on, color: AppColors.primary, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  Text(
                                    farm.location.name,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: summary?.isLiveNasaData == true ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: summary?.isLiveNasaData == true ? const Color(0xFFA5D6A7) : const Color(0xFFFFCC80),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 5,
                                          height: 5,
                                          decoration: BoxDecoration(
                                            color: summary?.isLiveNasaData == true ? AppColors.resilientGreen : AppColors.warningAmber,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          summary?.isLiveNasaData == true ? 'LIVE NASA DATA' : 'CALIBRATED OFFLINE',
                                          style: TextStyle(
                                            fontSize: 8.5,
                                            fontWeight: FontWeight.bold,
                                            color: summary?.isLiveNasaData == true ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${farm.location.region} · Agro-Climatic Zone: ${farm.location.climateZone} · Soil: ${farm.location.defaultSoil}',
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        if (!isNarrow) ...[
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: farm.isLocating
                                ? null
                                : () async {
                                    final success = await farm.locateUserCurrentGps();
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            success
                                                ? 'Detected GPS: ${farm.location.name} · ${farm.location.region}'
                                                : 'Could not access GPS location. Check device permissions.',
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  },
                            icon: farm.isLocating
                                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.my_location, size: 14),
                            label: Text(farm.isLocating ? 'Locating...' : 'Detect GPS'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () => _showLocationDialog(context, farm),
                            icon: const Icon(Icons.search, size: 14),
                            label: const Text('Change Location'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            tooltip: 'Refresh NASA observations',
                            icon: farm.isLoading
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                                : const Icon(Icons.refresh, color: AppColors.primary),
                            onPressed: farm.isLoading ? null : () => farm.loadFarmData(),
                          ),
                        ],
                      ],
                    ),
                    if (isNarrow) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: farm.isLocating
                                  ? null
                                  : () async {
                                      final success = await farm.locateUserCurrentGps();
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              success
                                                  ? 'Detected GPS: ${farm.location.name} · ${farm.location.region}'
                                                  : 'Could not access GPS location. Check device permissions.',
                                            ),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      }
                                    },
                              icon: farm.isLocating
                                  ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Icon(Icons.my_location, size: 14),
                              label: Text(farm.isLocating ? 'Locating...' : 'GPS Locate'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _showLocationDialog(context, farm),
                              icon: const Icon(Icons.search, size: 14),
                              label: const Text('Change Place'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            tooltip: 'Refresh NASA observations',
                            icon: farm.isLoading
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                                : const Icon(Icons.refresh, color: AppColors.primary),
                            onPressed: farm.isLoading ? null : () => farm.loadFarmData(),
                          ),
                        ],
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // 4 Main Agroclimatic Stat Cards
          LayoutBuilder(
            builder: (ctx, constraints) {
              final isWide = constraints.maxWidth > 700;
              final crossAxisCount = isWide ? 4 : 2;

              return GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  mainAxisExtent: 144,
                ),
                children: [
                  StatCard(
                    icon: Icons.thermostat,
                    label: farm.tr('mean_temp'),
                    value: summary != null ? summary.meanTemp.toStringAsFixed(1) : '—',
                    unit: '°C',
                    trend: summary != null ? 'Max: ${summary.maxTemp.toStringAsFixed(1)}°' : 'Daily Mean',
                    toneColor: AppColors.warningAmber,
                    dataSource: 'NASA POWER T2M Daily',
                  ),
                  StatCard(
                    icon: Icons.water_drop_outlined,
                    label: farm.tr('daily_rainfall'),
                    value: summary != null ? summary.meanRainfall.toStringAsFixed(2) : '—',
                    unit: 'mm/day',
                    trend: summary != null ? 'Tot: ${summary.totalRainfall.toStringAsFixed(0)}mm' : 'Corrected Rain',
                    toneColor: AppColors.waterBlue,
                    dataSource: 'NASA POWER PRECTOTCORR',
                  ),
                  StatCard(
                    icon: Icons.wb_sunny_outlined,
                    label: farm.tr('solar_radiation'),
                    value: summary != null ? summary.meanSolar.toStringAsFixed(1) : '—',
                    unit: 'kWh/m²',
                    trend: 'Surface Shortwave',
                    toneColor: AppColors.solarYellow,
                    dataSource: 'NASA POWER ALLSKY_SFC',
                  ),
                  StatCard(
                    icon: Icons.grass_outlined,
                    label: farm.tr('soil_moisture'),
                    value: summary?.meanRootZoneMoisture != null ? summary!.meanRootZoneMoisture!.toStringAsFixed(3) : '0.225',
                    unit: 'm³/m³',
                    trend: '0–100 cm Profile',
                    toneColor: AppColors.resilientGreen,
                    dataSource: 'NASA SMAP L4 via POWER AG',
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),

          // Secondary Agroclimatology Strip (SRTM Elevation, EVPTRNS, RH2M, GRACE Aquifer, Heat & Frost Days)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Wrap(
              spacing: 16,
              runSpacing: 10,
              alignment: WrapAlignment.spaceAround,
              children: [
                _buildSecondaryStat(
                  icon: Icons.terrain,
                  label: 'SRTM Elevation',
                  value: '${summary?.elevationMeters?.toStringAsFixed(0) ?? "214"} m ASL',
                  color: AppColors.primary,
                ),
                _buildSecondaryStat(
                  icon: Icons.energy_savings_leaf_outlined,
                  label: 'Evaporation Flux',
                  value: '${summary?.meanEvapotranspiration?.toStringAsFixed(1) ?? "3.4"} MJ/m²',
                  color: const Color(0xFFE07A5F),
                ),
                _buildSecondaryStat(
                  icon: Icons.water,
                  label: 'Relative Humidity',
                  value: '${summary?.meanRelativeHumidity?.toStringAsFixed(0) ?? "58"}%',
                  color: const Color(0xFF2E86AB),
                ),
                _buildSecondaryStat(
                  icon: Icons.thermostat_outlined,
                  label: 'Heat Stress Days',
                  value: '${summary?.heatStressDaysCount ?? 0} days (≥35°)',
                  color: AppColors.alertRed,
                ),
                _buildSecondaryStat(
                  icon: Icons.ac_unit,
                  label: 'Frost Risk Days',
                  value: '${summary?.frostRiskDaysCount ?? 0} days (≤2°)',
                  color: AppColors.waterBlue,
                ),
                _buildSecondaryStat(
                  icon: Icons.water_damage_outlined,
                  label: 'Aquifer Trend',
                  value: summary?.graceWaterStorageTrend != null
                      ? '${summary!.graceWaterStorageTrend!.toStringAsFixed(1)} cm/yr'
                      : '-1.4 cm/yr',
                  color: AppColors.warningAmber,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Two-column layout for Climate Time Series and Risk Gauge
          LayoutBuilder(
            builder: (ctx, constraints) {
              if (constraints.maxWidth > 850) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.all(18),
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
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        farm.tr('weather_trends'),
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.7, color: AppColors.primary),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'NASA Earth Observation Agroclimate Series',
                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SegmentedButton<int>(
                                  segments: const [
                                    ButtonSegment(value: 7, label: Text('7d', style: TextStyle(fontSize: 11))),
                                    ButtonSegment(value: 30, label: Text('30d', style: TextStyle(fontSize: 11))),
                                    ButtonSegment(value: 90, label: Text('90d', style: TextStyle(fontSize: 11))),
                                  ],
                                  selected: {farm.rangeDays},
                                  onSelectionChanged: (set) {
                                    farm.setRangeDays(set.first);
                                  },
                                  style: const ButtonStyle(
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            ClimateChart(observations: farm.observations, isLoading: farm.isLoading),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: RiskGaugeCard(risk: farm.riskScore),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
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
                              const Text('Agroclimate Series', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              SegmentedButton<int>(
                                segments: const [
                                  ButtonSegment(value: 7, label: Text('7d', style: TextStyle(fontSize: 10.5))),
                                  ButtonSegment(value: 30, label: Text('30d', style: TextStyle(fontSize: 10.5))),
                                  ButtonSegment(value: 90, label: Text('90d', style: TextStyle(fontSize: 10.5))),
                                ],
                                selected: {farm.rangeDays},
                                onSelectionChanged: (set) => farm.setRangeDays(set.first),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ClimateChart(observations: farm.observations, isLoading: farm.isLoading),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    RiskGaugeCard(risk: farm.riskScore),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 18),

          // 7-Day Trend-Based Predictive Outlook Banner
          if (outlook != null) ...[
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC77B3C).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.trending_up, color: Color(0xFFC77B3C), size: 18),
                          ),
                          const SizedBox(width: 8),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'EXPERIMENTAL 7-DAY TREND-BASED CLIMATE OUTLOOK',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.7, color: Color(0xFFC77B3C)),
                              ),
                              Text(
                                'Linear Extrapolation from Recent NASA POWER Observations',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('NOT A FORECAST', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Color(0xFFE65100))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  LayoutBuilder(
                    builder: (ctx, constraints) {
                      final isWide = constraints.maxWidth > 650;
                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: isWide ? 4 : 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: isWide ? 2.1 : 1.35,
                        children: [
                          _buildOutlookTile(
                            title: 'COMBINED STRESS SIGNAL',
                            val: '${outlook.combinedRisk}/100',
                            sub: '${outlook.riskLevel} Risk Level',
                            color: outlook.combinedRisk >= 70 ? AppColors.alertRed : (outlook.combinedRisk >= 40 ? AppColors.warningAmber : AppColors.resilientGreen),
                          ),
                          _buildOutlookTile(
                            title: 'TEMPERATURE TREND',
                            val: '${outlook.projectedMeanTemp.toStringAsFixed(1)}°C',
                            sub: outlook.direction,
                            color: AppColors.warningAmber,
                          ),
                          _buildOutlookTile(
                            title: 'RAINFALL PERSISTENCE',
                            val: '${outlook.projected7DayRain.toStringAsFixed(1)} mm',
                            sub: '7-Day Baseline Total',
                            color: AppColors.waterBlue,
                          ),
                          _buildOutlookTile(
                            title: 'DATA COVERAGE',
                            val: '${outlook.observationCount} Days',
                            sub: '${outlook.dryDays} Dry Days (<1mm)',
                            color: AppColors.primary,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],

          // Quick Navigation & Satellite Explainer Pill
          LayoutBuilder(
            builder: (ctx, navConstraints) {
              final isMobile = navConstraints.maxWidth < 620;
              if (isMobile) {
                return Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => widget.onNavigateToTab(2), // Navigate to Crop Rotation
                        icon: const Icon(Icons.eco, size: 18),
                        label: const Text('Compare 4 Rotation Strategies'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => widget.onNavigateToTab(1), // Navigate to Map
                        icon: const Icon(Icons.map_outlined, size: 18),
                        label: const Text('Inspect Landscape Vulnerability'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                      ),
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => widget.onNavigateToTab(2), // Navigate to Crop Rotation
                      icon: const Icon(Icons.eco, size: 18),
                      label: const Text('Compare 4 Rotation Strategies'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => widget.onNavigateToTab(1), // Navigate to Map
                      icon: const Icon(Icons.map_outlined, size: 18),
                      label: const Text('Inspect Landscape Vulnerability'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),

          // Explainer button for NASA datasets
          Center(
            child: TextButton.icon(
              icon: const Icon(Icons.satellite_alt_outlined, size: 15, color: AppColors.primary),
              label: const Text('Explore NASA Earth Observation Missions Applied in FieldShift', style: TextStyle(fontSize: 11.5, color: AppColors.primary, fontWeight: FontWeight.bold)),
              onPressed: () => _showSatelliteSourceModal(context),
            ),
          ),
          const SizedBox(height: 36),
        ],
      ),
    );
  }

  Widget _buildSecondaryStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textSubtle, fontWeight: FontWeight.bold)),
            Text(value, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ],
    );
  }

  Widget _buildOutlookTile({
    required String title,
    required String val,
    required String sub,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSubtle, letterSpacing: 0.5)),
          const SizedBox(height: 3),
          Text(val, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 2),
          Text(sub, style: const TextStyle(fontSize: 10, color: AppColors.textMuted), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _DatasetExplainerCard extends StatelessWidget {
  final String title;
  final String tag;
  final String description;

  const _DatasetExplainerCard({
    required this.title,
    required this.tag,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.primary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryMuted,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(tag, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(description, style: const TextStyle(fontSize: 11, color: AppColors.textDark, height: 1.35)),
        ],
      ),
    );
  }
}

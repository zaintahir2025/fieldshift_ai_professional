import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/farm_provider.dart';
import 'services/localization_service.dart';
import 'theme/app_theme.dart';
import 'views/auth/auth_wrapper.dart';
import 'views/overview_view.dart';
import 'views/geospatial_map_view.dart';
import 'views/crop_rotation_view.dart';
import 'views/scenario_simulator_view.dart';
import 'views/farmer_profile_view.dart';
import 'views/nasa_catalog_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization note: $e');
  }
  runApp(const FieldShiftApp());
}

class FieldShiftApp extends StatelessWidget {
  const FieldShiftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FarmProvider()),
      ],
      child: MaterialApp(
        title: 'FIELDSHIFT AI — Earth Intelligence for Resilient Farms',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(child: MainScaffold()),
      ),
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final farm = context.watch<FarmProvider>();

    final titles = [
      farm.tr('overview'),
      farm.tr('map_and_zones'),
      farm.tr('crop_rotation'),
      farm.tr('climate_simulator'),
      farm.tr('farmer_profile'),
      farm.tr('transparency'),
    ];

    return LayoutBuilder(
      builder: (ctx, constraints) {
        final isDesktop = constraints.maxWidth >= 850;

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.eco, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(fontFamily: 'Roboto', color: AppColors.textDark),
                          children: [
                            TextSpan(text: 'FIELD', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                            TextSpan(text: 'SHIFT ', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF2D6A4F))),
                            TextSpan(text: 'AI', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Color(0xFFE65100))),
                          ],
                        ),
                      ),
                      Text(
                        constraints.maxWidth > 420
                            ? 'EARTH OBSERVATION ADVISORY · NASA SPACE APPS 2026'
                            : 'NASA EARTH ADVISORY',
                        style: const TextStyle(fontSize: 8.5, letterSpacing: 0.5, fontWeight: FontWeight.w700, color: AppColors.textSubtle),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (constraints.maxWidth >= 1150) ...[
                  const SizedBox(width: 16),
                  Container(
                    height: 24,
                    width: 1,
                    color: AppColors.borderLight,
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      titles[_currentIndex],
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              // Current Location Pill (shown on tablet/desktop)
              if (constraints.maxWidth > 700) ...[
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.place, size: 14, color: AppColors.primary),
                      const SizedBox(width: 5),
                      Text(
                        farm.location.name.split(',')[0],
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textDark),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
              ],

              // Language Selector Dropdown in AppBar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: farm.currentLanguage,
                    isDense: true,
                    icon: const Icon(Icons.arrow_drop_down, size: 16),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                    items: LocalizationService.supportedLanguages.entries.map((e) {
                      return DropdownMenuItem(
                        value: e.key,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.language, size: 12, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(e.key.toUpperCase()),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (lang) {
                      if (lang != null) farm.setLanguage(lang);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Simple Farmer Mode Pill (shown on wider screens)
              if (constraints.maxWidth > 550) ...[
                InkWell(
                  onTap: () => farm.toggleSimpleFarmerMode(),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: farm.isSimpleFarmerMode ? const Color(0xFFE8F5E9) : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: farm.isSimpleFarmerMode ? const Color(0xFFA5D6A7) : AppColors.borderLight),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          farm.isSimpleFarmerMode ? Icons.volunteer_activism : Icons.science_outlined,
                          size: 13,
                          color: farm.isSimpleFarmerMode ? AppColors.resilientGreen : AppColors.textSubtle,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          farm.isSimpleFarmerMode ? farm.tr('farmer_mode') : farm.tr('specialist_mode'),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: farm.isSimpleFarmerMode ? AppColors.resilientGreen : AppColors.textSubtle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              ],

              IconButton(
                tooltip: 'Scientific Transparency & About',
                icon: const Icon(Icons.info_outline, color: AppColors.textMuted, size: 20),
                onPressed: () {
                  setState(() => _currentIndex = 5); // NASA catalog
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Row(
            children: [
              if (isDesktop)
                NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
                  labelType: NavigationRailLabelType.all,
                  backgroundColor: Colors.white,
                  selectedIconTheme: const IconThemeData(color: AppColors.primary),
                  selectedLabelTextStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                  unselectedLabelTextStyle: const TextStyle(fontSize: 10.5, color: AppColors.textSubtle),
                  destinations: [
                    NavigationRailDestination(
                      icon: const Icon(Icons.dashboard_outlined),
                      selectedIcon: const Icon(Icons.dashboard),
                      label: Text(farm.tr('nav_overview')),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.map_outlined),
                      selectedIcon: const Icon(Icons.map),
                      label: Text(farm.tr('nav_map')),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.eco_outlined),
                      selectedIcon: const Icon(Icons.eco),
                      label: Text(farm.tr('nav_rotations')),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.tune_outlined),
                      selectedIcon: const Icon(Icons.tune),
                      label: Text(farm.tr('nav_scenarios')),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.person_outline),
                      selectedIcon: const Icon(Icons.person),
                      label: Text(farm.tr('nav_profile')),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.satellite_alt_outlined),
                      selectedIcon: const Icon(Icons.satellite_alt),
                      label: Text(farm.tr('nav_nasa')),
                    ),
                  ],
                ),
              if (isDesktop) const VerticalDivider(width: 1, thickness: 1, color: AppColors.borderLight),
              Expanded(
                child: IndexedStack(
                  index: _currentIndex,
                  children: [
                    OverviewView(onNavigateToTab: (idx) => setState(() => _currentIndex = idx)),
                    const GeospatialMapView(),
                    const CropRotationView(),
                    const ScenarioSimulatorView(),
                    const FarmerProfileView(),
                    NasaCatalogView(onBack: () => setState(() => _currentIndex = 0)),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: isDesktop
              ? null
              : NavigationBar(
                  selectedIndex: _currentIndex > 4 ? 0 : _currentIndex,
                  onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
                  backgroundColor: Colors.white,
                  indicatorColor: AppColors.primary.withValues(alpha: 0.15),
                  height: 64,
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                  destinations: [
                    NavigationDestination(
                      icon: const Icon(Icons.dashboard_outlined, size: 20),
                      selectedIcon: const Icon(Icons.dashboard, size: 20, color: AppColors.primary),
                      label: farm.tr('nav_overview'),
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.map_outlined, size: 20),
                      selectedIcon: const Icon(Icons.map, size: 20, color: AppColors.primary),
                      label: farm.tr('nav_map'),
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.eco_outlined, size: 20),
                      selectedIcon: const Icon(Icons.eco, size: 20, color: AppColors.primary),
                      label: farm.tr('nav_rotations'),
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.tune_outlined, size: 20),
                      selectedIcon: const Icon(Icons.tune, size: 20, color: AppColors.primary),
                      label: farm.tr('nav_scenarios'),
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.person_outline, size: 20),
                      selectedIcon: const Icon(Icons.person, size: 20, color: AppColors.primary),
                      label: farm.tr('nav_profile'),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

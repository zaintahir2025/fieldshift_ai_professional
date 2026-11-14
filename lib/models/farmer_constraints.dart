enum FarmerPriority {
  waterConservation('Water Conservation', 'Prioritize drought-tolerant, low-irrigation crops to guard against groundwater depletion.'),
  soilHealth('Soil Health & Organic Matter', 'Integrate biological nitrogen fixation, deep taproots, and continuous soil cover to restore soil carbon.'),
  cropDiversification('Crop Diversification & Pest Break', 'Break monoculture pest, disease, and weed life-cycles through botanically diverse species.'),
  economicReturn('Economic Cash Flow', 'Maximize net gross margin per hectare with high-value market-ready harvests.'),
  livestockForage('Livestock Forage & Biomass', 'Provide nutrient-dense green fodder and crop residues for dairy and cattle herds.');

  final String label;
  final String description;
  const FarmerPriority(this.label, this.description);
}

enum IrrigationSystem {
  canalGravity('Canal Water (Rotational)', 'Dependent on rotational canal releases; high vulnerability to supply delays.'),
  tubewellGroundwater('Tubewell / Deep Groundwater', 'High energy/fuel pumping cost; vulnerable to aquifer depletion and salinity.'),
  dripMicro('Drip / Micro-Irrigation', 'Precision water delivery; 40-60% water savings; requires clean filtered water.'),
  rainfed('Strictly Rainfed / Dryland', 'Entirely dependent on seasonal precipitation patterns and soil water storage.');

  final String label;
  final String description;
  const IrrigationSystem(this.label, this.description);
}

enum EquipmentLevel {
  basicTractor('Standard Tractor & Tillage', 'Disc harrow, cultivator, planker available.'),
  directSeeder('Direct Seeder / Happy Seeder', 'Enables zero-till direct drilling into standing crop residue without burning.'),
  combineHarvester('Combine Harvester', 'Mechanized harvest available; creates residue distribution needs.'),
  manualHandTools('Manual & Draft Animal', 'Relies on family labor or draft animals; smaller plot operations.');

  final String label;
  final String description;
  const EquipmentLevel(this.label, this.description);
}

enum MarketPreference {
  localMandi('Local Mandi / Grain Market', 'Immediate cash liquidity; vulnerable to peak harvest price gluts.'),
  contractProcessor('Contract Farming / Food Processor', 'Predetermined purchase price; strict grade and moisture specifications.'),
  livestockDairy('Livestock & Dairy Integration', 'On-farm feeding or local hay sales to livestock producers.'),
  seedCooperative('Cooperative / Certified Seed', 'Premium price for certified purity; requires rigorous quality control.');

  final String label;
  final String description;
  const MarketPreference(this.label, this.description);
}

typedef MarketAccessType = MarketPreference;

class FarmerConstraints {
  final FarmerPriority priority;
  final IrrigationSystem irrigation;
  final List<EquipmentLevel> equipment;
  final MarketPreference market;
  final String currentCrop;
  final String soilTexture;
  final double? manualSoilMoisture; // m³/m³
  final double? manualNdvi;
  final double? manualNdviChange;
  final String? soilSalinityLevel; // Low, Moderate, High

  const FarmerConstraints({
    this.priority = FarmerPriority.waterConservation,
    this.irrigation = IrrigationSystem.canalGravity,
    this.equipment = const [EquipmentLevel.basicTractor],
    this.market = MarketPreference.localMandi,
    this.currentCrop = 'Wheat',
    this.soilTexture = 'Loam',
    this.manualSoilMoisture,
    this.manualNdvi,
    this.manualNdviChange,
    this.soilSalinityLevel = 'Low',
  });

  MarketPreference get marketAccess => market;

  FarmerConstraints copyWith({
    FarmerPriority? priority,
    IrrigationSystem? irrigation,
    List<EquipmentLevel>? equipment,
    MarketPreference? market,
    MarketPreference? marketAccess,
    String? currentCrop,
    String? soilTexture,
    double? manualSoilMoisture,
    double? manualNdvi,
    double? manualNdviChange,
    String? soilSalinityLevel,
    bool clearManualMoisture = false,
  }) {
    return FarmerConstraints(
      priority: priority ?? this.priority,
      irrigation: irrigation ?? this.irrigation,
      equipment: equipment ?? this.equipment,
      market: marketAccess ?? (market ?? this.market),
      currentCrop: currentCrop ?? this.currentCrop,
      soilTexture: soilTexture ?? this.soilTexture,
      manualSoilMoisture: clearManualMoisture ? null : (manualSoilMoisture ?? this.manualSoilMoisture),
      manualNdvi: manualNdvi ?? this.manualNdvi,
      manualNdviChange: manualNdviChange ?? this.manualNdviChange,
      soilSalinityLevel: soilSalinityLevel ?? this.soilSalinityLevel,
    );
  }
}

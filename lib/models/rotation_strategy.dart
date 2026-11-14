class RotationCropStep {
  final String cropName;
  final String seasonName;
  final String category; // Cereal, Legume, Oilseed, Cover Crop, Cash Crop
  final int startMonth; // 1-12
  final int durationMonths;
  final String waterDemand; // Low, Medium, High
  final String rootingDepth; // Shallow (0-40cm), Medium (40-90cm), Deep (>90cm)
  final String nitrogenBalance; // Positive (+40-70 kg N/ha), Neutral, Depleting (-60-120 kg N/ha)
  final String primaryBenefit;
  final bool isCoverCrop;
  final bool isBareFallow;

  const RotationCropStep({
    required this.cropName,
    required this.seasonName,
    required this.category,
    required this.startMonth,
    required this.durationMonths,
    required this.waterDemand,
    required this.rootingDepth,
    required this.nitrogenBalance,
    required this.primaryBenefit,
    this.isCoverCrop = false,
    this.isBareFallow = false,
  });

  int get endMonth => ((startMonth + durationMonths - 2) % 12) + 1;

  List<int> get monthSpan {
    final list = <int>[];
    for (int i = 0; i < durationMonths; i++) {
      list.add(((startMonth - 1 + i) % 12) + 1);
    }
    return list;
  }

  String get monthWindow {
    const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${m[startMonth - 1]}–${m[endMonth - 1]}';
  }

  int get rootingDepthCm {
    if (rootingDepth.contains('Deep')) return 110;
    if (rootingDepth.contains('Medium')) return 65;
    return 35;
  }

  int get waterDemandMm {
    if (waterDemand.contains('High')) return 520;
    if (waterDemand.contains('Medium')) return 340;
    return 190;
  }

  String get pestDisruptionMechanism {
    if (isBareFallow) return 'No disruption; promotes weed seed bank persistence and pathogen harboring.';
    if (category.contains('Legume')) return 'Breaks cereal cyst nematode, Fusarium, and take-all fungal cycles.';
    if (category.contains('Oilseed') || category.contains('Brassica')) return 'Bio-fumigation via root glucosinolates suppresses soilborne pathogens.';
    return 'Diversifies root exudate biome and interrupts repetitive monoculture pest cycles.';
  }

  String get biomassContribution {
    if (isBareFallow) return 'Negative; accelerates soil organic carbon oxidation under direct sunlight.';
    if (category.contains('Cover') || isCoverCrop) return '+3.5–5.0 tons/ha green manure residue added to topsoil.';
    if (category.contains('Legume')) return '+2.0–3.2 tons/ha high-nitrogen organic residue.';
    return '+3.0–4.5 tons/ha root and stubble carbon residue.';
  }
}

class VulnerabilityPeriod {
  final String crop;
  final String monthWindow;
  final String phenologicalStage;
  final String hazardType; // Heat Wave, Frost, Drought, Flooding, Pest Emergence
  final String hazardSeverity; // Critical, Elevated, Moderate
  final String nasaDataSource;
  final String impactMechanism;
  final String recommendedMitigation;

  const VulnerabilityPeriod({
    required this.crop,
    required this.monthWindow,
    required this.phenologicalStage,
    required this.hazardType,
    required this.hazardSeverity,
    required this.nasaDataSource,
    required this.impactMechanism,
    required this.recommendedMitigation,
  });
}

class RotationStrategy {
  final String id;
  final String title;
  final String subtitle;
  final String tag;
  final bool isBaseline;
  final List<RotationCropStep> steps;
  final String whySuggested;
  final List<String> evidenceSupported;
  final List<String> agronomicBenefits;
  final List<String> informationGaps;
  final List<String> risksRequiringLocalReview;
  final int bareFieldDaysPerYear;
  final List<VulnerabilityPeriod> vulnerabilityPeriods;
  final int soilHealthScore; // 0-100
  final double waterSavingsPercentage; // Positive = savings, Negative = additional demand
  final double nitrogenBalanceKgPerHa; // Positive = net fixation, Negative = net removal
  final int pestBreakRating; // 1 to 5 stars
  final int economicResilienceScore; // 0 to 100
  final int overallScore; // 0 to 100

  const RotationStrategy({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.isBaseline,
    required this.steps,
    required this.whySuggested,
    required this.evidenceSupported,
    required this.agronomicBenefits,
    required this.informationGaps,
    required this.risksRequiringLocalReview,
    required this.bareFieldDaysPerYear,
    required this.vulnerabilityPeriods,
    required this.soilHealthScore,
    required this.waterSavingsPercentage,
    required this.nitrogenBalanceKgPerHa,
    required this.pestBreakRating,
    required this.economicResilienceScore,
    required this.overallScore,
  });
}

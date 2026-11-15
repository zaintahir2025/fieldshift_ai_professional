import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/farm_provider.dart';
import '../providers/auth_provider.dart';
import '../models/app_user.dart';
import '../models/farmer_constraints.dart';
import '../services/localization_service.dart';
import '../theme/app_theme.dart';

class FarmerProfileView extends StatefulWidget {
  const FarmerProfileView({super.key});

  @override
  State<FarmerProfileView> createState() => _FarmerProfileViewState();
}

class _FarmerProfileViewState extends State<FarmerProfileView> {
  final TextEditingController _moistureController = TextEditingController();
  final TextEditingController _ndviController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final farm = context.read<FarmProvider>();
    if (farm.constraints.manualSoilMoisture != null) {
      _moistureController.text = farm.constraints.manualSoilMoisture!.toString();
    }
    if (farm.constraints.manualNdvi != null) {
      _ndviController.text = farm.constraints.manualNdvi!.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final farm = context.watch<FarmProvider>();
    final auth = context.watch<AuthProvider>();
    final c = farm.constraints;
    final assessment = farm.cropAssessment;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    farm.tr('farmer_profile'),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.primary),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Farm Priorities, Equipment & Field Inputs',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                ],
              ),
              // Simple Mode Switch
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(farm.tr('farmer_mode'), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                  Switch(
                    value: farm.isSimpleFarmerMode,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) => farm.toggleSimpleFarmerMode(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Authenticated Farmer Account & Firebase Cloud Sync Card
          _buildAccountCard(context, auth, auth.currentUser),
          const SizedBox(height: 14),

          // Language & Accessibility Preference Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryMuted,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.language, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'APP INTERFACE LANGUAGE (MULTILINGUAL)',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: AppColors.primary),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Select preferred regional language for instructions, alerts, and advisories:',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: farm.currentLanguage,
                      isDense: true,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark),
                      items: LocalizationService.supportedLanguages.entries.map((e) {
                        return DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value),
                        );
                      }).toList(),
                      onChanged: (code) {
                        if (code != null) farm.setLanguage(code);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 1. Farmer Priorities Card
          Container(
            padding: const EdgeInsets.all(18),
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
                    Icon(Icons.flag_outlined, size: 18, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'PRIMARY FARMING PRIORITY',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Select what matters most for this parcel. The rotation engine re-ranks strategies according to your choice.',
                  style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                ),
                const SizedBox(height: 14),
                ...FarmerPriority.values.map((p) {
                  final isSel = c.priority == p;
                  return InkWell(
                    onTap: () => farm.updatePriority(p),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSel ? AppColors.primaryMuted.withValues(alpha: 0.5) : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSel ? AppColors.primary : AppColors.borderLight,
                          width: isSel ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSel ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                            color: isSel ? AppColors.primary : AppColors.textSubtle,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.label,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  p.description,
                                  style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Water & Irrigation System Card
          Container(
            padding: const EdgeInsets.all(18),
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
                    Icon(Icons.water_drop, size: 18, color: AppColors.waterBlue),
                    SizedBox(width: 8),
                    Text(
                      'WATER AVAILABILITY & IRRIGATION METHOD',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: AppColors.waterBlue),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Your water source directly influences the feasibility of high-demand rotations.',
                  style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: IrrigationSystem.values.map((irrig) {
                    final isSel = c.irrigation == irrig;
                    return ChoiceChip(
                      label: Text(irrig.label),
                      selected: isSel,
                      selectedColor: const Color(0xFFE1F5FE),
                      backgroundColor: AppColors.surfaceLight,
                      labelStyle: TextStyle(
                        fontSize: 11.5,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                        color: isSel ? const Color(0xFF0277BD) : AppColors.textDark,
                      ),
                      side: BorderSide(color: isSel ? const Color(0xFF0277BD) : AppColors.borderLight),
                      onSelected: (val) {
                        if (val) farm.setConstraints(c.copyWith(irrigation: irrig));
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Equipment & Mechanization Limitations
          Container(
            padding: const EdgeInsets.all(18),
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
                    Icon(Icons.handyman_outlined, size: 18, color: AppColors.warningAmber),
                    SizedBox(width: 8),
                    Text(
                      'EQUIPMENT & MECHANIZATION CONSTRAINTS',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: AppColors.warningAmber),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Select implements available on your farm or through custom-hire centers:',
                  style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: EquipmentLevel.values.map((eq) {
                    final isSel = c.equipment.contains(eq);
                    return FilterChip(
                      label: Text(eq.label),
                      selected: isSel,
                      selectedColor: const Color(0xFFFFF3E0),
                      backgroundColor: AppColors.surfaceLight,
                      labelStyle: TextStyle(
                        fontSize: 11.5,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                        color: isSel ? const Color(0xFFE65100) : AppColors.textDark,
                      ),
                      side: BorderSide(color: isSel ? const Color(0xFFE65100) : AppColors.borderLight),
                      onSelected: (selected) {
                        final list = List<EquipmentLevel>.from(c.equipment);
                        if (selected) {
                          list.add(eq);
                        } else {
                          list.remove(eq);
                        }
                        farm.setConstraints(c.copyWith(equipment: list));
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 4. Market Access & Economic Channels
          Container(
            padding: const EdgeInsets.all(18),
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
                    Icon(Icons.storefront_outlined, size: 18, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'MARKET ACCESS & COMMERCIAL PREFERENCE',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Where do you plan to market new rotation crops (pulses, oilseeds, forages)?',
                  style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: MarketAccessType.values.map((m) {
                    final isSel = c.marketAccess == m;
                    return ChoiceChip(
                      label: Text(m.label),
                      selected: isSel,
                      selectedColor: const Color(0xFFE8F5E9),
                      backgroundColor: AppColors.surfaceLight,
                      labelStyle: TextStyle(
                        fontSize: 11.5,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                        color: isSel ? const Color(0xFF2E7D32) : AppColors.textDark,
                      ),
                      side: BorderSide(color: isSel ? const Color(0xFF2E7D32) : AppColors.borderLight),
                      onSelected: (val) {
                        if (val) farm.setConstraints(c.copyWith(marketAccess: m));
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 5. Optional In-Situ Field Measurements (Overrides SMAP)
          Container(
            padding: const EdgeInsets.all(18),
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
                        Icon(Icons.sensors, size: 18, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text(
                          'IN-SITU FIELD SENSOR INPUTS',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: AppColors.primary),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('OVERRIDES SMAP', style: TextStyle(fontSize: 8.5, color: AppColors.textSubtle, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'If you have a capacitive soil probe or recent drone/multispectral NDVI scan, enter values here. Otherwise, NASA satellite defaults are used automatically.',
                  style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _moistureController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Soil Moisture (m³/m³)',
                          hintText: farm.summary?.meanRootZoneMoisture != null
                              ? 'NASA SMAP: ${farm.summary!.meanRootZoneMoisture!.toStringAsFixed(3)}'
                              : 'e.g. 0.22',
                          suffixText: 'm³/m³',
                        ),
                        onChanged: (val) {
                          final v = double.tryParse(val);
                          if (v != null && v >= 0 && v <= 1.0) {
                            farm.setConstraints(c.copyWith(manualSoilMoisture: v));
                          } else if (val.isEmpty) {
                            farm.setConstraints(c.copyWith(clearManualMoisture: true));
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _ndviController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Field NDVI Mean (-1 to 1)',
                          hintText: 'e.g. 0.64',
                        ),
                        onChanged: (val) {
                          final v = double.tryParse(val);
                          if (v != null && v >= -1.0 && v <= 1.0) {
                            farm.setConstraints(c.copyWith(manualNdvi: v));
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 6. Rule-Based Crop Stress & Suitability Screening Result
          if (assessment != null) ...[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFC7E2D1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.eco, size: 18, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text(
                            'TRANSPARENT RULE-BASED CROP ASSESSMENT',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: AppColors.primary),
                          ),
                        ],
                      ),
                      Text('RULE-BASED · NO BLACK BOX', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: AppColors.textSubtle)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Crop Stress Level', style: TextStyle(fontSize: 10, color: AppColors.textSubtle, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 3),
                              Text(
                                assessment.stressPrediction,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: assessment.stressScore > 50 ? AppColors.alertRed : AppColors.resilientGreen,
                                ),
                              ),
                              Text('Screening Score: ${assessment.stressScore}/100', style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Climate Suitability Index', style: TextStyle(fontSize: 10, color: AppColors.textSubtle, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 3),
                              Text(
                                '${assessment.suitabilityIndex}/100',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary),
                              ),
                              Text(assessment.suitabilityCategory, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.primaryLight)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Contributing Screening Factors:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 4),
                  ...assessment.reasons.map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 3.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                            Expanded(child: Text(r, style: const TextStyle(fontSize: 11, color: AppColors.textMuted))),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),

          // About FieldShift AI Card with Logo
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FieldShift AI v1.0.0',
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.textDark),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'NASA Space Apps Challenge 2026\nAdapting Farms with NASA Earth Observations',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Export / Share Farm Profile Action Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.share, size: 16),
              label: const Text('Export Full Farm Decision Brief to Clipboard'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                final report = farm.exportAdvisoryReportText();
                Clipboard.setData(ClipboardData(text: report));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Farm profile and advisory report copied to clipboard!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 36),
        ],
      ),
    );
  }

  Widget _buildAccountCard(BuildContext context, AuthProvider auth, AppUser? user) {
    final isGuest = user?.isAnonymous ?? true;
    final name = user?.displayName.isNotEmpty == true ? user!.displayName : 'Farmer Steward';
    final email = user?.email.isNotEmpty == true ? user!.email : 'Unregistered Field Guest';
    final farmName = user?.farmName.isNotEmpty == true ? user!.farmName : 'My Resilient Farm';
    final initials = name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: isGuest ? AppColors.secondary.withValues(alpha: 0.2) : AppColors.primary,
                child: Text(
                  initials.isNotEmpty ? initials : 'FS',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isGuest ? AppColors.secondary : Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: isGuest ? AppColors.riskMedium.withValues(alpha: 0.12) : AppColors.resilientGreen.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isGuest ? 'Guest Mode' : 'Firebase Verified',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: isGuest ? AppColors.riskMedium : AppColors.resilientGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$farmName · $email',
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Sign Out',
                icon: const Icon(Icons.logout, size: 20, color: AppColors.riskHigh),
                onPressed: () => _confirmSignOut(context, auth),
              ),
            ],
          ),
          if (isGuest) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cloud_upload_outlined, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Sign in or create an account to synchronize custom farm boundaries and multi-year rotation plans to Firebase Cloud.',
                      style: TextStyle(fontSize: 10.5, color: AppColors.textMuted, height: 1.3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => auth.logout(),
                    child: const Text('Sign In', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to sign out of your farm workspace?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.riskHigh),
            onPressed: () {
              Navigator.pop(ctx);
              auth.logout();
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

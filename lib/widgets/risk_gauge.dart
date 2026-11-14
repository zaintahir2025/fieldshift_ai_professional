import 'package:flutter/material.dart';
import '../services/climate_risk_engine.dart';
import '../theme/app_theme.dart';

class RiskGaugeCard extends StatelessWidget {
  final FarmRiskScore? risk;

  const RiskGaugeCard({super.key, required this.risk});

  @override
  Widget build(BuildContext context) {
    final score = risk?.overallSuitabilityScore ?? 0;
    final color = score >= 70
        ? AppColors.resilientGreen
        : (score >= 45 ? AppColors.warningAmber : AppColors.alertRed);

    return Container(
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
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryMuted,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.speed, color: AppColors.primary, size: 18),
                    ),
                    const SizedBox(width: 8),
                    const Flexible(
                      child: Text(
                        'CLIMATE SUITABILITY INDEX',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: AppColors.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4F1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: const Text(
                  'HEURISTIC PROTOTYPE',
                  style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: AppColors.textMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                risk != null ? '$score' : '—',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  color: color,
                  letterSpacing: -1,
                ),
              ),
              const Text(
                ' / 100',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSubtle),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  risk?.statusLabel ?? 'Awaiting Data',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (score / 100.0).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: const Color(0xFFE9EFEA),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Underlying Risk Signals (0–100 Scale):',
            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.textMuted),
          ),
          const SizedBox(height: 8),
          _buildRiskRow(
            label: 'Heat Exposure Indicator',
            value: risk?.heatExposureScore ?? 0,
            icon: Icons.thermostat,
            color: AppColors.warningAmber,
          ),
          const SizedBox(height: 6),
          _buildRiskRow(
            label: 'Rainfall Deficit Proxy',
            value: risk?.droughtDeficitScore ?? 0,
            icon: Icons.water_drop_outlined,
            color: AppColors.waterBlue,
          ),
          const SizedBox(height: 6),
          _buildRiskRow(
            label: 'Surface Solar Irradiance',
            value: risk?.solarScore ?? 0,
            icon: Icons.wb_sunny_outlined,
            color: AppColors.solarYellow,
          ),
          const SizedBox(height: 12),
          const Text(
            'Transparent screening heuristic combining NASA POWER observations. High score indicates lower climatic stress. Not a certified yield prediction.',
            style: TextStyle(fontSize: 9.5, color: AppColors.textSubtle, height: 1.35),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskRow({
    required String label,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textDark, fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          '$value/100',
          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}

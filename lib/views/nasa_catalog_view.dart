import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/farm_provider.dart';
import '../models/nasa_observation.dart';
import '../theme/app_theme.dart';

class NasaCatalogView extends StatelessWidget {
  const NasaCatalogView({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showReportDialog(BuildContext context, String reportTitle, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(reportTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 550,
          height: 380,
          child: SingleChildScrollView(
            child: SelectableText(
              content,
              style: const TextStyle(fontSize: 11, fontFamily: 'monospace', height: 1.4),
            ),
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: content));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied report to clipboard!')),
              );
            },
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('Copy to Clipboard'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final farm = context.watch<FarmProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NASA EARTH OBSERVATION ARCHITECTURE',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.primary),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Dataset Catalog & Scientific Transparency',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  _launchUrl('https://www.spaceappschallenge.org/2026/challenges/adapting-farms-with-nasa-data/?tab=resources');
                },
                icon: const Icon(Icons.open_in_new, size: 14),
                label: const Text('Space Apps Resources'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Export & Extension Actions Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DATA EXPORT & EXTENSION ADVISORY TOOLS',
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: 0.6),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Export raw NASA daily records or print a structured advisory summary for local extension officers.',
                        style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    final csv = farm.exportObservationsCsv();
                    _showReportDialog(context, 'NASA POWER Daily Observations (CSV)', csv);
                  },
                  icon: const Icon(Icons.table_view, size: 15),
                  label: const Text('Export CSV'),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    final report = farm.generateAdvisoryReport();
                    _showReportDialog(context, 'FieldShift Agronomic Advisory Summary', report);
                  },
                  icon: const Icon(Icons.description_outlined, size: 15),
                  label: const Text('Generate Advisory Report'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // NASA Datasets Catalog Cards
          const Text(
            'INTEGRATED NASA SATELLITE MISSIONS & SENSORS',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.7, color: AppColors.primary),
          ),
          const SizedBox(height: 10),

          ...NasaDatasetMetadata.catalog.map((meta) {
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primaryMuted,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                meta.shortCode,
                                style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.primary),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              meta.fullName,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
                            ),
                            Text(
                              meta.agency,
                              style: const TextStyle(fontSize: 11, color: AppColors.textSubtle),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F8F4),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFC7E2D1)),
                        ),
                        child: Text(
                          meta.liveStatus,
                          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF1B4332)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    meta.primaryApplication,
                    style: const TextStyle(fontSize: 12, color: AppColors.textDark, height: 1.35),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _buildSpecPill(Icons.tune, 'Params: ${meta.parameters}'),
                      _buildSpecPill(Icons.grid_4x4, 'Res: ${meta.spatialResolution}'),
                      _buildSpecPill(Icons.schedule, 'Freq: ${meta.temporalResolution}'),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Scientific Caveats & Resolution Considerations:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSubtle)),
                        const SizedBox(height: 4),
                        ...meta.scientificCaveats.map((c) => Padding(
                              padding: const EdgeInsets.only(bottom: 2.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• ', style: TextStyle(color: AppColors.warningAmber, fontWeight: FontWeight.bold)),
                                  Expanded(child: Text(c, style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted))),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => _launchUrl(meta.officialDocUrl),
                      icon: const Icon(Icons.open_in_new, size: 13),
                      label: const Text('Official Documentation & API', style: TextStyle(fontSize: 11)),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSpecPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSubtle),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

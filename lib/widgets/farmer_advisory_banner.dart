import 'package:flutter/material.dart';

class FarmerAdvisoryBanner extends StatelessWidget {
  final VoidCallback? onLearnMore;

  const FarmerAdvisoryBanner({super.key, this.onLearnMore});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8F4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC7E2D1), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFF2D6A4F).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.psychology_alt_outlined, color: Color(0xFF1B4332), size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'FARMER-CENTERED DECISION SUPPORT',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.7,
                        color: Color(0xFF1B4332),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D6A4F),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'HUMAN IN THE LOOP',
                        style: TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'This platform translates NASA Earth observations to identify patterns and possibilities. It is designed to support—not replace—local farmer judgment, traditional knowledge, and agricultural extension expertise.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF384A3E), height: 1.35),
                ),
                if (onLearnMore != null) ...[
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: onLearnMore,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 2.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Scientific Transparency & Data Limits',
                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF2D6A4F)),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_ios, size: 9, color: Color(0xFF2D6A4F)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

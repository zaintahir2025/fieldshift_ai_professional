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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFF2D6A4F).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.psychology_alt_outlined, color: Color(0xFF1B4332), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text(
                      'FARMER-CENTERED DECISION SUPPORT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.7,
                        color: Color(0xFF1B4332),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D6A4F),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'HUMAN IN THE LOOP',
                        style: TextStyle(fontSize: 8.5, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                const Text(
                  'This platform translates NASA Earth observations to identify patterns and possibilities. It is designed to support—not replace—local farmer judgment, traditional knowledge, and agricultural extension expertise.',
                  style: TextStyle(fontSize: 11.5, color: Color(0xFF384A3E), height: 1.35),
                ),
              ],
            ),
          ),
          if (onLearnMore != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onLearnMore,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF1B4332),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Transparency', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  Icon(Icons.arrow_forward_ios, size: 10),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

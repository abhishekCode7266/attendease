import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Progress bar displaying student attendance percentage with threshold warning colors
class AttendanceProgressBar extends StatelessWidget {
  final double percentage; // 0 to 100
  final double height;
  final bool showLabel;
  final bool showWarningBadge;

  const AttendanceProgressBar({
    super.key,
    required this.percentage,
    this.height = 10.0,
    this.showLabel = true,
    this.showWarningBadge = true,
  });

  Color get progressColor {
    if (percentage < AppConstants.attendanceThreshold) {
      return const Color(0xFFEF4444); // Red (< 75%)
    } else if (percentage < 85.0) {
      return const Color(0xFFF59E0B); // Amber (75% - 85%)
    } else {
      return const Color(0xFF10B981); // Green (> 85%)
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final normalized = (percentage / 100.0).clamp(0.0, 1.0);
    final isShortage = percentage < AppConstants.attendanceThreshold;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Overall Attendance',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                  if (isShortage && showWarningBadge) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, size: 12, color: Color(0xFFEF4444)),
                          SizedBox(width: 3),
                          Text(
                            'Below 75%',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFEF4444),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: progressColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Stack(
          children: [
            Container(
              height: height,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
            FractionallySizedBox(
              widthFactor: normalized,
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  color: progressColor,
                  borderRadius: BorderRadius.circular(height / 2),
                  boxShadow: [
                    BoxShadow(
                      color: progressColor.withOpacity(0.35),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

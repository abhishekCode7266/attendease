import 'package:flutter/material.dart';
import '../models/attendance_model.dart';
import '../utils/constants.dart';

/// AttendanceTile provides quick one-tap marking options (Present / Absent / Late) for a student
class AttendanceTile extends StatelessWidget {
  final AttendanceWithStudent item;
  final ValueChanged<AttendanceStatus> onStatusChanged;

  const AttendanceTile({
    super.key,
    required this.item,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentStatus = item.status;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? (isDark ? const Color(0xFF1E293B) : Colors.white),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: currentStatus.color.withOpacity(0.15),
            child: Text(
              item.student.initials,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: currentStatus.color,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.student.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.student.rollNo} • ${item.student.className}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Interactive Status Action Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatusPill(
                label: 'P',
                status: AttendanceStatus.present,
                selected: currentStatus == AttendanceStatus.present,
                activeColor: const Color(0xFF10B981),
              ),
              const SizedBox(width: 6),
              _buildStatusPill(
                label: 'A',
                status: AttendanceStatus.absent,
                selected: currentStatus == AttendanceStatus.absent,
                activeColor: const Color(0xFFEF4444),
              ),
              const SizedBox(width: 6),
              _buildStatusPill(
                label: 'L',
                status: AttendanceStatus.late,
                selected: currentStatus == AttendanceStatus.late,
                activeColor: const Color(0xFFF59E0B),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill({
    required String label,
    required AttendanceStatus status,
    required bool selected,
    required Color activeColor,
  }) {
    return InkWell(
      onTap: () => onStatusChanged(status),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? activeColor : activeColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? activeColor : activeColor.withOpacity(0.3),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.35),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : activeColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

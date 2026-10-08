import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/attendance_model.dart';
import '../providers/attendance_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../utils/date_helper.dart';

/// MyAttendanceScreen displays student's attendance history and color-coded monthly calendar
class MyAttendanceScreen extends StatefulWidget {
  const MyAttendanceScreen({super.key});

  @override
  State<MyAttendanceScreen> createState() => _MyAttendanceScreenState();
}

class _MyAttendanceScreenState extends State<MyAttendanceScreen> {
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  String _selectedSubject = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.userId != null) {
        Provider.of<AttendanceProvider>(context, listen: false)
            .loadStudentDashboard(auth.userId!);
      }
    });
  }

  void _shiftMonth(int offset) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + offset, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final attProv = Provider.of<AttendanceProvider>(context);

    // Map date strings (yyyy-MM-dd) to AttendanceModel for quick lookup in calendar
    final historyMap = <String, AttendanceModel>{};
    for (final rec in attProv.studentAttendanceHistory) {
      if (_selectedSubject == 'All' || rec.subject == _selectedSubject) {
        historyMap[rec.date] = rec;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Attendance Record'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Navigation & Subject Filter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded),
                      onPressed: () => _shiftMonth(-1),
                    ),
                    Text(
                      DateHelper.formatMonthYear(_currentMonth),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded),
                      onPressed: () => _shiftMonth(1),
                    ),
                  ],
                ),
                DropdownButton<String>(
                  value: _selectedSubject,
                  underline: const SizedBox(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                  items: ['All', ...AppConstants.defaultSubjects].map((s) {
                    return DropdownMenuItem(
                      value: s,
                      child: Text(s.length > 15 ? '${s.substring(0, 15)}...' : s),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedSubject = val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Monthly Calendar Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardTheme.color ?? (isDark ? const Color(0xFF1E293B) : Colors.white),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                children: [
                  // Weekday headers
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((day) {
                      return SizedBox(
                        width: 38,
                        child: Text(
                          day,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 10),

                  // Calendar Days Grid
                  _buildCalendarGrid(historyMap),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Color Legend
            Wrap(
              spacing: 14,
              runSpacing: 8,
              children: [
                _buildLegendItem('Present', const Color(0xFF10B981)),
                _buildLegendItem('Absent', const Color(0xFFEF4444)),
                _buildLegendItem('Late', const Color(0xFFF59E0B)),
                _buildLegendItem('Leave', const Color(0xFF3B82F6)),
                _buildLegendItem('Holiday/None', const Color(0xFF94A3B8)),
              ],
            ),
            const SizedBox(height: 22),

            // Date-wise History List
            const Text(
              'Detailed History',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),

            if (attProv.studentAttendanceHistory.isEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text('No attendance records found.', style: TextStyle(color: Colors.grey)),
                ),
              ),
            ] else ...[
              ...attProv.studentAttendanceHistory.map((rec) {
                if (_selectedSubject != 'All' && rec.subject != _selectedSubject) {
                  return const SizedBox.shrink();
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color ?? (isDark ? const Color(0xFF1E293B) : Colors.white),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: rec.status.color.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(rec.status.icon, color: rec.status.color, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateHelper.formatDbToDisplay(rec.date),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              rec.subject,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: rec.status.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: rec.status.color.withOpacity(0.3)),
                        ),
                        child: Text(
                          rec.status.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: rec.status.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(Map<String, AttendanceModel> historyMap) {
    final year = _currentMonth.year;
    final month = _currentMonth.month;
    final totalDays = DateTime(year, month + 1, 0).day;
    final firstWeekday = DateTime(year, month, 1).weekday; // 1 = Monday, 7 = Sunday

    final daysList = <Widget>[];

    // Leading empty slots
    for (int i = 1; i < firstWeekday; i++) {
      daysList.add(const SizedBox(width: 38, height: 42));
    }

    // Month days
    for (int day = 1; day <= totalDays; day++) {
      final date = DateTime(year, month, day);
      final dateStr = DateHelper.formatDbDate(date);
      final record = historyMap[dateStr];
      final isToday = DateHelper.isToday(date);

      Color? dotColor;
      if (record != null) {
        dotColor = record.status.color;
      }

      daysList.add(
        Container(
          width: 38,
          height: 42,
          alignment: Alignment.center,
          decoration: isToday
              ? BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                )
              : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$day',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: dotColor ?? Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Wrap(
      alignment: WrapAlignment.start,
      spacing: 6,
      runSpacing: 4,
      children: daysList,
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

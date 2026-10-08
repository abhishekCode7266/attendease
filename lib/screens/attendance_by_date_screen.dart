import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/attendance_provider.dart';
import '../utils/constants.dart';
import '../utils/date_helper.dart';
import '../widgets/attendance_tile.dart';

/// AttendanceByDateScreen allows Admin to view, mark, and edit attendance for any selected date
class AttendanceByDateScreen extends StatefulWidget {
  const AttendanceByDateScreen({super.key});

  @override
  State<AttendanceByDateScreen> createState() => _AttendanceByDateScreenState();
}

class _AttendanceByDateScreenState extends State<AttendanceByDateScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AttendanceProvider>(context, listen: false).loadAttendanceForSelectedDate();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final attProv = Provider.of<AttendanceProvider>(context, listen: false);
    final picked = await showDatePicker(
      context: context,
      initialDate: attProv.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null) {
      attProv.setSelectedDate(picked);
    }
  }

  void _shiftDate(int dayOffset) {
    final attProv = Provider.of<AttendanceProvider>(context, listen: false);
    final newDate = attProv.selectedDate.add(Duration(days: dayOffset));
    attProv.setSelectedDate(newDate);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final attProv = Provider.of<AttendanceProvider>(context);

    final stats = attProv.dailyStats;
    final isSelectedDateToday = DateHelper.isToday(attProv.selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Date-wise Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reload',
            onPressed: () => attProv.loadAttendanceForSelectedDate(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Date Selector Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  tooltip: 'Previous Day',
                  onPressed: () => _shiftDate(-1),
                ),
                InkWell(
                  onTap: () => _selectDate(context),
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_month_rounded, color: theme.colorScheme.primary, size: 20),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              DateHelper.formatDisplay(attProv.selectedDate),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              isSelectedDateToday
                                  ? 'Today • ${DateHelper.getDayOfWeek(attProv.selectedDate)}'
                                  : DateHelper.getDayOfWeek(attProv.selectedDate),
                              style: TextStyle(
                                fontSize: 11,
                                color: isSelectedDateToday
                                    ? const Color(0xFF10B981)
                                    : (isDark ? Colors.white60 : Colors.black54),
                                fontWeight: isSelectedDateToday ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded),
                  tooltip: 'Next Day',
                  onPressed: () => _shiftDate(1),
                ),
              ],
            ),
          ),

          // Filters: Class & Subject
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              border: Border(
                bottom: BorderSide(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
            ),
            child: Row(
              children: [
                // Subject Dropdown
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    value: attProv.selectedSubject,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      isDense: true,
                      labelText: 'Subject',
                    ),
                    items: AppConstants.defaultSubjects.map((sub) {
                      return DropdownMenuItem(
                        value: sub,
                        child: Text(
                          sub,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) attProv.setSelectedSubject(val);
                    },
                  ),
                ),
                const SizedBox(width: 10),

                // Class Dropdown
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: attProv.selectedClass,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      isDense: true,
                      labelText: 'Class',
                    ),
                    items: ['All', ...AppConstants.defaultClasses].map((cls) {
                      return DropdownMenuItem(
                        value: cls,
                        child: Text(
                          cls,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) attProv.setSelectedClass(val);
                    },
                  ),
                ),
              ],
            ),
          ),

          // Summary Stats Strip & Batch Mark Actions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatPill('Present', '${stats["present"] ?? 0}', const Color(0xFF10B981)),
                    _buildStatPill('Absent', '${stats["absent"] ?? 0}', const Color(0xFFEF4444)),
                    _buildStatPill('Late', '${stats["late"] ?? 0}', const Color(0xFFF59E0B)),
                    _buildStatPill('Not Marked', '${stats["not_marked"] ?? 0}', const Color(0xFF94A3B8)),
                  ],
                ),
                const SizedBox(height: 10),

                // Batch Actions Row
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.done_all_rounded, size: 16, color: Color(0xFF10B981)),
                        label: const Text('Mark All Present', style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          minimumSize: const Size(0, 36),
                        ),
                        onPressed: () => attProv.batchMarkStatus(AttendanceStatus.present),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.remove_circle_outline_rounded, size: 16, color: Color(0xFFEF4444)),
                        label: const Text('Mark All Absent', style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          minimumSize: const Size(0, 36),
                        ),
                        onPressed: () => attProv.batchMarkStatus(AttendanceStatus.absent),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // List of Students for Date
          Expanded(
            child: attProv.isLoading
                ? const Center(child: CircularProgressIndicator())
                : attProv.dateAttendanceList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.fact_check_outlined,
                              size: 56,
                              color: isDark ? Colors.white24 : Colors.black26,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No enrolled students in this class/section.',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 20),
                        itemCount: attProv.dateAttendanceList.length,
                        itemBuilder: (context, index) {
                          final item = attProv.dateAttendanceList[index];
                          return AttendanceTile(
                            item: item,
                            onStatusChanged: (newStatus) {
                              if (item.student.id != null) {
                                attProv.setStudentAttendanceStatus(
                                  studentId: item.student.id!,
                                  status: newStatus,
                                );
                              }
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

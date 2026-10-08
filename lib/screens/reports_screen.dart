import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/attendance_provider.dart';
import '../utils/constants.dart';
import '../widgets/attendance_progress_bar.dart';

/// ReportsScreen aggregates student attendance analytics and highlights shortage students below 75%
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedClass = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AttendanceProvider>(context, listen: false).loadAllReports();
    });
  }

  void _onClassChanged(String className) {
    setState(() => _selectedClass = className);
    Provider.of<AttendanceProvider>(context, listen: false).loadAllReports(
      className: className,
    );
  }

  void _simulateExport(String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Attendance report generated successfully ($format exported locally).'),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final attProv = Provider.of<AttendanceProvider>(context);

    final summaries = attProv.allStudentsSummaries;
    final belowThresholdList = summaries.where((s) => s.isBelowThreshold).toList();

    // Calculate class average
    double totalPct = 0;
    for (final s in summaries) {
      totalPct += s.percentage;
    }
    final classAverage = summaries.isNotEmpty ? (totalPct / summaries.length).toStringAsFixed(1) : '0.0';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Export PDF Report',
            onPressed: () => _simulateExport('PDF'),
          ),
          IconButton(
            icon: const Icon(Icons.table_view_outlined),
            tooltip: 'Export CSV / Excel',
            onPressed: () => _simulateExport('Excel'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter by Class:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                DropdownButton<String>(
                  value: _selectedClass,
                  underline: const SizedBox(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                  items: ['All', ...AppConstants.defaultClasses].map((c) {
                    return DropdownMenuItem(value: c, child: Text(c));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) _onClassChanged(val);
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: attProv.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => attProv.loadAllReports(className: _selectedClass),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // KPI Metric Cards
                          Row(
                            children: [
                              Expanded(
                                child: _buildKpiCard(
                                  title: 'Class Average',
                                  value: '$classAverage%',
                                  color: double.parse(classAverage) >= 75.0
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFEF4444),
                                  icon: Icons.analytics_rounded,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildKpiCard(
                                  title: 'Enrolled',
                                  value: '${summaries.length}',
                                  color: theme.colorScheme.primary,
                                  icon: Icons.people_outline_rounded,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildKpiCard(
                                  title: 'Shortage (<75%)',
                                  value: '${belowThresholdList.length}',
                                  color: belowThresholdList.isNotEmpty
                                      ? const Color(0xFFDC2626)
                                      : const Color(0xFF10B981),
                                  icon: Icons.warning_rounded,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // HIGHLIGHTED SECTION: Students Below 75% Attendance (Red Alert)
                          if (belowThresholdList.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFF87171), width: 1.5),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.report_problem_rounded, color: Color(0xFFDC2626), size: 22),
                                      SizedBox(width: 8),
                                      Text(
                                        'CRITICAL: Attendance Shortage (<75%)',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF991B1B),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'The following students have less than 75% attendance and risk debarment from semester exams:',
                                    style: TextStyle(fontSize: 11, color: Color(0xFFB91C1C)),
                                  ),
                                  const SizedBox(height: 12),
                                  ...belowThresholdList.map((student) {
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: const Color(0xFFFCA5A5)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  student.studentName,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF0F172A),
                                                  ),
                                                ),
                                                Text(
                                                  '${student.rollNo} • ${student.className}',
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Color(0xFF64748B),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                '${student.percentage.toStringAsFixed(1)}%',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w800,
                                                  color: Color(0xFFDC2626),
                                                ),
                                              ),
                                              Text(
                                                '${student.presentDays}/${student.totalDays} days',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFFEF4444),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // All Students Detailed List
                          const Text(
                            'Student-by-Student Attendance Summary',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 12),

                          if (summaries.isEmpty) ...[
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24),
                                child: Text('No student records found.', style: TextStyle(color: Colors.grey)),
                              ),
                            ),
                          ] else ...[
                            ...summaries.map((item) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: theme.cardTheme.color ?? (isDark ? const Color(0xFF1E293B) : Colors.white),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: item.isBelowThreshold
                                        ? const Color(0xFFFCA5A5)
                                        : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                    width: item.isBelowThreshold ? 1.5 : 1.0,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.studentName,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          '${item.presentDays}/${item.totalDays} Days',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${item.rollNo} • ${item.className}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    AttendanceProgressBar(
                                      percentage: item.percentage,
                                      height: 8,
                                      showLabel: true,
                                      showWarningBadge: true,
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

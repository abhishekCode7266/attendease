import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/student_model.dart';
import '../providers/attendance_provider.dart';
import '../providers/student_provider.dart';
import '../utils/constants.dart';
import '../widgets/student_tile.dart';
import 'add_edit_student_screen.dart';

/// StudentListScreen displays all enrolled students with search, class filtering, and CRUD
class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StudentProvider>(context, listen: false).loadStudents();
      Provider.of<AttendanceProvider>(context, listen: false).loadAllReports();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _confirmDeleteStudent(StudentModel student) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444)),
              SizedBox(width: 8),
              Text('Remove Student?'),
            ],
          ),
          content: Text(
            'Are you sure you want to delete ${student.name} (Roll No: ${student.rollNo})?\n\nThis will permanently delete all associated attendance and leave records.',
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                if (student.id == null) return;
                final provider = Provider.of<StudentProvider>(context, listen: false);
                final success = await provider.deleteStudent(student.id!);
                if (!mounted) return;
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${student.name} deleted successfully.'),
                      backgroundColor: const Color(0xFF10B981),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(provider.errorMessage ?? 'Failed to delete student.'),
                      backgroundColor: const Color(0xFFEF4444),
                    ),
                  );
                }
              },
              child: const Text('Delete Student'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final studentProv = Provider.of<StudentProvider>(context);
    final attProv = Provider.of<AttendanceProvider>(context);

    // Map student IDs to attendance percentages for visual chips
    final summaryMap = <int, double>{};
    for (final s in attProv.allStudentsSummaries) {
      summaryMap[s.studentId] = s.percentage;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Directory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reload',
            onPressed: () => studentProv.loadStudents(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (val) => studentProv.setSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: 'Search by student name or roll number...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 22),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              studentProv.setSearchQuery('');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 8),

                // Class Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildClassFilterChip('All', studentProv),
                      ...AppConstants.defaultClasses.map(
                        (className) => _buildClassFilterChip(className, studentProv),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Student Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${studentProv.students.length} Student${studentProv.students.length == 1 ? "" : "s"} Enrolled',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                Text(
                  'Highlight in Red: Below 75%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFEF4444).withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          // Student List / Empty State
          Expanded(
            child: studentProv.isLoading
                ? const Center(child: CircularProgressIndicator())
                : studentProv.students.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_off_rounded,
                              size: 64,
                              color: isDark ? Colors.white24 : Colors.black26,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              studentProv.searchQuery.isNotEmpty
                                  ? 'No students found matching "${studentProv.searchQuery}"'
                                  : 'No students enrolled yet',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Tap the "+" button below to add your first student.',
                              style: TextStyle(fontSize: 13, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => studentProv.loadStudents(),
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 80, top: 4),
                          itemCount: studentProv.students.length,
                          itemBuilder: (context, index) {
                            final student = studentProv.students[index];
                            final pct = summaryMap[student.id];

                            return StudentTile(
                              student: student,
                              attendancePercentage: pct,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => AddEditStudentScreen(student: student),
                                  ),
                                );
                              },
                              onEdit: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => AddEditStudentScreen(student: student),
                                  ),
                                );
                              },
                              onDelete: () => _confirmDeleteStudent(student),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Student'),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddEditStudentScreen()),
          );
        },
      ),
    );
  }

  Widget _buildClassFilterChip(String className, StudentProvider provider) {
    final isSelected = provider.selectedClass == className;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        selected: isSelected,
        label: Text(
          className,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : null,
          ),
        ),
        selectedColor: theme.colorScheme.primary,
        checkmarkColor: Colors.white,
        onSelected: (_) => provider.setSelectedClass(className),
      ),
    );
  }
}

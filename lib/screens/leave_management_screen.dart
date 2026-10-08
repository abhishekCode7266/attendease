import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/leave_model.dart';
import '../providers/auth_provider.dart';
import '../providers/leave_provider.dart';
import '../utils/constants.dart';
import '../utils/date_helper.dart';
import '../utils/validators.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

/// LeaveManagementScreen manages leave applications for students and approval workflows for admins
class LeaveManagementScreen extends StatefulWidget {
  final bool isAdminView;

  const LeaveManagementScreen({super.key, this.isAdminView = false});

  @override
  State<LeaveManagementScreen> createState() => _LeaveManagementScreenState();
}

class _LeaveManagementScreenState extends State<LeaveManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  DateTime _fromDate = DateTime.now().add(const Duration(days: 1));
  DateTime _toDate = DateTime.now().add(const Duration(days: 2));
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLeaves();
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _loadLeaves() async {
    final leaveProv = Provider.of<LeaveProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (widget.isAdminView || auth.isAdmin) {
      await leaveProv.loadAllLeaves();
    } else if (auth.userId != null) {
      await leaveProv.loadStudentLeaves(auth.userId!);
    }
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      initialDateRange: DateTimeRange(start: _fromDate, end: _toDate),
    );

    if (picked != null) {
      setState(() {
        _fromDate = picked.start;
        _toDate = picked.end;
      });
    }
  }

  Future<void> _submitLeave() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.userId == null) return;

    setState(() => _isSubmitting = true);
    final leaveProv = Provider.of<LeaveProvider>(context, listen: false);

    final leave = LeaveModel(
      studentId: auth.userId!,
      fromDate: DateHelper.formatDbDate(_fromDate),
      toDate: DateHelper.formatDbDate(_toDate),
      reason: _reasonController.text.trim(),
      status: LeaveStatus.pending,
      appliedAt: DateTime.now().toIso8601String(),
    );

    final success = await leaveProv.applyLeave(leave);
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      _reasonController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Leave request submitted successfully!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(leaveProv.errorMessage ?? 'Failed to submit leave.'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final leaveProv = Provider.of<LeaveProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    final isAdmin = widget.isAdminView || auth.isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'Review Leave Requests' : 'Leave Application'),
      ),
      body: isAdmin ? _buildAdminView(leaveProv) : _buildStudentView(leaveProv),
    );
  }

  Widget _buildStudentView(LeaveProvider leaveProv) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Application Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardTheme.color ?? (isDark ? const Color(0xFF1E293B) : Colors.white),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Apply for Leave',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),

                  // Date range selector
                  InkWell(
                    onTap: _pickDateRange,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.calendar_month_rounded, color: theme.colorScheme.primary, size: 20),
                              const SizedBox(width: 10),
                              Text(
                                '${DateHelper.formatDisplay(_fromDate)}  ➔  ${DateHelper.formatDisplay(_toDate)}',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const Icon(Icons.edit_calendar_rounded, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Reason text field
                  CustomTextField(
                    controller: _reasonController,
                    label: 'Reason for Absence *',
                    hint: 'e.g. Medical appointment, family function...',
                    maxLines: 3,
                    validator: Validators.validateReason,
                  ),
                  const SizedBox(height: 16),

                  CustomButton(
                    text: 'Submit Application',
                    icon: Icons.send_rounded,
                    isLoading: _isSubmitting,
                    onPressed: _submitLeave,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Leave History List
          const Text(
            'My Applications',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),

          if (leaveProv.studentLeaves.isEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('No leave applications yet.', style: TextStyle(color: Colors.grey)),
              ),
            ),
          ] else ...[
            ...leaveProv.studentLeaves.map((leave) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color ?? (isDark ? const Color(0xFF1E293B) : Colors.white),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${DateHelper.formatDbToDisplay(leave.fromDate)} to ${DateHelper.formatDbToDisplay(leave.toDate)}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: leave.status.color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            leave.status.displayName,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: leave.status.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      leave.reason,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildAdminView(LeaveProvider leaveProv) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (leaveProv.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (leaveProv.allLeaves.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_rounded, size: 56, color: isDark ? Colors.white24 : Colors.black26),
            const SizedBox(height: 12),
            const Text('No leave applications submitted yet.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: leaveProv.allLeaves.length,
      itemBuilder: (context, index) {
        final item = leaveProv.allLeaves[index];
        final leave = item.leave;
        final student = item.student;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardTheme.color ?? (isDark ? const Color(0xFF1E293B) : Colors.white),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
                        child: Text(
                          student.initials,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(student.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          Text(
                            '${student.rollNo} • ${student.className}',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: leave.status.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      leave.status.displayName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: leave.status.color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Duration: ${DateHelper.formatDbToDisplay(leave.fromDate)} to ${DateHelper.formatDbToDisplay(leave.toDate)}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'Reason: ${leave.reason}',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                ),
              ),
              if (leave.status == LeaveStatus.pending) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.check_rounded, color: Color(0xFF10B981), size: 16),
                        label: const Text('Approve', style: TextStyle(color: Color(0xFF10B981))),
                        onPressed: () {
                          if (leave.id != null) {
                            leaveProv.updateStatus(leave.id!, LeaveStatus.approved);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.close_rounded, color: Color(0xFFEF4444), size: 16),
                        label: const Text('Reject', style: TextStyle(color: Color(0xFFEF4444))),
                        onPressed: () {
                          if (leave.id != null) {
                            leaveProv.updateStatus(leave.id!, LeaveStatus.rejected);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

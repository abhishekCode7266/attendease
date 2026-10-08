import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/student_model.dart';
import '../providers/student_provider.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

/// AddEditStudentScreen handles creating and updating student records with duplicate prevention
class AddEditStudentScreen extends StatefulWidget {
  final StudentModel? student;

  const AddEditStudentScreen({super.key, this.student});

  @override
  State<AddEditStudentScreen> createState() => _AddEditStudentScreenState();
}

class _AddEditStudentScreenState extends State<AddEditStudentScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _rollController;
  late TextEditingController _passwordController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  String _selectedClass = AppConstants.defaultClasses.first;
  bool _isSaving = false;
  bool _obscurePassword = true;

  bool get isEditing => widget.student != null;

  @override
  void initState() {
    super.initState();
    final s = widget.student;
    _nameController = TextEditingController(text: s?.name ?? '');
    _rollController = TextEditingController(text: s?.rollNo ?? '');
    _passwordController = TextEditingController(text: s?.password ?? 'password123');
    _emailController = TextEditingController(text: s?.email ?? '');
    _phoneController = TextEditingController(text: s?.phone ?? '');

    if (s != null && AppConstants.defaultClasses.contains(s.className)) {
      _selectedClass = s.className;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rollController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final provider = Provider.of<StudentProvider>(context, listen: false);

    final rollNo = _rollController.text.trim().toUpperCase();

    // Check duplicate roll number before saving
    final isDuplicate = await provider.checkRollNumberExists(
      rollNo,
      excludeStudentId: widget.student?.id,
    );

    if (isDuplicate) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Roll Number "$rollNo" is already assigned to another student!'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final newStudent = StudentModel(
      id: widget.student?.id,
      name: _nameController.text.trim(),
      rollNo: rollNo,
      className: _selectedClass,
      password: _passwordController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      createdAt: widget.student?.createdAt ?? DateTime.now().toIso8601String(),
    );

    bool success;
    if (isEditing) {
      success = await provider.updateStudent(newStudent);
    } else {
      success = await provider.addStudent(newStudent);
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing ? 'Student updated successfully.' : 'Student added successfully.',
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to save student record.'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Student Profile' : 'Enroll New Student'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFBFDBFE),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                      child: Icon(
                        isEditing ? Icons.edit_rounded : Icons.person_add_alt_1_rounded,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEditing ? 'Modify Student Details' : 'Student Information Form',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Roll number must be unique across all enrolled classes.',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF1E40AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Full Name
              CustomTextField(
                controller: _nameController,
                label: 'Student Full Name *',
                hint: 'e.g. Aarav Sharma',
                prefixIcon: Icons.person_outline_rounded,
                textCapitalization: TextCapitalization.words,
                validator: Validators.validateName,
              ),
              const SizedBox(height: 16),

              // Roll Number
              CustomTextField(
                controller: _rollController,
                label: 'Roll Number / Student ID *',
                hint: 'e.g. CS2026-001',
                prefixIcon: Icons.badge_outlined,
                textCapitalization: TextCapitalization.characters,
                validator: Validators.validateRollNumber,
              ),
              const SizedBox(height: 16),

              // Class Dropdown
              const Text(
                'Class / Department *',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedClass,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.school_outlined, size: 20),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                items: AppConstants.defaultClasses.map((className) {
                  return DropdownMenuItem(
                    value: className,
                    child: Text(className, style: const TextStyle(fontSize: 14)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedClass = val);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Student Password
              CustomTextField(
                controller: _passwordController,
                label: 'Student Portal Password *',
                hint: 'Default: password123',
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: _obscurePassword,
                validator: (v) => Validators.validatePassword(v, minLength: 4),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Optional Email
              CustomTextField(
                controller: _emailController,
                label: 'Email Address (Optional)',
                hint: 'e.g. student@college.edu',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Optional Phone
              CustomTextField(
                controller: _phoneController,
                label: 'Contact Phone (Optional)',
                hint: 'e.g. 9876543210',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 28),

              // Submit Button
              CustomButton(
                text: isEditing ? 'Save Changes' : 'Enroll Student',
                icon: Icons.check_circle_outline_rounded,
                isLoading: _isSaving,
                onPressed: _handleSave,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

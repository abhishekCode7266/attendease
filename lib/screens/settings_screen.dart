import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'login_screen.dart';

/// SettingsScreen provides theme preferences, security management, and session control
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showChangePasswordDialog(BuildContext context) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Change Password'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: oldPasswordController,
                    label: 'Current Password',
                    obscureText: true,
                    validator: (v) => Validators.validatePassword(v, minLength: 4),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: newPasswordController,
                    label: 'New Password',
                    obscureText: true,
                    validator: (v) => Validators.validatePassword(v, minLength: 4),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: confirmPasswordController,
                    label: 'Confirm New Password',
                    obscureText: true,
                    validator: (v) {
                      if (v != newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final auth = Provider.of<AuthProvider>(context, listen: false);

                bool success;
                if (auth.isAdmin) {
                  success = await auth.changeAdminPassword(
                    oldPasswordController.text.trim(),
                    newPasswordController.text.trim(),
                  );
                } else {
                  success = await auth.changeStudentPassword(
                    oldPasswordController.text.trim(),
                    newPasswordController.text.trim(),
                  );
                }

                if (!dialogCtx.mounted) return;
                Navigator.of(dialogCtx).pop();

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password updated successfully!'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(auth.errorMessage ?? 'Failed to update password.'),
                      backgroundColor: const Color(0xFFEF4444),
                    ),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
              SizedBox(width: 8),
              Text('Logout?'),
            ],
          ),
          content: Text('Are you sure you want to log out of ${AppConstants.appName}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.of(dialogCtx).pop();
                final auth = Provider.of<AuthProvider>(context, listen: false);
                await auth.logout();
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: const Text('Logout'),
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
    final themeProv = Provider.of<ThemeProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Preferences'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // User Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardTheme.color ?? (isDark ? const Color(0xFF1E293B) : Colors.white),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
                  child: Icon(
                    auth.isAdmin ? Icons.admin_panel_settings_rounded : Icons.school_rounded,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.userName ?? (auth.isAdmin ? 'Administrator' : 'Student'),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        auth.isAdmin
                            ? 'Role: System Administrator'
                            : 'Roll No: ${auth.rollNo ?? "N/A"} • ${auth.className ?? ""}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Appearance Section
          const Text(
            'APPEARANCE',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey),
          ),
          const SizedBox(height: 8),

          Container(
            decoration: BoxDecoration(
              color: theme.cardTheme.color ?? (isDark ? const Color(0xFF1E293B) : Colors.white),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            child: SwitchListTile(
              secondary: Icon(
                isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: theme.colorScheme.primary,
              ),
              title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                isDark ? 'Dark theme enabled' : 'Light theme enabled',
                style: const TextStyle(fontSize: 12),
              ),
              value: themeProv.isDarkMode,
              onChanged: (val) => themeProv.toggleTheme(val),
            ),
          ),
          const SizedBox(height: 20),

          // Security Section
          const Text(
            'SECURITY & ACCESS',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey),
          ),
          const SizedBox(height: 8),

          Container(
            decoration: BoxDecoration(
              color: theme.cardTheme.color ?? (isDark ? const Color(0xFF1E293B) : Colors.white),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            child: ListTile(
              leading: const Icon(Icons.password_rounded, color: Color(0xFF3B82F6)),
              title: const Text('Change Password', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Update login credentials', style: TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _showChangePasswordDialog(context),
            ),
          ),
          const SizedBox(height: 20),

          // Database & Offline Storage Section
          const Text(
            'STORAGE & DATABASE',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey),
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.cardTheme.color ?? (isDark ? const Color(0xFF1E293B) : Colors.white),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.storage_rounded, color: Color(0xFF10B981)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Local SQLite Database Active',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Database: ${AppConstants.databaseName} • 100% Offline (No Internet Needed)',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // About Section
          const Text(
            'ABOUT',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey),
          ),
          const SizedBox(height: 8),

          Container(
            decoration: BoxDecoration(
              color: theme.cardTheme.color ?? (isDark ? const Color(0xFF1E293B) : Colors.white),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            child: ListTile(
              leading: const Icon(Icons.info_outline_rounded, color: Color(0xFF6366F1)),
              title: Text('About ${AppConstants.appName}', style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Version ${AppConstants.appVersion}', style: TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: AppConstants.appName,
                  applicationVersion: 'v${AppConstants.appVersion}',
                  applicationIcon: const Icon(Icons.fact_check_rounded, size: 40, color: Color(0xFF2563EB)),
                  children: [
                    Text(
                      '${AppConstants.appName} is a high-performance offline mobile student attendance system built with Flutter and SQLite. Designed for universities and schools to track attendance, leaves, and analytics without internet access.',
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 28),

          // Logout Button
          CustomButton(
            text: 'Logout Session',
            icon: Icons.logout_rounded,
            backgroundColor: const Color(0xFFEF4444),
            onPressed: () => _confirmLogout(context),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:attendease/providers/auth_provider.dart';
import 'package:attendease/providers/student_provider.dart';
import 'package:attendease/providers/attendance_provider.dart';
import 'package:attendease/providers/theme_provider.dart';
import 'package:attendease/screens/login_screen.dart';
import 'package:attendease/utils/constants.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('LoginScreen renders role tabs, inputs, and settings bypass icon', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify brand title
    expect(find.text(AppConstants.appName), findsOneWidget);

    // Verify top-right settings circle button
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);

    // Verify Role buttons
    expect(find.text('Admin Portal'), findsOneWidget);
    expect(find.text('Student Portal'), findsOneWidget);

    // Initially in Admin portal
    expect(find.text('Admin Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Login as Admin'), findsOneWidget);

    // Switch to Student portal tab
    await tester.tap(find.text('Student Portal'));
    await tester.pumpAndSettle();

    // Verify UI switched to Student fields
    expect(find.text('Roll Number'), findsOneWidget);
    expect(find.text('Login as Student'), findsOneWidget);
  });

  testWidgets('Tapping top-right settings button opens Settings & Quick Access with Direct Admin Bypass', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Tap top-right circular settings button
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    // Verify bottom sheet contents
    expect(find.text('Settings & Quick Access'), findsOneWidget);
    expect(find.text('⚡ Direct Admin Bypass'), findsOneWidget);
    expect(find.text('One-tap instant entry to Admin Dashboard'), findsOneWidget);
  });

  testWidgets('Tapping Direct Admin Bypass immediately logs in and navigates to Admin Dashboard', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => StudentProvider()),
          ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Tap top-right circular settings button
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    // Tap Direct Admin Bypass
    await tester.tap(find.text('⚡ Direct Admin Bypass'));
    await tester.pumpAndSettle();

    // Should now be on Admin Dashboard
    expect(find.text('⚡ Admin Bypass Activated! Welcome to Admin Portal.'), findsOneWidget);
  });
}

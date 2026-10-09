import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:attendease/providers/auth_provider.dart';
import 'package:attendease/screens/login_screen.dart';
import 'package:attendease/utils/constants.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('LoginScreen renders role tabs and input fields correctly', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Allow async initializations
    await tester.pumpAndSettle();

    // Verify brand title
    expect(find.text(AppConstants.appName), findsOneWidget);

    // Verify Role buttons
    expect(find.text('Admin Portal'), findsOneWidget);
    expect(find.text('Student Portal'), findsOneWidget);

    // Initially in Admin portal, expect Admin Username field
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

  testWidgets('Logo long-press displays hidden owner master access dialog', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Long press on brand logo
    final logoFinder = find.byIcon(Icons.fact_check_rounded);
    expect(logoFinder, findsOneWidget);
    await tester.longPress(logoFinder);
    await tester.pumpAndSettle();

    // Verify private owner dialog is displayed
    expect(find.text('Owner Master Access'), findsOneWidget);
    expect(find.text('Unlock Admin Portal'), findsOneWidget);
  });
}

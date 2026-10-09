import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/database_helper.dart';
import '../models/admin_model.dart';
import '../models/student_model.dart';
import '../utils/constants.dart';

/// AuthProvider manages user authentication, sessions, and credentials
class AuthProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  // Active Session
  bool _isLoggedIn = false;
  UserRole _role = UserRole.admin;
  int? _userId;
  String? _userName;
  String? _rollNo;
  String? _className;

  AdminModel? _currentAdmin;
  StudentModel? _currentStudent;

  // Getters
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _isLoggedIn;
  UserRole get role => _role;
  int? get userId => _userId;
  String? get userName => _userName;
  String? get rollNo => _rollNo;
  String? get className => _className;
  AdminModel? get currentAdmin => _currentAdmin;
  StudentModel? get currentStudent => _currentStudent;

  bool get isAdmin => _role == UserRole.admin;
  bool get isStudent => _role == UserRole.student;
  bool get isTeacher => _role == UserRole.teacher;

  AuthProvider() {
    initSession();
  }

  /// Initializes and restores persistent session from SharedPreferences
  Future<void> initSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool(AppConstants.prefIsLoggedIn) ?? false;

      if (_isLoggedIn) {
        final roleStr = prefs.getString(AppConstants.prefUserRole);
        _role = UserRoleExtension.fromString(roleStr);
        _userId = prefs.getInt(AppConstants.prefUserId);
        _userName = prefs.getString(AppConstants.prefUserName);
        _rollNo = prefs.getString(AppConstants.prefUserRollNo);
        _className = prefs.getString(AppConstants.prefUserClass);

        if (_role == UserRole.admin && _userId != null) {
          final admin = await _dbHelper.getAdminByUsername(_userName ?? 'admin');
          _currentAdmin = admin;
        } else if (_role == UserRole.student && _userId != null) {
          final student = await _dbHelper.getStudentById(_userId!);
          _currentStudent = student;
          if (student != null) {
            _userName = student.name;
            _rollNo = student.rollNo;
            _className = student.className;
          }
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to restore session: $e';
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Admin Login
  Future<bool> loginAdmin(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final admin = await _dbHelper.authenticateAdmin(username, password);
      if (admin == null) {
        _errorMessage = 'Invalid admin username or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _currentAdmin = admin;
      _role = UserRole.admin;
      _isLoggedIn = true;
      _userId = admin.id;
      _userName = admin.username;

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.prefIsLoggedIn, true);
      await prefs.setString(AppConstants.prefUserRole, UserRole.admin.value);
      if (admin.id != null) await prefs.setInt(AppConstants.prefUserId, admin.id!);
      await prefs.setString(AppConstants.prefUserName, admin.username);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Admin login error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Student Login
  Future<bool> loginStudent(String rollNo, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final student = await _dbHelper.authenticateStudent(rollNo, password);
      if (student == null) {
        _errorMessage = 'Invalid roll number or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _currentStudent = student;
      _role = UserRole.student;
      _isLoggedIn = true;
      _userId = student.id;
      _userName = student.name;
      _rollNo = student.rollNo;
      _className = student.className;

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.prefIsLoggedIn, true);
      await prefs.setString(AppConstants.prefUserRole, UserRole.student.value);
      if (student.id != null) await prefs.setInt(AppConstants.prefUserId, student.id!);
      await prefs.setString(AppConstants.prefUserName, student.name);
      await prefs.setString(AppConstants.prefUserRollNo, student.rollNo);
      await prefs.setString(AppConstants.prefUserClass, student.className);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Student login error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Secret Owner/Developer Admin Bypass
  Future<bool> bypassAdminLogin() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      AdminModel? admin = await _dbHelper.getAdminByUsername(AppConstants.defaultAdminUsername);
      admin ??= const AdminModel(id: 1, username: 'admin', password: 'admin123');

      _currentAdmin = admin;
      _role = UserRole.admin;
      _isLoggedIn = true;
      _userId = admin.id ?? 1;
      _userName = admin.username;

      // Persist session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.prefIsLoggedIn, true);
      await prefs.setString(AppConstants.prefUserRole, UserRole.admin.value);
      await prefs.setInt(AppConstants.prefUserId, admin.id ?? 1);
      await prefs.setString(AppConstants.prefUserName, admin.username);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Admin bypass error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Updates Admin Password
  Future<bool> changeAdminPassword(String oldPassword, String newPassword) async {
    if (_currentAdmin == null || _userId == null) {
      _errorMessage = 'No active admin session';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final verify = await _dbHelper.authenticateAdmin(_currentAdmin!.username, oldPassword);
      if (verify == null) {
        _errorMessage = 'Incorrect current password';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final success = await _dbHelper.updateAdminPassword(_userId!, newPassword);
      if (success) {
        _currentAdmin = _currentAdmin!.copyWith(password: newPassword);
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Failed to change password: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Updates Student Password
  Future<bool> changeStudentPassword(String oldPassword, String newPassword) async {
    if (_currentStudent == null || _userId == null) {
      _errorMessage = 'No active student session';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final verify = await _dbHelper.authenticateStudent(_currentStudent!.rollNo, oldPassword);
      if (verify == null) {
        _errorMessage = 'Incorrect current password';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final success = await _dbHelper.updateStudentPassword(_userId!, newPassword);
      if (success) {
        _currentStudent = _currentStudent!.copyWith(password: newPassword);
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Failed to change password: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Refresh current student profile
  Future<void> refreshProfile() async {
    if (_role == UserRole.student && _userId != null) {
      _currentStudent = await _dbHelper.getStudentById(_userId!);
      notifyListeners();
    }
  }

  /// Logs out the user and clears SharedPreferences
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.prefIsLoggedIn);
      await prefs.remove(AppConstants.prefUserRole);
      await prefs.remove(AppConstants.prefUserId);
      await prefs.remove(AppConstants.prefUserName);
      await prefs.remove(AppConstants.prefUserRollNo);
      await prefs.remove(AppConstants.prefUserClass);

      _isLoggedIn = false;
      _userId = null;
      _userName = null;
      _rollNo = null;
      _className = null;
      _currentAdmin = null;
      _currentStudent = null;
      _errorMessage = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

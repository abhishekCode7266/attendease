import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/leave_model.dart';
import '../utils/constants.dart';

/// LeaveProvider manages leave applications and approval workflows
class LeaveProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  bool _isLoading = false;
  String? _errorMessage;

  List<LeaveModel> _studentLeaves = [];
  List<LeaveWithStudent> _allLeaves = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<LeaveModel> get studentLeaves => _studentLeaves;
  List<LeaveWithStudent> get allLeaves => _allLeaves;

  /// Loads leaves for current student
  Future<void> loadStudentLeaves(int studentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _studentLeaves = await _dbHelper.getLeavesForStudent(studentId);
    } catch (e) {
      _errorMessage = 'Failed to load leaves: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Submits a new leave request
  Future<bool> applyLeave(LeaveModel leave) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _dbHelper.insertLeave(leave);
      await loadStudentLeaves(leave.studentId);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to submit leave: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Loads all leave applications for Admin review
  Future<void> loadAllLeaves({String? status}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allLeaves = await _dbHelper.getAllLeaves(status: status);
    } catch (e) {
      _errorMessage = 'Failed to load leave applications: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Approves or rejects a leave application
  Future<bool> updateStatus(int leaveId, LeaveStatus status) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _dbHelper.updateLeaveStatus(leaveId, status);
      await loadAllLeaves();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update leave status: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

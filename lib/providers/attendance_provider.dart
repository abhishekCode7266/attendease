import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/attendance_model.dart';
import '../utils/constants.dart';
import '../utils/date_helper.dart';

/// AttendanceProvider manages attendance marking, date-wise reports, and analytics
class AttendanceProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  bool _isLoading = false;
  String? _errorMessage;

  // Admin Date-wise State
  DateTime _selectedDate = DateTime.now();
  String _selectedSubject = 'General';
  String _selectedClass = 'All';
  List<AttendanceWithStudent> _dateAttendanceList = [];
  Map<String, int> _dailyStats = {
    'total': 0,
    'present': 0,
    'absent': 0,
    'late': 0,
    'not_marked': 0,
  };

  // Student State
  bool _studentMarkedToday = false;
  AttendanceModel? _todayStudentAttendance;
  List<AttendanceModel> _studentAttendanceHistory = [];
  StudentAttendanceSummary? _studentSummary;
  List<SubjectAttendanceSummary> _studentSubjectSummaries = [];

  // All Students Summaries (for Reports)
  List<StudentAttendanceSummary> _allStudentsSummaries = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime get selectedDate => _selectedDate;
  String get selectedSubject => _selectedSubject;
  String get selectedClass => _selectedClass;
  List<AttendanceWithStudent> get dateAttendanceList => _dateAttendanceList;
  Map<String, int> get dailyStats => _dailyStats;

  bool get studentMarkedToday => _studentMarkedToday;
  AttendanceModel? get todayStudentAttendance => _todayStudentAttendance;
  List<AttendanceModel> get studentAttendanceHistory => _studentAttendanceHistory;
  StudentAttendanceSummary? get studentSummary => _studentSummary;
  List<SubjectAttendanceSummary> get studentSubjectSummaries => _studentSubjectSummaries;
  List<StudentAttendanceSummary> get allStudentsSummaries => _allStudentsSummaries;

  /// Low attendance (<75%) students count in reports
  int get lowAttendanceCount =>
      _allStudentsSummaries.where((s) => s.isBelowThreshold).length;

  /// Loads attendance for selected date (Admin)
  Future<void> loadAttendanceForSelectedDate() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final dateStr = DateHelper.formatDbDate(_selectedDate);
      _dateAttendanceList = await _dbHelper.getAttendanceForDate(
        dateStr,
        className: _selectedClass == 'All' ? null : _selectedClass,
        subject: _selectedSubject,
      );

      _dailyStats = await _dbHelper.getDailyAttendanceSummary(
        dateStr,
        subject: _selectedSubject,
      );
    } catch (e) {
      _errorMessage = 'Failed to load date attendance: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sets selected date for Admin date-wise inspection
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    loadAttendanceForSelectedDate();
  }

  /// Sets selected subject
  void setSelectedSubject(String subject) {
    _selectedSubject = subject;
    loadAttendanceForSelectedDate();
  }

  /// Sets selected class
  void setSelectedClass(String className) {
    _selectedClass = className;
    loadAttendanceForSelectedDate();
  }

  /// Manually update / mark attendance for a student on selected date (Admin)
  Future<bool> setStudentAttendanceStatus({
    required int studentId,
    required AttendanceStatus status,
    String? notes,
  }) async {
    try {
      final dateStr = DateHelper.formatDbDate(_selectedDate);
      final record = AttendanceModel(
        studentId: studentId,
        date: dateStr,
        status: status,
        subject: _selectedSubject,
        timestamp: DateTime.now().toIso8601String(),
        notes: notes,
      );

      await _dbHelper.markAttendance(record);
      await loadAttendanceForSelectedDate();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update attendance: $e';
      notifyListeners();
      return false;
    }
  }

  /// Batch mark all students for selected date
  Future<void> batchMarkStatus(AttendanceStatus status) async {
    _isLoading = true;
    notifyListeners();

    try {
      final dateStr = DateHelper.formatDbDate(_selectedDate);
      for (final item in _dateAttendanceList) {
        if (item.student.id != null) {
          final record = AttendanceModel(
            studentId: item.student.id!,
            date: dateStr,
            status: status,
            subject: _selectedSubject,
            timestamp: DateTime.now().toIso8601String(),
          );
          await _dbHelper.markAttendance(record);
        }
      }
      await loadAttendanceForSelectedDate();
    } catch (e) {
      _errorMessage = 'Batch marking failed: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==========================================
  // STUDENT METHODS
  // ==========================================

  /// Loads student's personal attendance dashboard data
  Future<void> loadStudentDashboard(int studentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final todayStr = DateHelper.formatDbDate(DateTime.now());

      // Check today's status
      _todayStudentAttendance = await _dbHelper.getAttendanceForDateAndStudent(
        studentId,
        todayStr,
        subject: 'General',
      );
      _studentMarkedToday = _todayStudentAttendance != null &&
          _todayStudentAttendance!.status != AttendanceStatus.notMarked;

      // History
      _studentAttendanceHistory = await _dbHelper.getAttendanceForStudent(studentId);

      // Summary
      _studentSummary = await _dbHelper.getStudentAttendanceSummary(studentId);

      // Subject-wise summaries
      _studentSubjectSummaries = await _dbHelper.getSubjectWiseAttendance(studentId);
    } catch (e) {
      _errorMessage = 'Failed to load attendance dashboard: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Student marks attendance for today (Once per day enforcement)
  Future<bool> markStudentTodayAttendance({
    required int studentId,
    AttendanceStatus status = AttendanceStatus.present,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final todayStr = DateHelper.formatDbDate(DateTime.now());

      // Verify if already marked
      final existing = await _dbHelper.getAttendanceForDateAndStudent(
        studentId,
        todayStr,
        subject: 'General',
      );

      if (existing != null && existing.status != AttendanceStatus.notMarked) {
        _errorMessage = 'You have already marked attendance for today ($todayStr).';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final record = AttendanceModel(
        studentId: studentId,
        date: todayStr,
        status: status,
        subject: 'General',
        timestamp: DateTime.now().toIso8601String(),
        notes: 'Self-marked by student',
      );

      await _dbHelper.markAttendance(record);
      await loadStudentDashboard(studentId);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to mark attendance: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ==========================================
  // REPORT METHODS
  // ==========================================

  /// Loads all students summaries for comprehensive reports screen
  Future<void> loadAllReports({String? className, String? subject}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allStudentsSummaries = await _dbHelper.getAllStudentsAttendanceSummary(
        className: className == 'All' ? null : className,
        subject: subject == 'All' ? null : subject,
      );
    } catch (e) {
      _errorMessage = 'Failed to load attendance reports: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

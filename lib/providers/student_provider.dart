import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/student_model.dart';

/// StudentProvider manages student records, searching, filtering, and CRUD operations
class StudentProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<StudentModel> _students = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedClass = 'All';

  List<StudentModel> get students => _students;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedClass => _selectedClass;
  int get totalStudentCount => _students.length;

  StudentProvider() {
    loadStudents();
  }

  /// Loads students from SQLite according to active search and filter
  Future<void> loadStudents() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _students = await _dbHelper.getAllStudents(
        search: _searchQuery.isEmpty ? null : _searchQuery,
        className: _selectedClass == 'All' ? null : _selectedClass,
      );
    } catch (e) {
      _errorMessage = 'Failed to load students: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sets search query and reloads students
  void setSearchQuery(String query) {
    _searchQuery = query;
    loadStudents();
  }

  /// Sets class filter and reloads students
  void setSelectedClass(String className) {
    _selectedClass = className;
    loadStudents();
  }

  /// Adds a new student with duplicate roll number prevention
  Future<bool> addStudent(StudentModel student) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final exists = await _dbHelper.isRollNumberExists(student.rollNo);
      if (exists) {
        _errorMessage = 'Roll Number "${student.rollNo.toUpperCase()}" already exists.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await _dbHelper.insertStudent(student);
      await loadStudents();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Updates an existing student
  Future<bool> updateStudent(StudentModel student) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final exists = await _dbHelper.isRollNumberExists(
        student.rollNo,
        excludeStudentId: student.id,
      );
      if (exists) {
        _errorMessage = 'Another student with Roll Number "${student.rollNo.toUpperCase()}" already exists.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await _dbHelper.updateStudent(student);
      await loadStudents();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Deletes a student by ID
  Future<bool> deleteStudent(int studentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _dbHelper.deleteStudent(studentId);
      await loadStudents();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete student: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Checks roll number availability synchronously/asynchronously
  Future<bool> checkRollNumberExists(String rollNo, {int? excludeStudentId}) async {
    try {
      return await _dbHelper.isRollNumberExists(rollNo, excludeStudentId: excludeStudentId);
    } catch (_) {
      return false;
    }
  }
}

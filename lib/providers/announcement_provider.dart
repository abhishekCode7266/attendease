import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/announcement_model.dart';

/// AnnouncementProvider manages notice board announcements
class AnnouncementProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<AnnouncementModel> _announcements = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AnnouncementModel> get announcements => _announcements;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AnnouncementProvider() {
    loadAnnouncements();
  }

  /// Loads all announcements
  Future<void> loadAnnouncements() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _announcements = await _dbHelper.getAllAnnouncements();
    } catch (e) {
      _errorMessage = 'Failed to load announcements: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adds a new announcement
  Future<bool> addAnnouncement(AnnouncementModel announcement) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _dbHelper.insertAnnouncement(announcement);
      await loadAnnouncements();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to post announcement: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Deletes an announcement
  Future<bool> deleteAnnouncement(int id) async {
    try {
      await _dbHelper.deleteAnnouncement(id);
      await loadAnnouncements();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete announcement: $e';
      notifyListeners();
      return false;
    }
  }
}

import 'package:flutter/material.dart';
import '../core/api/api_client.dart';
import '../core/constants/api_constants.dart';
import '../data/models/student_models.dart';
import '../data/models/timetable_models.dart';
import '../data/models/attendance_models.dart';
import '../data/models/holiday_models.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

class StudentProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  Student? _profile;
  List<TimetableEntry> _batchTimetable = [];
  List<AttendanceRecord> _myAttendance = [];
  List<Holiday> _holidays = [];
  bool _isLoading = false;

  Student? get profile => _profile;
  List<TimetableEntry> get batchTimetable => _batchTimetable;
  List<AttendanceRecord> get myAttendance => _myAttendance;
  List<Holiday> get holidays => _holidays;
  bool get isLoading => _isLoading;

  Future<void> fetchMyProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.dio.get('/student/me');
      if (response.statusCode == 200 && response.data['success']) {
        final data = response.data['data'];
        if (data is Map && data.containsKey('student')) {
          _profile = Student.fromJson(data['student']);
        } else {
          _profile = Student.fromJson(data);
        }
        
        // Automatically fetch holidays once profile (and batchId) is available
        if (_profile?.batch?.id != null) {
          fetchHolidays(batchId: _profile!.batch!.id);
        }
      }
    } catch (e) {
      debugPrint('Fetch Student Profile Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data, String? photoPath) async {
    if (_profile == null) return false;

    try {
      FormData formData = FormData.fromMap(data);
      if (photoPath != null) {
        formData.files.add(MapEntry(
          'photo',
          await MultipartFile.fromFile(photoPath),
        ));
      }

      final response = await _apiClient.dio.put('${ApiConstants.student}/${_profile!.id}', data: formData);
      if (response.statusCode == 200 && response.data['success']) {
        await fetchMyProfile();
        return true;
      }
    } catch (e) {
      debugPrint('Update Profile Error: $e');
    }
    return false;
  }

  Future<void> fetchBatchTimetable() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.dio.get(ApiConstants.timetableMe);
      if (response.statusCode == 200 && response.data['success']) {
        final data = response.data['data'];
        if (data is Map && data.containsKey('entries')) {
          _batchTimetable = (data['entries'] as List).map((e) => TimetableEntry.fromJson(e)).toList();
        } else {
          _batchTimetable = (data as List).map((e) => TimetableEntry.fromJson(e)).toList();
        }
      }
    } catch (e) {
      debugPrint('Fetch Batch Timetable Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyAttendance() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.dio.get(ApiConstants.attendanceMe);
      if (response.statusCode == 200 && response.data['success']) {
        final data = response.data['data'];
        if (data is Map && data.containsKey('records')) {
          _myAttendance = (data['records'] as List).map((e) => AttendanceRecord.fromJson(e)).toList();
        } else {
          _myAttendance = (data as List).map((e) => AttendanceRecord.fromJson(e)).toList();
        }
      }
    } catch (e) {
      debugPrint('Fetch My Attendance Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchHolidays({String? batchId}) async {
    try {
      final int fetchYear = _profile?.batch?.startDate?.year ?? DateTime.now().year;
      
      final response = await _apiClient.dio.get(
        ApiConstants.holiday,
        queryParameters: {
          if (batchId != null) 'batchId': batchId,
          'year': fetchYear,
        },
      );
      if (response.statusCode == 200 && response.data['success']) {
        final List data = response.data['data']['holidays'] ?? [];
        _holidays = data.map((e) => Holiday.fromJson(e)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Fetch Holidays Error: $e');
    }
  }

  Future<bool> uploadCertification(String name, String filePath) async {
    if (_profile == null) return false;

    try {
      FormData formData = FormData.fromMap({
        'name': name,
        'file': await MultipartFile.fromFile(filePath),
      });

      final response = await _apiClient.dio.post('${ApiConstants.student}/${_profile!.id}/certifications', data: formData);
      if (response.statusCode == 201 || (response.statusCode == 200 && response.data['success'])) {
        await fetchMyProfile();
        return true;
      }
    } catch (e) {
      debugPrint('Upload Certification Error: $e');
    }
    return false;
  }

  Future<AttendanceRecord?> fetchAttendanceByDate(DateTime date) async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final response = await _apiClient.dio.get(
        ApiConstants.attendanceMe,
        queryParameters: {'date': dateStr},
      );
      
      if (response.statusCode == 200 && response.data['success']) {
        final data = response.data['data'];
        final List records = data is Map ? (data['records'] ?? []) : (data as List);
        
        if (records.isNotEmpty) {
          return AttendanceRecord.fromJson(records.first);
        }
      }
    } catch (e) {
      debugPrint('Fetch Attendance By Date Error: $e');
    }
    return null;
  }

  Future<bool> deleteCertification(String certId) async {
    if (_profile == null) return false;

    try {
      final response = await _apiClient.dio.delete('${ApiConstants.student}/${_profile!.id}/certifications/$certId');
      if (response.statusCode == 200 && response.data['success']) {
        await fetchMyProfile();
        return true;
      }
    } catch (e) {
      debugPrint('Delete Certification Error: $e');
    }
    return false;
  }
}

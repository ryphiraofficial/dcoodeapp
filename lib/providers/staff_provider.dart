import 'package:flutter/material.dart';
import '../core/api/api_client.dart';
import '../core/constants/api_constants.dart';
import '../data/models/dashboard_models.dart';
import '../data/models/college_models.dart';
import '../data/models/course_models.dart';
import '../data/models/student_models.dart';
import '../data/models/batch_models.dart';
import '../data/models/timetable_models.dart';
import '../data/models/attendance_models.dart';
import '../data/models/auth_models.dart';
import '../data/models/holiday_models.dart';
import 'package:dio/dio.dart';

class StaffProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  DashboardData? _dashboardData;
  CollegeListResponse? _collegeList;
  CourseListResponse? _courseList;
  List<Course> _dropdownCourses = [];
  StudentListResponse? _studentList;
  BatchListResponse? _batchList;
  List<TimetableEntry> _timetableList = [];
  List<AttendanceRecord> _attendanceRecords = [];
  List<Holiday> _holidays = [];
  User? _profile;
  bool _isLoading = false;

  DashboardData? get dashboardData => _dashboardData;
  CollegeListResponse? get collegeList => _collegeList;
  CourseListResponse? get courseList => _courseList;
  List<Course> get dropdownCourses => _dropdownCourses;
  StudentListResponse? get studentList => _studentList;
  BatchListResponse? get batchList => _batchList;
  List<TimetableEntry> get timetableList => _timetableList;
  List<AttendanceRecord> get attendanceRecords => _attendanceRecords;
  List<Holiday> get holidays => _holidays;
  User? get profile => _profile;
  bool get isLoading => _isLoading;

  Future<void> fetchDashboard() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.dio.get(ApiConstants.dashboard);
      if (response.statusCode == 200 && response.data['success']) {
        _dashboardData = DashboardData.fromJson(response.data);
      }
    } catch (e) {
      debugPrint('Fetch Dashboard Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchColleges({String? search, String? status, int page = 1}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final queryParams = {
        if (search != null) 'search': search,
        if (status != null) 'status': status,
        'page': page,
      };
      final response = await _apiClient.dio.get(ApiConstants.college, queryParameters: queryParams);
      if (response.statusCode == 200 && response.data['success']) {
        _collegeList = CollegeListResponse.fromJson(response.data);
      }
    } catch (e) {
      debugPrint('Fetch Colleges Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createCollege(Map<String, dynamic> data, String? logoPath) async {
    try {
      final Map<String, dynamic> cleanData = {};
      data.forEach((key, value) {
        if (value != null && value.toString().trim().isNotEmpty) cleanData[key] = value;
      });
      FormData formData = FormData.fromMap(cleanData);
      if (logoPath != null) {
        formData.files.add(MapEntry('logo', await MultipartFile.fromFile(logoPath)));
      }
      final response = await _apiClient.dio.post(ApiConstants.college, data: formData);
      return response.statusCode == 201 || (response.statusCode == 200 && response.data['success']);
    } catch (e) {
      debugPrint('Create College Error: $e');
      return false;
    }
  }

  Future<bool> deleteCollege(String id) async {
    try {
      final response = await _apiClient.dio.delete('${ApiConstants.college}/$id');
      if (response.statusCode == 200 && response.data['success']) {
        await fetchColleges();
        return true;
      }
    } catch (e) {
      debugPrint('Delete College Error: $e');
    }
    return false;
  }

  Future<void> fetchCourses({String? collegeId, String? search, int page = 1}) async {
    _isLoading = true;
    notifyListeners();
    try {
      String url = ApiConstants.course;
      if (collegeId != null) url = '${ApiConstants.course}/$collegeId';
      
      final queryParams = {
        if (search != null) 'search': search,
        if (collegeId == null) 'page': page,
      };

      final response = await _apiClient.dio.get(url, queryParameters: queryParams);
      if (response.statusCode == 200 && response.data['success']) {
        if (collegeId != null) {
          final data = response.data['data'];
          _dropdownCourses = (data['courses'] as List).map<Course>((e) => Course.fromJson(e)).toList();
        } else {
          _courseList = CourseListResponse.fromJson(response.data);
        }
      }
    } catch (e) {
      debugPrint('Fetch Courses Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createCourse(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post(ApiConstants.course, data: data);
      if (response.statusCode == 201 || (response.statusCode == 200 && response.data['success'])) {
        await fetchCourses();
        return true;
      }
    } catch (e) {
      debugPrint('Create Course Error: $e');
    }
    return false;
  }

  Future<bool> updateCourse(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.put('${ApiConstants.course}/$id', data: data);
      if (response.statusCode == 200 && response.data['success']) {
        await fetchCourses();
        return true;
      }
    } catch (e) {
      debugPrint('Update Course Error: $e');
    }
    return false;
  }

  Future<bool> deleteCourse(String id) async {
    try {
      final response = await _apiClient.dio.delete('${ApiConstants.course}/$id');
      if (response.statusCode == 200 && response.data['success']) {
        await fetchCourses();
        return true;
      }
    } catch (e) {
      debugPrint('Delete Course Error: $e');
    }
    return false;
  }

  Future<void> fetchStudents({String? search, String? collegeId, String? courseId, String? batchId, int page = 1}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final queryParams = {
        if (search != null) 'search': search,
        if (collegeId != null) 'collegeId': collegeId,
        if (courseId != null) 'courseId': courseId,
        if (batchId != null) 'batchId': batchId,
        'page': page,
      };
      final response = await _apiClient.dio.get(ApiConstants.student, queryParameters: queryParams);
      if (response.statusCode == 200 && response.data['success']) {
        _studentList = StudentListResponse.fromJson(response.data);
      }
    } catch (e) {
      debugPrint('Fetch Students Error: $e');
      if (e is TypeError) {
        debugPrint('Parsing error in fetchStudents: ${e.stackTrace}');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> createStudent(Map<String, dynamic> data, String? photoPath) async {
    try {
      final Map<String, dynamic> cleanData = {};
      data.forEach((key, value) {
        if (value != null && value.toString().trim().isNotEmpty) cleanData[key] = value;
      });
      FormData formData = FormData.fromMap(cleanData);
      if (photoPath != null) {
        formData.files.add(MapEntry('photo', await MultipartFile.fromFile(photoPath)));
      }
      final response = await _apiClient.dio.post(ApiConstants.student, data: formData);
      if (response.statusCode == 201 && response.data['success']) {
        return response.data['data'];
      }
    } catch (e) {
      debugPrint('Create Student Error: $e');
    }
    return null;
  }

  Future<bool> updateStudent(String id, Map<String, dynamic> data, String? photoPath) async {
    try {
      final Map<String, dynamic> cleanData = {};
      data.forEach((key, value) {
        if (value != null && value.toString().trim().isNotEmpty) cleanData[key] = value;
      });
      FormData formData = FormData.fromMap(cleanData);
      if (photoPath != null) {
        formData.files.add(MapEntry('photo', await MultipartFile.fromFile(photoPath)));
      }
      final response = await _apiClient.dio.put('${ApiConstants.student}/$id', data: formData);
      return response.statusCode == 200 && response.data['success'];
    } catch (e) {
      debugPrint('Update Student Error: $e');
      return false;
    }
  }

  Future<bool> deleteStudent(String id) async {
    try {
      final response = await _apiClient.dio.delete('${ApiConstants.student}/$id');
      if (response.statusCode == 200 && response.data['success']) {
        await fetchStudents();
        return true;
      }
    } catch (e) {
      debugPrint('Delete Student Error: $e');
    }
    return false;
  }

  Future<void> fetchBatches({String? collegeId, String? courseId, String? search, int page = 1}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final queryParams = {
        if (collegeId != null) 'collegeId': collegeId,
        if (courseId != null) 'courseId': courseId,
        if (search != null) 'search': search,
        'page': page,
      };
      final response = await _apiClient.dio.get(ApiConstants.batch, queryParameters: queryParams);
      if (response.statusCode == 200 && response.data['success']) {
        _batchList = BatchListResponse.fromJson(response.data);
      }
    } catch (e) {
      debugPrint('Fetch Batches Error: $e');
      if (e is TypeError) {
        debugPrint('Parsing error in fetchBatches: ${e.stackTrace}');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createBatch(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post(ApiConstants.batch, data: data);
      if (response.statusCode == 201 || (response.statusCode == 200 && response.data['success'])) {
        await fetchBatches();
        return true;
      }
    } catch (e) {
      debugPrint('Create Batch Error: $e');
    }
    return false;
  }

  Future<bool> updateBatch(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.put('${ApiConstants.batch}/$id', data: data);
      if (response.statusCode == 200 && response.data['success']) {
        await fetchBatches();
        return true;
      }
    } catch (e) {
      debugPrint('Update Batch Error: $e');
    }
    return false;
  }

  Future<bool> deleteBatch(String id) async {
    try {
      final response = await _apiClient.dio.delete('${ApiConstants.batch}/$id');
      if (response.statusCode == 200 && response.data['success']) {
        await fetchBatches();
        return true;
      }
    } catch (e) {
      debugPrint('Delete Batch Error: $e');
    }
    return false;
  }

  Future<void> fetchTimetable({String? batchId, String? date}) async {
    _isLoading = true;
    _timetableList = []; // Clear current list before fetching new date
    notifyListeners();
    try {
      final queryParams = {
        if (batchId != null) 'batchId': batchId,
        if (date != null) 'date': date,
      };
      final response = await _apiClient.dio.get(ApiConstants.timetable, queryParameters: queryParams);
      if (response.statusCode == 200 && response.data['success']) {
        final data = response.data['data'];
        if (data is List) {
          _timetableList = data.map((e) => TimetableEntry.fromJson(e)).toList();
        } else if (data is Map && data.containsKey('timetable')) {
          _timetableList = (data['timetable'] as List).map((e) => TimetableEntry.fromJson(e)).toList();
        }
      }
    } catch (e) {
      debugPrint('Fetch Timetable Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createTimetableEntry(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post(ApiConstants.timetable, data: data);
      return response.statusCode == 201 || (response.statusCode == 200 && response.data['success']);
    } catch (e) {
      debugPrint('Create Timetable Error: $e');
      return false;
    }
  }

  Future<void> fetchAttendance({required String batchId, required String date}) async {
    _isLoading = true;
    _attendanceRecords = [];
    notifyListeners();
    try {
      final response = await _apiClient.dio.get(ApiConstants.attendance, queryParameters: {
        'batchId': batchId,
        'date': date,
      });
      if (response.statusCode == 200 && response.data['success']) {
        final data = response.data['data'];
        final records = data['records'] as List? ?? [];
        _attendanceRecords = records.map((e) => AttendanceRecord.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Fetch Attendance Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> markBulkAttendance({
    required String batchId,
    required String date,
    required List<Map<String, String>> records,
    String? task,
    String? description,
    List<String>? files,
  }) async {
    try {
      final response = await _apiClient.dio.post(ApiConstants.attendanceBulk, data: {
        'batch': batchId,
        'date': date,
        'records': records,
        if (task != null && task.isNotEmpty) 'task': task,
        if (description != null && description.isNotEmpty) 'description': description,
        if (files != null && files.isNotEmpty) 'files': files,
      });
      return response.statusCode == 201 || (response.statusCode == 200 && response.data['success']);
    } catch (e) {
      debugPrint('Mark Bulk Attendance Error: $e');
      return false;
    }
  }

  Future<bool> markLeave({required String date, String? batchId}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.dio.post(ApiConstants.attendanceLeave, data: {
        'date': date,
        if (batchId != null) 'batchId': batchId,
      });
      return response.statusCode == 201 || (response.statusCode == 200 && response.data['success']);
    } catch (e) {
      debugPrint('Mark Leave Error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchHolidays({String? batchId}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.dio.get(ApiConstants.holiday, queryParameters: {
        if (batchId != null) 'batchId': batchId,
        'year': DateTime.now().year,
      });
      if (response.statusCode == 200 && response.data['success']) {
        final List data = response.data['data']['holidays'] ?? [];
        _holidays = data.map((e) => Holiday.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Fetch Holidays Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createHoliday({required String date, required String reason, String? batchId}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.dio.post(ApiConstants.holiday, data: {
        'date': date,
        'reason': reason,
        if (batchId != null) 'batchId': batchId,
      });
      if (response.statusCode == 201 || (response.statusCode == 200 && response.data['success'])) {
        await fetchHolidays(batchId: batchId);
        return true;
      }
    } catch (e) {
      debugPrint('Create Holiday Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<bool> deleteHoliday(String id, {String? batchId}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.dio.delete('${ApiConstants.holiday}/$id');
      if (response.statusCode == 200 && response.data['success']) {
        await fetchHolidays(batchId: batchId);
        return true;
      }
    } catch (e) {
      debugPrint('Delete Holiday Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<void> fetchMyProfile() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.dio.get('/staff/me');
      if (response.statusCode == 200 && response.data['success']) {
        final data = response.data['data'];
        // Handle both { data: { staff: {...} } } and { data: {...} }
        if (data is Map && data.containsKey('staff')) {
          _profile = User.fromJson(data['staff']);
        } else if (data is Map && data.containsKey('user')) {
          _profile = User.fromJson(data['user']);
        } else {
          _profile = User.fromJson(data);
        }
      }
    } catch (e) {
      debugPrint('Fetch Staff Profile Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateMyProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.dio.put('/staff/me', data: data);
      if (response.statusCode == 200 && response.data['success']) {
        _profile = User.fromJson(response.data['data']);
        return true;
      }
    } catch (e) {
      debugPrint('Update Staff Profile Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }
}

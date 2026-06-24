class ApiConstants {
  static const String baseUrl = 'http://192.168.1.60:5000/api';


  // Auth Endpoints
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refresh = '/auth/refresh';
  static const String changePassword = '/auth/change-password';
  static const String me = '/auth/me';

  // Staff Endpoints
  static const String dashboard = '/dashboard';
  static const String college = '/college';
  static const String course = '/course';
  static const String batch = '/batch';
  static const String timetable = '/timetable';
  static const String student = '/student';
  static const String attendance = '/attendance';
  static const String attendanceBulk = '/attendance/bulk';
  static const String attendanceLeave = '/attendance/leave';

  // Student Specific
  static const String timetableMe = '/timetable/me';
  static const String attendanceMe = '/attendance/me';

  // Holiday / Leave Endpoints
  static const String holiday = '/holiday';
}

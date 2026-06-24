class DashboardData {
  final DashboardSummary summary;
  final List<ClassEntry> todaysClasses;
  final List<ClassEntry> upcomingClasses;
  final List<RecentStudent> recentStudents;

  DashboardData({
    required this.summary,
    required this.todaysClasses,
    required this.upcomingClasses,
    required this.recentStudents,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return DashboardData(
      summary: DashboardSummary.fromJson(data['summary']),
      todaysClasses: (data['todaysClasses'] as List)
          .map((e) => ClassEntry.fromJson(e))
          .toList(),
      upcomingClasses: (data['upcomingClasses'] as List)
          .map((e) => ClassEntry.fromJson(e))
          .toList(),
      recentStudents: (data['recentStudents'] as List)
          .map((e) => RecentStudent.fromJson(e))
          .toList(),
    );
  }
}

class DashboardSummary {
  final int totalColleges;
  final int totalCourses;
  final int totalBatches;
  final int totalStudents;

  DashboardSummary({
    required this.totalColleges,
    required this.totalCourses,
    required this.totalBatches,
    required this.totalStudents,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalColleges: json['totalColleges'] ?? 0,
      totalCourses: json['totalCourses'] ?? 0,
      totalBatches: json['totalBatches'] ?? 0,
      totalStudents: json['totalStudents'] ?? 0,
    );
  }
}

class ClassEntry {
  final String id;
  final String subject;
  final String faculty;
  final String startTime;
  final String endTime;
  final String classroom;
  final BatchMiniInfo? batch;

  ClassEntry({
    required this.id,
    required this.subject,
    required this.faculty,
    required this.startTime,
    required this.endTime,
    required this.classroom,
    this.batch,
  });

  factory ClassEntry.fromJson(Map<String, dynamic> json) {
    return ClassEntry(
      id: json['_id'] ?? '',
      subject: json['subject'] ?? '',
      faculty: json['faculty'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      classroom: json['classroom'] ?? '',
      batch: json['batch'] != null ? BatchMiniInfo.fromJson(json['batch']) : null,
    );
  }
}

class BatchMiniInfo {
  final String name;
  final String? courseName;

  BatchMiniInfo({required this.name, this.courseName});

  factory BatchMiniInfo.fromJson(Map<String, dynamic> json) {
    return BatchMiniInfo(
      name: json['name'] ?? '',
      courseName: json['course'] != null ? json['course']['name'] : null,
    );
  }
}

class RecentStudent {
  final String id;
  final String fullName;
  final String studentId;
  final String? email;

  RecentStudent({
    required this.id,
    required this.fullName,
    required this.studentId,
    this.email,
  });

  factory RecentStudent.fromJson(Map<String, dynamic> json) {
    return RecentStudent(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      studentId: json['studentId'] ?? '',
      email: json['email'],
    );
  }
}

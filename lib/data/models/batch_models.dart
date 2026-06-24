import 'college_models.dart';
import 'course_models.dart';

class Batch {
  final String id;
  final String name;
  final String college;
  final String course;
  final String? courseName;
  final String? collegeName;
  final String facultyInCharge;
  final DateTime startDate;
  final DateTime? endDate;
  final String workingDays;
  final List<String> customWorkingDays;
  final String? duration;
  final String? startTime;
  final String? endTime;

  Batch({
    required this.id,
    required this.name,
    required this.college,
    this.courseName,
    this.collegeName,
    required this.course,
    required this.facultyInCharge,
    required this.startDate,
    this.endDate,
    required this.workingDays,
    required this.customWorkingDays,
    this.duration,
    this.startTime,
    this.endTime,
  });

  factory Batch.fromJson(Map<String, dynamic> json) {
    return Batch(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unnamed Batch',
      college: json['college'] != null 
          ? (json['college'] is String ? json['college'] : (json['college']['_id'] ?? '')) 
          : '',
      collegeName: json['college'] != null && json['college'] is Map ? json['college']['name'] : null,
      course: json['course'] != null 
          ? (json['course'] is String ? json['course'] : (json['course']['_id'] ?? '')) 
          : '',
      courseName: json['course'] != null && json['course'] is Map ? json['course']['name'] : null,
      facultyInCharge: json['facultyInCharge'] ?? json['facultyName'] ?? 'No Faculty',
      startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
      endDate: json['endDate'] != null ? DateTime.tryParse(json['endDate']) : null,
      workingDays: json['workingDays'] ?? 'Monday-Friday',
      customWorkingDays: (json['customWorkingDays'] as List? ?? []).map((e) => e.toString()).toList(),
      duration: json['duration'],
      startTime: json['startTime'],
      endTime: json['endTime'],
    );
  }
}

class BatchListResponse {
  final List<Batch> items;
  final int total;
  final int page;
  final int totalPages;

  BatchListResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.totalPages,
  });

  factory BatchListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final batchesData = data['batches'] as List? ?? [];
    final pagination = json['pagination'] ?? {
      'total': batchesData.length,
      'page': 1,
      'totalPages': 1,
    };
    return BatchListResponse(
      items: batchesData.map((e) => Batch.fromJson(e)).toList(),
      total: pagination['total'] ?? 0,
      page: pagination['page'] ?? 1,
      totalPages: pagination['totalPages'] ?? 1,
    );
  }
}

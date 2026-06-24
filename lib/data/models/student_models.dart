import 'college_models.dart';
import 'course_models.dart';

class Student {
  final String id;
  final String studentId;
  final String fullName;
  final String registerNumber;
  final String? rollNumber;
  final String email;
  final String? phone;
  final String? dateOfBirth;
  final String? gender;
  final String? address;
  final String? parentName;
  final String? parentPhone;
  final String? photo;
  final College? college;
  final Course? course;
  final BatchSummary? batch;
  final List<Certification> certifications;

  Student({
    required this.id,
    required this.studentId,
    required this.fullName,
    required this.registerNumber,
    this.rollNumber,
    required this.email,
    this.phone,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.parentName,
    this.parentPhone,
    this.photo,
    this.college,
    this.course,
    this.batch,
    required this.certifications,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['_id'] ?? '',
      studentId: json['studentId'] ?? '',
      fullName: json['fullName'] ?? 'Unnamed Student',
      registerNumber: json['registerNumber'] ?? '',
      rollNumber: json['rollNumber'],
      email: json['email'] ?? '',
      phone: json['phone'],
      dateOfBirth: json['dateOfBirth'],
      gender: json['gender'],
      address: json['address'],
      parentName: json['parentName'],
      parentPhone: json['parentPhone'],
      photo: json['photo'],
      college: json['college'] != null ? (json['college'] is String ? null : College.fromJson(json['college'])) : null,
      course: json['course'] != null ? (json['course'] is String ? null : Course.fromJson(json['course'])) : null,
      batch: json['batch'] != null ? (json['batch'] is String ? null : BatchSummary.fromJson(json['batch'])) : null,
      certifications: (json['certifications'] as List? ?? [])
          .map((e) => Certification.fromJson(e))
          .toList(),
    );
  }
}

class StudentListResponse {
  final List<Student> items;
  final int total;
  final int page;
  final int totalPages;

  StudentListResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.totalPages,
  });

  factory StudentListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final studentsData = data['students'] as List? ?? [];
    final pagination = json['pagination'] ?? {
      'total': studentsData.length,
      'page': 1,
      'totalPages': 1,
    };
    return StudentListResponse(
      items: studentsData.map((e) => Student.fromJson(e)).toList(),
      total: pagination['total'] ?? 0,
      page: pagination['page'] ?? 1,
      totalPages: pagination['totalPages'] ?? 1,
    );
  }
}

class BatchSummary {
  final String id;
  final String name;
  final String? duration;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? workingDays;
  final List<String> customWorkingDays;
  final String? startTime;
  final String? endTime;
  final String? facultyName;

  BatchSummary({
    required this.id, 
    required this.name, 
    this.duration,
    this.startDate,
    this.endDate,
    this.workingDays,
    this.customWorkingDays = const [],
    this.startTime,
    this.endTime,
    this.facultyName,
  });

  factory BatchSummary.fromJson(Map<String, dynamic> json) {
    return BatchSummary(
      id: json['_id'] ?? '', 
      name: json['name'] ?? 'Unnamed Batch',
      duration: json['duration'],
      startDate: json['startDate'] != null ? DateTime.tryParse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.tryParse(json['endDate']) : null,
      workingDays: json['workingDays'],
      customWorkingDays: (json['customWorkingDays'] as List? ?? []).map((e) => e.toString()).toList(),
      startTime: json['startTime'],
      endTime: json['endTime'],
      facultyName: json['facultyInCharge'] ?? json['facultyName'],
    );
  }
}

class Certification {
  final String id;
  final String name;
  final String url;
  final DateTime uploadedAt;

  Certification({
    required this.id,
    required this.name,
    required this.url,
    required this.uploadedAt,
  });

  factory Certification.fromJson(Map<String, dynamic> json) {
    return Certification(
      id: json['_id'],
      name: json['name'],
      url: json['url'],
      uploadedAt: DateTime.parse(json['uploadedAt']),
    );
  }
}

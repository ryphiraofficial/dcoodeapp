import 'package:flutter/foundation.dart';

class CertificateData {
  final String studentName;
  final String registerNumber;
  final String courseName;
  final String collegeName;
  final String batchName;
  final String startDate;
  final String endDate;
  final String certificateId;
  final String issueDate;
  final String description;

  CertificateData({
    required this.studentName,
    required this.registerNumber,
    required this.courseName,
    required this.collegeName,
    required this.batchName,
    required this.startDate,
    required this.endDate,
    required this.certificateId,
    required this.issueDate,
    this.description = '',
  });

  factory CertificateData.fromJson(Map<String, dynamic> json) {
    debugPrint('[DEBUG] Parsing CertificateData JSON: $json');
    
    // Extracting nested data based on the provided API structure
    final student = json['student'] as Map<String, dynamic>?;
    final course = json['course'] as Map<String, dynamic>?;
    final batch = json['batch'] as Map<String, dynamic>?;
    final college = json['college'] as Map<String, dynamic>?;

    return CertificateData(
      studentName: (student?['fullName'] ?? json['studentName'] ?? 'Unknown').toString(),
      registerNumber: (student?['registerNumber'] ?? json['registerNumber'] ?? 'N/A').toString(),
      courseName: (course?['name'] ?? json['courseName'] ?? '').toString(),
      collegeName: (college?['name'] ?? json['collegeName'] ?? '').toString(),
      batchName: (batch?['name'] ?? json['batchName'] ?? '').toString(),
      startDate: (batch?['startDate'] ?? json['startDate'] ?? '').toString(),
      endDate: (batch?['endDate'] ?? json['endDate'] ?? '').toString(),
      certificateId: (json['certificateId'] ?? json['_id'] ?? '').toString(),
      issueDate: (json['issueDate'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
    );
  }
}

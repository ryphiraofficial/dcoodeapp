class AttendanceRecord {
  final String id;
  final String studentId;
  final String studentName;
  final String registerNumber;
  final String batchId;
  final DateTime date;
  final String status; // Present, Absent, Late
  final String markedBy;
  final String? task;
  final String? description;
  final List<String> files;

  AttendanceRecord({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.registerNumber,
    required this.batchId,
    required this.date,
    required this.status,
    required this.markedBy,
    this.task,
    this.description,
    this.files = const [],
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    String sId = '';
    String sName = 'Unknown';
    String sReg = 'N/A';

    if (json['student'] != null) {
      if (json['student'] is Map) {
        sId = json['student']['_id'] ?? '';
        sName = json['student']['fullName'] ?? 'Unknown';
        sReg = json['student']['registerNumber'] ?? 'N/A';
      } else {
        sId = json['student'];
      }
    }

    return AttendanceRecord(
      id: json['_id'] ?? '',
      studentId: sId,
      studentName: sName,
      registerNumber: sReg,
      batchId: json['batch'] ?? '',
      date: DateTime.parse(json['date']).toLocal(),
      status: json['status'] ?? 'Absent',
      markedBy: json['markedBy'] is Map ? (json['markedBy']['name'] ?? 'Staff') : 'Staff',
      task: json['task'],
      description: json['description'],
      files: (json['files'] as List? ?? []).map((e) => e.toString()).toList(),
    );
  }
}

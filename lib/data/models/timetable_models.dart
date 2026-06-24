class TimetableEntry {
  final String id;
  final String batch;
  final String subject;
  final String faculty;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String classroom;

  TimetableEntry({
    required this.id,
    required this.batch,
    required this.subject,
    required this.faculty,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.classroom,
  });

  factory TimetableEntry.fromJson(Map<String, dynamic> json) {
    return TimetableEntry(
      id: json['_id'],
      batch: json['batch'] is String ? json['batch'] : json['batch']['_id'],
      subject: json['subject'],
      faculty: json['faculty'],
      date: DateTime.parse(json['date']).toLocal(),
      startTime: json['startTime'],
      endTime: json['endTime'],
      classroom: json['classroom'] ?? '',
    );
  }
}

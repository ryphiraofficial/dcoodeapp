class Holiday {
  final String id;
  final DateTime date;
  final String reason;
  final String? batchId;

  Holiday({
    required this.id,
    required this.date,
    required this.reason,
    this.batchId,
  });

  factory Holiday.fromJson(Map<String, dynamic> json) {
    return Holiday(
      id: json['_id'] ?? '',
      date: DateTime.parse(json['date']).toLocal(),
      reason: json['reason'] ?? 'Holiday',
      batchId: json['batch'] is Map ? json['batch']['_id'] : json['batch'],
    );
  }
}

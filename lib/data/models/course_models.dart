class Course {
  final String id;
  final String name;
  final String code;
  final List<String> durations;
  final String? description;
  final String college;

  Course({
    required this.id,
    required this.name,
    required this.code,
    required this.durations,
    this.description,
    required this.college,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unnamed Course',
      code: json['code'] ?? '',
      durations: (json['durations'] as List? ?? []).map((e) => e.toString()).toList(),
      description: json['description'],
      college: json['college'] != null 
          ? (json['college'] is String ? json['college'] : (json['college']['_id'] ?? '')) 
          : '',
    );
  }
}

class CourseListResponse {
  final List<Course> items;
  final int total;
  final int page;
  final int totalPages;

  CourseListResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.totalPages,
  });

  factory CourseListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final pagination = json['pagination'] ?? {
      'total': (data['courses'] as List).length,
      'page': 1,
      'totalPages': 1,
    };
    return CourseListResponse(
      items: (data['courses'] as List).map<Course>((e) => Course.fromJson(e)).toList(),
      total: pagination['total'],
      page: pagination['page'],
      totalPages: pagination['totalPages'],
    );
  }
}

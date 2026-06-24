class College {
  final String id;
  final String name;
  final String code;
  final String? address;
  final String? email;
  final String? phone;
  final String? principalName;
  final String status;
  final String? logo;

  College({
    required this.id,
    required this.name,
    required this.code,
    this.address,
    this.email,
    this.phone,
    this.principalName,
    required this.status,
    this.logo,
  });

  factory College.fromJson(Map<String, dynamic> json) {
    return College(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unnamed College',
      code: json['code'] ?? '',
      address: json['address'],
      email: json['email'],
      phone: json['phone'],
      principalName: json['principalName'],
      status: json['status'] ?? 'active',
      logo: json['logo'],
    );
  }
}

class CollegeListResponse {
  final List<College> items;
  final int total;
  final int page;
  final int totalPages;

  CollegeListResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.totalPages,
  });

  factory CollegeListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final collegesData = data['colleges'] as List? ?? [];
    final pagination = json['pagination'] ?? {
      'total': collegesData.length,
      'page': 1,
      'totalPages': 1,
    };
    return CollegeListResponse(
      items: collegesData.map((e) => College.fromJson(e)).toList(),
      total: pagination['total'] ?? 0,
      page: pagination['page'] ?? 1,
      totalPages: pagination['totalPages'] ?? 1,
    );
  }
}

class TeacherModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? specialization;
  final DateTime? createdAt;

  TeacherModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.specialization,
    this.createdAt,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      specialization: json['specialization'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'specialization': specialization,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}


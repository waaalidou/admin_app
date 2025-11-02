class StudentModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? courseId;
  final DateTime? createdAt;

  StudentModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.courseId,
    this.createdAt,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      courseId: json['course_id']?.toString(),
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
      'course_id': courseId,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}


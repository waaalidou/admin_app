class CourseModel {
  final String id;
  final String name;
  final String? description;
  final String? teacherId;
  final int? studentCount;
  final DateTime? createdAt;

  CourseModel({
    required this.id,
    required this.name,
    this.description,
    this.teacherId,
    this.studentCount,
    this.createdAt,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'],
      teacherId: json['teacher_id']?.toString(),
      studentCount: json['student_count'] ?? json['students_count'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'teacher_id': teacherId,
      'student_count': studentCount,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}


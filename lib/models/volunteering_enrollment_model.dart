class VolunteeringEnrollmentModel {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String opportunityId;
  final String opportunityTitle;
  final DateTime? enrolledAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  VolunteeringEnrollmentModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.opportunityId,
    required this.opportunityTitle,
    this.enrolledAt,
    this.createdAt,
    this.updatedAt,
  });

  // Convert from JSON (Supabase)
  factory VolunteeringEnrollmentModel.fromJson(Map<String, dynamic> json) {
    return VolunteeringEnrollmentModel(
      id: json['id'].toString(),
      userId: json['user_id']?.toString() ?? '',
      userName: json['user_name'] ?? '',
      userEmail: json['user_email'] ?? '',
      opportunityId: json['opportunity_id']?.toString() ?? '',
      opportunityTitle: json['opportunity_title'] ?? '',
      enrolledAt: json['enrolled_at'] != null
          ? DateTime.parse(json['enrolled_at'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  // Convert to JSON (Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_email': userEmail,
      'opportunity_id': opportunityId,
      'opportunity_title': opportunityTitle,
      'enrolled_at': enrolledAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}



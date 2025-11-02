class VolunteeringOpportunityModel {
  final String id;
  final String title;
  final String description;
  final String location;
  final String iconName;
  final String color; // Hex color string
  final int enrolledCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  VolunteeringOpportunityModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.iconName,
    required this.color,
    required this.enrolledCount,
    this.createdAt,
    this.updatedAt,
  });

  // Convert from JSON (Supabase)
  factory VolunteeringOpportunityModel.fromJson(Map<String, dynamic> json) {
    return VolunteeringOpportunityModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      iconName: json['icon_name'] ?? 'volunteer_activism',
      color: json['color'] ?? '#4CAF50',
      enrolledCount: json['enrolled_count'] ?? 0,
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
      'title': title,
      'description': description,
      'location': location,
      'icon_name': iconName,
      'color': color,
      'enrolled_count': enrolledCount,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}



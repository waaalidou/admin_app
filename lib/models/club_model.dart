class ClubModel {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final String color; // Hex color string
  final int memberCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ClubModel({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.color,
    required this.memberCount,
    this.createdAt,
    this.updatedAt,
  });

  // Convert from JSON (Supabase)
  factory ClubModel.fromJson(Map<String, dynamic> json) {
    return ClubModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      iconName: json['icon_name'] ?? 'group',
      color: json['color'] ?? '#194CBF',
      memberCount: json['member_count'] ?? 0,
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
      'name': name,
      'description': description,
      'icon_name': iconName,
      'color': color,
      'member_count': memberCount,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}



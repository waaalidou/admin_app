class SuggestionModel {
  final String id;
  final String? userId;
  final String? userName;
  final String? userEmail;
  final String? title;
  final String? name;
  final String suggestion;
  final String? content;
  final String? description;
  final String? status; // e.g., 'pending', 'reviewed', 'approved', 'rejected'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SuggestionModel({
    required this.id,
    this.userId,
    this.userName,
    this.userEmail,
    this.title,
    this.name,
    required this.suggestion,
    this.content,
    this.description,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory SuggestionModel.fromJson(Map<String, dynamic> json) {
    // Handle different possible field names for the suggestion content
    String suggestionText = json['suggestion'] ?? 
                           json['content'] ?? 
                           json['description'] ?? 
                           json['message'] ?? 
                           json['text'] ?? 
                           '';
    
    // Handle title/name fields
    String? titleValue = json['title'] ?? json['name'] ?? json['subject'];
    
    return SuggestionModel(
      id: json['id'].toString(),
      userId: json['user_id']?.toString() ?? json['userId']?.toString(),
      userName: json['user_name'] ?? json['userName'] ?? json['name'],
      userEmail: json['user_email'] ?? json['userEmail'] ?? json['email'],
      title: titleValue,
      name: json['name'] ?? titleValue,
      suggestion: suggestionText,
      content: json['content'] ?? json['description'] ?? suggestionText,
      description: json['description'],
      status: json['status'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : (json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : (json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_email': userEmail,
      'title': title,
      'name': name,
      'suggestion': suggestion,
      'content': content,
      'description': description,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
  
  // Get the display title (prioritizes title > name > first part of suggestion)
  String get displayTitle {
    if (title != null && title!.isNotEmpty) return title!;
    if (name != null && name!.isNotEmpty) return name!;
    if (suggestion.isNotEmpty) {
      // Get first 50 characters as title
      return suggestion.length > 50 ? '${suggestion.substring(0, 50)}...' : suggestion;
    }
    return 'Untitled Suggestion';
  }
  
  // Get the display content
  String get displayContent {
    if (suggestion.isNotEmpty) return suggestion;
    if (content != null && content!.isNotEmpty) return content!;
    if (description != null && description!.isNotEmpty) return description!;
    return '';
  }
}


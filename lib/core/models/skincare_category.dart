class SkincareCategory {
  final String id;
  final String? userId;
  final String name;
  final String color;
  final bool isDefault;
  final DateTime? createdAt;

  SkincareCategory({
    required this.id,
    this.userId,
    required this.name,
    required this.color,
    this.isDefault = false,
    this.createdAt,
  });

  factory SkincareCategory.fromJson(Map<String, dynamic> json) {
    return SkincareCategory(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      name: json['name'] as String? ?? '',
      color: json['color'] as String? ?? '0xFFE040FB',
      isDefault: json['is_default'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'color': color,
      'is_default': isDefault,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  SkincareCategory copyWith({
    String? id,
    String? userId,
    String? name,
    String? color,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return SkincareCategory(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

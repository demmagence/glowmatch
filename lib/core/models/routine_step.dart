class RoutineStep {
  final String id;
  final String routineType;
  final int stepNumber;
  final String name;
  final String? description;
  final String? shelfItemId;

  RoutineStep({
    required this.id,
    required this.routineType,
    required this.stepNumber,
    required this.name,
    this.description,
    this.shelfItemId,
  });

  factory RoutineStep.fromJson(Map<String, dynamic> json) {
    return RoutineStep(
      id: json['id'] as String,
      routineType: json['routine_type'] as String? ?? 'AM',
      stepNumber: json['step_number'] as int? ?? 1,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      shelfItemId: json['shelf_item_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'routine_type': routineType,
      'step_number': stepNumber,
      'name': name,
      'description': description,
      'shelf_item_id': shelfItemId,
    };
  }

  RoutineStep copyWith({
    String? id,
    String? routineType,
    int? stepNumber,
    String? name,
    String? description,
    String? shelfItemId,
  }) {
    return RoutineStep(
      id: id ?? this.id,
      routineType: routineType ?? this.routineType,
      stepNumber: stepNumber ?? this.stepNumber,
      name: name ?? this.name,
      description: description ?? this.description,
      shelfItemId: shelfItemId ?? this.shelfItemId,
    );
  }
}

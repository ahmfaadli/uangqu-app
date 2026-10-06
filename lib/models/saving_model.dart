class SavingModel {
  final int? id;
  final String name;
  final int targetAmount;
  final int currentAmount;
  final DateTime createdAt;

  SavingModel({
    this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.createdAt,
  });

  double get progress {
    if (targetAmount <= 0) {
      return 0;
    }

    final value = currentAmount / targetAmount;

    return value.clamp(0.0, 1.0);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory SavingModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return SavingModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      targetAmount:
          (map['target_amount'] as num).toInt(),
      currentAmount:
          (map['current_amount'] as num).toInt(),
      createdAt:
          DateTime.parse(map['created_at'] as String),
    );
  }
}
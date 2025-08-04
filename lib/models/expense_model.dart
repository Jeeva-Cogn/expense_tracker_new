import 'package:hive_flutter/hive_flutter.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 0)
class Expense extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final String? source;

  @HiveField(6)
  final Map<String, dynamic>? metadata;

  Expense({
    required this.id,
    required this.amount,
    required this.description,
    required this.category,
    required this.date,
    this.source,
    this.metadata,
  });

  Expense copyWith({
    String? id,
    double? amount,
    String? description,
    String? category,
    DateTime? date,
    String? source,
    Map<String, dynamic>? metadata,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      category: category ?? this.category,
      date: date ?? this.date,
      source: source ?? this.source,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'category': category,
      'date': date.toIso8601String(),
      'source': source,
      'metadata': metadata,
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      category: json['category'] as String,
      date: DateTime.parse(json['date'] as String),
      source: json['source'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() {
    return 'Expense(id: $id, amount: $amount, description: $description, category: $category, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Expense &&
        other.id == id &&
        other.amount == amount &&
        other.description == description &&
        other.category == category &&
        other.date == date &&
        other.source == source;
  }

  @override
  int get hashCode {
    return Object.hash(id, amount, description, category, date, source);
  }
}

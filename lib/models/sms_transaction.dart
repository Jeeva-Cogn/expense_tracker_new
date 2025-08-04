import 'package:hive_flutter/hive_flutter.dart';

part 'sms_transaction.g.dart';

@HiveType(typeId: 2)
class SMSTransaction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String rawMessage;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String type; // DEBIT, CREDIT

  @HiveField(4)
  final String? merchant;

  @HiveField(5)
  final String category;

  @HiveField(6)
  final DateTime date;

  @HiveField(7)
  final double confidence;

  @HiveField(8)
  final String description;

  @HiveField(9)
  final String? accountNumber;

  SMSTransaction({
    required this.id,
    required this.rawMessage,
    required this.amount,
    required this.type,
    this.merchant,
    required this.category,
    required this.date,
    required this.confidence,
    required this.description,
    this.accountNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rawMessage': rawMessage,
      'amount': amount,
      'type': type,
      'merchant': merchant,
      'category': category,
      'date': date.toIso8601String(),
      'confidence': confidence,
      'description': description,
      'accountNumber': accountNumber,
    };
  }

  factory SMSTransaction.fromJson(Map<String, dynamic> json) {
    return SMSTransaction(
      id: json['id'] as String,
      rawMessage: json['rawMessage'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      merchant: json['merchant'] as String?,
      category: json['category'] as String,
      date: DateTime.parse(json['date'] as String),
      confidence: (json['confidence'] as num).toDouble(),
      description: json['description'] as String,
      accountNumber: json['accountNumber'] as String?,
    );
  }

  @override
  String toString() {
    return 'SMSTransaction(id: $id, amount: $amount, type: $type, merchant: $merchant, category: $category)';
  }
}

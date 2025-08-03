import 'package:hive/hive.dart';

part 'bill_reminder.g.dart';

@HiveType(typeId: 9)
class BillReminder extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? description;

  @HiveField(3)
  double amount;

  @HiveField(4)
  String category;

  @HiveField(5)
  DateTime dueDate;

  @HiveField(6)
  ReminderFrequency frequency;

  @HiveField(7)
  List<int> reminderDays; // Days before due date to remind

  @HiveField(8)
  bool isActive;

  @HiveField(9)
  bool autoAddExpense;

  @HiveField(10)
  String? walletId;

  @HiveField(11)
  DateTime? lastPaid;

  @HiveField(12)
  DateTime? nextDue;

  @HiveField(13)
  String color;

  @HiveField(14)
  String icon;

  @HiveField(15)
  DateTime createdAt;

  @HiveField(16)
  DateTime updatedAt;

  BillReminder({
    required this.id,
    required this.name,
    this.description,
    required this.amount,
    required this.category,
    required this.dueDate,
    this.frequency = ReminderFrequency.monthly,
    List<int>? reminderDays,
    this.isActive = true,
    this.autoAddExpense = false,
    this.walletId,
    this.lastPaid,
    DateTime? nextDue,
    this.color = '#F44336',
    this.icon = '💳',
    required this.createdAt,
    required this.updatedAt,
  }) : reminderDays = reminderDays ?? [1, 3, 7],
       nextDue = nextDue ?? _calculateNextDue(dueDate, frequency);

  // Helper methods
  static DateTime _calculateNextDue(DateTime dueDate, ReminderFrequency frequency) {
    final now = DateTime.now();
    DateTime next = dueDate;
    
    while (next.isBefore(now)) {
      switch (frequency) {
        case ReminderFrequency.weekly:
          next = next.add(const Duration(days: 7));
          break;
        case ReminderFrequency.monthly:
          next = DateTime(next.year, next.month + 1, next.day);
          break;
        case ReminderFrequency.quarterly:
          next = DateTime(next.year, next.month + 3, next.day);
          break;
        case ReminderFrequency.yearly:
          next = DateTime(next.year + 1, next.month, next.day);
          break;
        case ReminderFrequency.custom:
          next = next.add(const Duration(days: 30)); // Default to monthly
          break;
      }
    }
    
    return next;
  }

  int get daysUntilDue {
    if (nextDue == null) return 0;
    final now = DateTime.now();
    final difference = nextDue!.difference(DateTime(now.year, now.month, now.day));
    return difference.inDays;
  }

  bool get isDueToday => daysUntilDue == 0;
  bool get isOverdue => daysUntilDue < 0;
  bool get needsReminder => reminderDays.contains(daysUntilDue);

  String get statusText {
    if (isOverdue) return 'Overdue';
    if (isDueToday) return 'Due Today';
    if (daysUntilDue <= 7) return 'Due Soon';
    return 'Upcoming';
  }

  String get urgencyEmoji {
    if (isOverdue) return '🚨';
    if (isDueToday) return '⚠️';
    if (daysUntilDue <= 3) return '🔔';
    return '📅';
  }

  void markAsPaid() {
    lastPaid = DateTime.now();
    nextDue = _calculateNextDue(nextDue ?? dueDate, frequency);
    updatedAt = DateTime.now();
  }

  void updateNextDue() {
    nextDue = _calculateNextDue(nextDue ?? dueDate, frequency);
    updatedAt = DateTime.now();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'amount': amount,
    'category': category,
    'dueDate': dueDate.toIso8601String(),
    'frequency': frequency.name,
    'reminderDays': reminderDays,
    'isActive': isActive,
    'autoAddExpense': autoAddExpense,
    'walletId': walletId,
    'lastPaid': lastPaid?.toIso8601String(),
    'nextDue': nextDue?.toIso8601String(),
    'color': color,
    'icon': icon,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory BillReminder.fromJson(Map<String, dynamic> json) => BillReminder(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    amount: json['amount'].toDouble(),
    category: json['category'],
    dueDate: DateTime.parse(json['dueDate']),
    frequency: ReminderFrequency.values.firstWhere((e) => e.name == json['frequency']),
    reminderDays: List<int>.from(json['reminderDays']),
    isActive: json['isActive'] ?? true,
    autoAddExpense: json['autoAddExpense'] ?? false,
    walletId: json['walletId'],
    lastPaid: json['lastPaid'] != null ? DateTime.parse(json['lastPaid']) : null,
    nextDue: json['nextDue'] != null ? DateTime.parse(json['nextDue']) : null,
    color: json['color'] ?? '#F44336',
    icon: json['icon'] ?? '💳',
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );
}

@HiveType(typeId: 10)
enum ReminderFrequency {
  @HiveField(0)
  weekly,
  @HiveField(1)
  monthly,
  @HiveField(2)
  quarterly,
  @HiveField(3)
  yearly,
  @HiveField(4)
  custom,
}

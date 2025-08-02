import 'package:hive/hive.dart';

part 'wallet.g.dart';

@HiveType(typeId: 3)
class Wallet extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? description;

  @HiveField(3)
  double balance;

  @HiveField(4)
  String currency;

  @HiveField(5)
  String color; // Hex color code

  @HiveField(6)
  String icon; // Icon name or emoji

  @HiveField(7)
  WalletType type;

  @HiveField(8)
  List<String> sharedWith; // User IDs for shared wallets

  @HiveField(9)
  Map<String, WalletPermission> permissions; // User permissions

  @HiveField(10)
  bool isDefault;

  @HiveField(11)
  bool isSynced;

  @HiveField(12)
  DateTime createdAt;

  @HiveField(13)
  DateTime updatedAt;

  Wallet({
    required this.id,
    required this.name,
    this.description,
    this.balance = 0.0,
    this.currency = '₹',
    this.color = '#2196F3',
    this.icon = '💳',
    this.type = WalletType.personal,
    List<String>? sharedWith,
    Map<String, WalletPermission>? permissions,
    this.isDefault = false,
    this.isSynced = false,
    required this.createdAt,
    required this.updatedAt,
  }) : sharedWith = sharedWith ?? [],
       permissions = permissions ?? {};

  // Helper methods
  bool get isShared => type == WalletType.shared;
  bool get isPersonal => type == WalletType.personal;
  bool get isFamily => type == WalletType.family;
  
  bool canEdit(String userId) {
    if (isPersonal) return true;
    final permission = permissions[userId];
    return permission == WalletPermission.admin || permission == WalletPermission.edit;
  }
  
  bool canView(String userId) {
    if (isPersonal) return true;
    return permissions.containsKey(userId);
  }

  void addUser(String userId, WalletPermission permission) {
    if (!sharedWith.contains(userId)) {
      sharedWith.add(userId);
    }
    permissions[userId] = permission;
  }

  void removeUser(String userId) {
    sharedWith.remove(userId);
    permissions.remove(userId);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'balance': balance,
    'currency': currency,
    'color': color,
    'icon': icon,
    'type': type.name,
    'sharedWith': sharedWith,
    'permissions': permissions.map((k, v) => MapEntry(k, v.name)),
    'isDefault': isDefault,
    'isSynced': isSynced,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    balance: json['balance'].toDouble(),
    currency: json['currency'] ?? '₹',
    color: json['color'] ?? '#2196F3',
    icon: json['icon'] ?? '💳',
    type: WalletType.values.firstWhere((e) => e.name == json['type']),
    sharedWith: List<String>.from(json['sharedWith'] ?? []),
    permissions: (json['permissions'] as Map<String, dynamic>?)?.map(
      (k, v) => MapEntry(k, WalletPermission.values.firstWhere((e) => e.name == v))
    ) ?? {},
    isDefault: json['isDefault'] ?? false,
    isSynced: json['isSynced'] ?? false,
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );
}

@HiveType(typeId: 4)
enum WalletType {
  @HiveField(0)
  personal,
  @HiveField(1)
  shared,
  @HiveField(2)
  family,
  @HiveField(3)
  business,
}

@HiveType(typeId: 5)
enum WalletPermission {
  @HiveField(0)
  view,
  @HiveField(1)
  edit,
  @HiveField(2)
  admin,
}

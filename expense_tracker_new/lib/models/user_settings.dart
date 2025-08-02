import 'package:hive/hive.dart';

part 'user_settings.g.dart';

@HiveType(typeId: 11)
class UserSettings extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? email;

  @HiveField(3)
  String currency;

  @HiveField(4)
  String language;

  @HiveField(5)
  String theme; // 'light', 'dark', 'system'

  @HiveField(6)
  bool biometricEnabled;

  @HiveField(7)
  bool notificationsEnabled;

  @HiveField(8)
  bool smsParsingEnabled;

  @HiveField(9)
  bool cloudSyncEnabled;

  @HiveField(10)
  String? cloudProvider; // 'firebase', 'gdrive'

  @HiveField(11)
  Map<String, bool> categoryNotifications;

  @HiveField(12)
  double budgetAlertThreshold;

  @HiveField(13)
  bool showMotivationalQuotes;

  @HiveField(14)
  List<String> favoriteCategories;

  @HiveField(15)
  String dateFormat; // 'dd/mm/yyyy', 'mm/dd/yyyy', etc.

  @HiveField(16)
  bool autoBackup;

  @HiveField(17)
  int backupFrequencyDays;

  @HiveField(18)
  DateTime? lastBackup;

  @HiveField(19)
  String? profileImagePath;

  @HiveField(20)
  DateTime createdAt;

  @HiveField(21)
  DateTime updatedAt;

  UserSettings({
    required this.id,
    required this.name,
    this.email,
    this.currency = '₹',
    this.language = 'en', // 'en', 'hi', 'ta'
    this.theme = 'system',
    this.biometricEnabled = false,
    this.notificationsEnabled = true,
    this.smsParsingEnabled = true,
    this.cloudSyncEnabled = false,
    this.cloudProvider,
    Map<String, bool>? categoryNotifications,
    this.budgetAlertThreshold = 0.8,
    this.showMotivationalQuotes = true,
    List<String>? favoriteCategories,
    this.dateFormat = 'dd/mm/yyyy',
    this.autoBackup = true,
    this.backupFrequencyDays = 7,
    this.lastBackup,
    this.profileImagePath,
    required this.createdAt,
    required this.updatedAt,
  }) : categoryNotifications = categoryNotifications ?? {},
       favoriteCategories = favoriteCategories ?? [];

  // Helper methods
  bool get isDarkMode => theme == 'dark';
  bool get isLightMode => theme == 'light';
  bool get isSystemMode => theme == 'system';
  
  bool get needsBackup {
    if (!autoBackup || lastBackup == null) return autoBackup;
    final daysSinceBackup = DateTime.now().difference(lastBackup!).inDays;
    return daysSinceBackup >= backupFrequencyDays;
  }

  String get languageDisplayName {
    switch (language) {
      case 'hi':
        return 'हिंदी';
      case 'ta':
        return 'தமிழ்';
      case 'en':
      default:
        return 'English';
    }
  }

  void updateLastBackup() {
    lastBackup = DateTime.now();
    updatedAt = DateTime.now();
  }

  void toggleCategoryNotification(String category) {
    categoryNotifications[category] = !(categoryNotifications[category] ?? true);
    updatedAt = DateTime.now();
  }

  void addFavoriteCategory(String category) {
    if (!favoriteCategories.contains(category)) {
      favoriteCategories.add(category);
      updatedAt = DateTime.now();
    }
  }

  void removeFavoriteCategory(String category) {
    favoriteCategories.remove(category);
    updatedAt = DateTime.now();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'currency': currency,
    'language': language,
    'theme': theme,
    'biometricEnabled': biometricEnabled,
    'notificationsEnabled': notificationsEnabled,
    'smsParsingEnabled': smsParsingEnabled,
    'cloudSyncEnabled': cloudSyncEnabled,
    'cloudProvider': cloudProvider,
    'categoryNotifications': categoryNotifications,
    'budgetAlertThreshold': budgetAlertThreshold,
    'showMotivationalQuotes': showMotivationalQuotes,
    'favoriteCategories': favoriteCategories,
    'dateFormat': dateFormat,
    'autoBackup': autoBackup,
    'backupFrequencyDays': backupFrequencyDays,
    'lastBackup': lastBackup?.toIso8601String(),
    'profileImagePath': profileImagePath,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    currency: json['currency'] ?? '₹',
    language: json['language'] ?? 'en',
    theme: json['theme'] ?? 'system',
    biometricEnabled: json['biometricEnabled'] ?? false,
    notificationsEnabled: json['notificationsEnabled'] ?? true,
    smsParsingEnabled: json['smsParsingEnabled'] ?? true,
    cloudSyncEnabled: json['cloudSyncEnabled'] ?? false,
    cloudProvider: json['cloudProvider'],
    categoryNotifications: Map<String, bool>.from(json['categoryNotifications'] ?? {}),
    budgetAlertThreshold: json['budgetAlertThreshold']?.toDouble() ?? 0.8,
    showMotivationalQuotes: json['showMotivationalQuotes'] ?? true,
    favoriteCategories: List<String>.from(json['favoriteCategories'] ?? []),
    dateFormat: json['dateFormat'] ?? 'dd/mm/yyyy',
    autoBackup: json['autoBackup'] ?? true,
    backupFrequencyDays: json['backupFrequencyDays'] ?? 7,
    lastBackup: json['lastBackup'] != null ? DateTime.parse(json['lastBackup']) : null,
    profileImagePath: json['profileImagePath'],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );
}

class MotivationalQuotes {
  static const List<String> quotes = [
    "💰 A penny saved is a penny earned!",
    "🌟 Small steps lead to big financial dreams!",
    "💪 You're building wealth one expense at a time!",
    "🎯 Every budget is a step toward financial freedom!",
    "✨ Your future self will thank you for today's choices!",
    "🚀 Financial discipline today, freedom tomorrow!",
    "💎 You're worth the effort of smart money management!",
    "🌈 Every rupee saved brings you closer to your dreams!",
    "🔥 Your commitment to budgeting is inspiring!",
    "⭐ Wealth is built through consistent small actions!",
    "🌸 Financial peace of mind is priceless!",
    "🎨 You're painting a beautiful financial future!",
    "🌱 Money grows when you nurture it wisely!",
    "🏆 You're winning at the money game!",
    "💝 Investing in yourself is the best investment!",
    "🌺 Bloom where you budget and grow your wealth!",
    "🎪 Life is a circus, but your budget keeps you balanced!",
    "🍀 Lucky are those who budget wisely!",
    "🎵 Make your money sing with smart choices!",
    "🦋 Transform your financial habits, transform your life!"
  ];

  static String getRandomQuote() {
    final now = DateTime.now();
    final index = (now.day + now.month) % quotes.length;
    return quotes[index];
  }

  static String getTodaysQuote() {
    final now = DateTime.now();
    final index = now.day % quotes.length;
    return quotes[index];
  }
}

import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  late SharedPreferences _prefs;

  // Initialize the service
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Currency settings
  String get defaultCurrency => _prefs.getString('defaultCurrency') ?? 'USD';
  Future<void> setDefaultCurrency(String currency) async {
    await _prefs.setString('defaultCurrency', currency);
  }

  // Theme settings
  bool get isDarkMode => _prefs.getBool('isDarkMode') ?? false;
  Future<void> setDarkMode(bool value) async {
    await _prefs.setBool('isDarkMode', value);
  }

  // Notification settings
  bool get notificationsEnabled => _prefs.getBool('notificationsEnabled') ?? true;
  Future<void> setNotificationsEnabled(bool value) async {
    await _prefs.setBool('notificationsEnabled', value);
  }

  bool get budgetAlertsEnabled => _prefs.getBool('budgetAlertsEnabled') ?? true;
  Future<void> setBudgetAlertsEnabled(bool value) async {
    await _prefs.setBool('budgetAlertsEnabled', value);
  }

  bool get monthlyReportsEnabled => _prefs.getBool('monthlyReportsEnabled') ?? true;
  Future<void> setMonthlyReportsEnabled(bool value) async {
    await _prefs.setBool('monthlyReportsEnabled', value);
  }

  // Biometric settings
  bool get biometricEnabled => _prefs.getBool('biometricEnabled') ?? false;
  Future<void> setBiometricEnabled(bool value) async {
    await _prefs.setBool('biometricEnabled', value);
  }

  // SMS parsing settings
  bool get smsParsingEnabled => _prefs.getBool('smsParsingEnabled') ?? false;
  Future<void> setSmsParsingEnabled(bool value) async {
    await _prefs.setBool('smsParsingEnabled', value);
  }

  // Auto-categorization settings
  bool get autoCategorizeEnabled => _prefs.getBool('autoCategorizeEnabled') ?? true;
  Future<void> setAutoCategorizeEnabled(bool value) async {
    await _prefs.setBool('autoCategorizeEnabled', value);
  }

  // Privacy settings
  bool get analyticsEnabled => _prefs.getBool('analyticsEnabled') ?? true;
  Future<void> setAnalyticsEnabled(bool value) async {
    await _prefs.setBool('analyticsEnabled', value);
  }

  bool get crashReportingEnabled => _prefs.getBool('crashReportingEnabled') ?? true;
  Future<void> setCrashReportingEnabled(bool value) async {
    await _prefs.setBool('crashReportingEnabled', value);
  }

  // Backup settings
  bool get autoBackupEnabled => _prefs.getBool('autoBackupEnabled') ?? false;
  Future<void> setAutoBackupEnabled(bool value) async {
    await _prefs.setBool('autoBackupEnabled', value);
  }

  String get backupFrequency => _prefs.getString('backupFrequency') ?? 'weekly';
  Future<void> setBackupFrequency(String frequency) async {
    await _prefs.setString('backupFrequency', frequency);
  }

  // Spending limit settings
  double get dailySpendingLimit => _prefs.getDouble('dailySpendingLimit') ?? 100.0;
  Future<void> setDailySpendingLimit(double limit) async {
    await _prefs.setDouble('dailySpendingLimit', limit);
  }

  double get monthlySpendingLimit => _prefs.getDouble('monthlySpendingLimit') ?? 3000.0;
  Future<void> setMonthlySpendingLimit(double limit) async {
    await _prefs.setDouble('monthlySpendingLimit', limit);
  }

  // Language settings
  String get appLanguage => _prefs.getString('appLanguage') ?? 'en';
  Future<void> setAppLanguage(String language) async {
    await _prefs.setString('appLanguage', language);
  }

  // Date format settings
  String get dateFormat => _prefs.getString('dateFormat') ?? 'MM/dd/yyyy';
  Future<void> setDateFormat(String format) async {
    await _prefs.setString('dateFormat', format);
  }

  // First time setup
  bool get isFirstTime => _prefs.getBool('isFirstTime') ?? true;
  Future<void> setFirstTime(bool value) async {
    await _prefs.setBool('isFirstTime', value);
  }

  // User onboarding
  bool get onboardingCompleted => _prefs.getBool('onboardingCompleted') ?? false;
  Future<void> setOnboardingCompleted(bool value) async {
    await _prefs.setBool('onboardingCompleted', value);
  }

  // Last sync settings
  DateTime? get lastSyncTime {
    final timestamp = _prefs.getInt('lastSyncTime');
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }

  Future<void> setLastSyncTime(DateTime time) async {
    await _prefs.setInt('lastSyncTime', time.millisecondsSinceEpoch);
  }

  // Get all settings as a map
  Map<String, dynamic> getAllSettings() {
    return {
      'defaultCurrency': defaultCurrency,
      'isDarkMode': isDarkMode,
      'notificationsEnabled': notificationsEnabled,
      'budgetAlertsEnabled': budgetAlertsEnabled,
      'monthlyReportsEnabled': monthlyReportsEnabled,
      'biometricEnabled': biometricEnabled,
      'smsParsingEnabled': smsParsingEnabled,
      'autoCategorizeEnabled': autoCategorizeEnabled,
      'analyticsEnabled': analyticsEnabled,
      'crashReportingEnabled': crashReportingEnabled,
      'autoBackupEnabled': autoBackupEnabled,
      'backupFrequency': backupFrequency,
      'dailySpendingLimit': dailySpendingLimit,
      'monthlySpendingLimit': monthlySpendingLimit,
      'appLanguage': appLanguage,
      'dateFormat': dateFormat,
      'isFirstTime': isFirstTime,
      'onboardingCompleted': onboardingCompleted,
      'lastSyncTime': lastSyncTime?.toIso8601String(),
    };
  }

  // Clear all settings
  Future<void> clearAllSettings() async {
    await _prefs.clear();
  }

  // Reset to defaults
  Future<void> resetToDefaults() async {
    await _prefs.clear();
    await init();
  }
}

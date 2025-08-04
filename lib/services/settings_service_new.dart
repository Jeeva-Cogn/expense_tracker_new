import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSettings {
  final bool biometricEnabled;
  final bool notificationsEnabled;
  final bool cloudSyncEnabled;
  final String theme;
  final String currency;

  UserSettings({
    this.biometricEnabled = false,
    this.notificationsEnabled = true,
    this.cloudSyncEnabled = false,
    this.theme = 'dark',
    this.currency = 'INR',
  });

  UserSettings copyWith({
    bool? biometricEnabled,
    bool? notificationsEnabled,
    bool? cloudSyncEnabled,
    String? theme,
    String? currency,
  }) {
    return UserSettings(
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      cloudSyncEnabled: cloudSyncEnabled ?? this.cloudSyncEnabled,
      theme: theme ?? this.theme,
      currency: currency ?? this.currency,
    );
  }
}

class SettingsService extends ChangeNotifier {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  late SharedPreferences _prefs;
  UserSettings _settings = UserSettings();

  UserSettings get settings => _settings;

  // Initialize the service
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSettings();
  }

  void _loadSettings() {
    _settings = UserSettings(
      biometricEnabled: _prefs.getBool('biometricEnabled') ?? false,
      notificationsEnabled: _prefs.getBool('notificationsEnabled') ?? true,
      cloudSyncEnabled: _prefs.getBool('cloudSyncEnabled') ?? false,
      theme: _prefs.getString('theme') ?? 'dark',
      currency: _prefs.getString('currency') ?? 'INR',
    );
    notifyListeners();
  }

  Future<void> toggleBiometric(bool value) async {
    await _prefs.setBool('biometricEnabled', value);
    _settings = _settings.copyWith(biometricEnabled: value);
    notifyListeners();
  }

  Future<void> toggleNotifications(bool value) async {
    await _prefs.setBool('notificationsEnabled', value);
    _settings = _settings.copyWith(notificationsEnabled: value);
    notifyListeners();
  }

  Future<void> toggleCloudSync(bool value) async {
    await _prefs.setBool('cloudSyncEnabled', value);
    _settings = _settings.copyWith(cloudSyncEnabled: value);
    notifyListeners();
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

  // Biometric settings
  bool get biometricEnabled => _prefs.getBool('biometricEnabled') ?? false;
  Future<void> setBiometricEnabled(bool value) async {
    await _prefs.setBool('biometricEnabled', value);
  }

  // Cloud sync settings
  bool get cloudSyncEnabled => _prefs.getBool('cloudSyncEnabled') ?? false;
  Future<void> setCloudSyncEnabled(bool value) async {
    await _prefs.setBool('cloudSyncEnabled', value);
  }

  // Budget alert settings
  bool get budgetAlertsEnabled => _prefs.getBool('budgetAlertsEnabled') ?? true;
  Future<void> setBudgetAlertsEnabled(bool value) async {
    await _prefs.setBool('budgetAlertsEnabled', value);
  }

  double get budgetAlertThreshold => _prefs.getDouble('budgetAlertThreshold') ?? 80.0;
  Future<void> setBudgetAlertThreshold(double value) async {
    await _prefs.setDouble('budgetAlertThreshold', value);
  }
}

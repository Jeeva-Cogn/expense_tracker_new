import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_settings.dart';
import 'biometric_auth_service.dart';

class SettingsService extends ChangeNotifier {
  static const String _boxName = 'user_settings';
  static const String _settingsKey = 'main_settings';
  
  Box<UserSettings>? _box;
  UserSettings? _settings;
  
  UserSettings get settings => _settings ?? _getDefaultSettings();
  
  // Initialize the service
  Future<void> initialize() async {
    _box = await Hive.openBox<UserSettings>(_boxName);
    _settings = _box?.get(_settingsKey) ?? _getDefaultSettings();
    await _saveSettings();
    notifyListeners();
  }
  
  UserSettings _getDefaultSettings() {
    final now = DateTime.now();
    return UserSettings(
      id: 'user_main',
      name: 'User',
      currency: '₹',
      language: 'en',
      theme: 'system',
      biometricEnabled: false,
      notificationsEnabled: true,
      smsParsingEnabled: true,
      cloudSyncEnabled: false,
      budgetAlertThreshold: 0.8,
      showMotivationalQuotes: true,
      dateFormat: 'dd/mm/yyyy',
      autoBackup: true,
      backupFrequencyDays: 7,
      createdAt: now,
      updatedAt: now,
    );
  }
  
  Future<void> _saveSettings() async {
    if (_box != null && _settings != null) {
      _settings!.updatedAt = DateTime.now();
      await _box!.put(_settingsKey, _settings!);
    }
  }
  
  // Budget Settings
  double? _monthlyBudget;
  double? _dailyBudget;
  List<String> _categories = [
    'Food & Dining',
    'Transportation',
    'Entertainment',
    'Shopping',
    'Bills & Utilities',
    'Healthcare',
    'Education',
    'Travel',
    'Investment',
    'Other'
  ];
  
  double? get monthlyBudget => _monthlyBudget;
  double? get dailyBudget => _dailyBudget;
  List<String> get categories => List.unmodifiable(_categories);
  
  Future<void> setMonthlyBudget(double? budget) async {
    _monthlyBudget = budget;
    await _saveSettings();
    notifyListeners();
  }
  
  Future<void> setDailyBudget(double? budget) async {
    _dailyBudget = budget;
    await _saveSettings();
    notifyListeners();
  }
  
  Future<void> addCategory(String category) async {
    if (!_categories.contains(category) && category.trim().isNotEmpty) {
      _categories.add(category.trim());
      await _saveSettings();
      notifyListeners();
    }
  }
  
  Future<void> removeCategory(String category) async {
    _categories.remove(category);
    await _saveSettings();
    notifyListeners();
  }
  
  Future<void> updateCategories(List<String> newCategories) async {
    _categories = newCategories.where((c) => c.trim().isNotEmpty).toList();
    await _saveSettings();
    notifyListeners();
  }
  
  // User Settings Updates
  Future<void> updateUserName(String name) async {
    _settings!.name = name;
    await _saveSettings();
    notifyListeners();
  }
  
  Future<void> updateEmail(String? email) async {
    _settings!.email = email;
    await _saveSettings();
    notifyListeners();
  }
  
  Future<void> updateCurrency(String currency) async {
    _settings!.currency = currency;
    await _saveSettings();
    notifyListeners();
  }
  
  Future<void> updateLanguage(String language) async {
    _settings!.language = language;
    await _saveSettings();
    notifyListeners();
  }
  
  Future<void> updateTheme(String theme) async {
    _settings!.theme = theme;
    await _saveSettings();
    notifyListeners();
  }
  
  Future<void> toggleBiometric(bool enabled) async {
    if (enabled) {
      // Check if biometric authentication is available
      final biometricService = BiometricAuthService();
      await biometricService.initialize();
      
      if (!await biometricService.isAvailable()) {
        // Biometric not available, show error and don't enable
        if (kDebugMode) {
          print('Biometric authentication not available: ${biometricService.getStatusMessage()}');
        }
        throw Exception('Biometric authentication is not available on this device');
      }
      
      // Test biometric authentication before enabling
      final authenticated = await biometricService.authenticate(
        reason: 'Please authenticate to enable biometric login',
        biometricOnly: false,
        stickyAuth: true,
      );
      
      if (!authenticated) {
        if (kDebugMode) {
          print('Biometric authentication failed: ${biometricService.lastError}');
        }
        throw Exception('Biometric authentication failed');
      }
    }
    
    _settings!.biometricEnabled = enabled;
    await _saveSettings();
    notifyListeners();
  }
  
  Future<void> toggleNotifications(bool enabled) async {
    _settings!.notificationsEnabled = enabled;
    await _saveSettings();
    notifyListeners();
  }
  
  Future<void> toggleSMSParsing(bool enabled) async {
    _settings!.smsParsingEnabled = enabled;
    await _saveSettings();
    notifyListeners();
  }
  
  Future<void> toggleCloudSync(bool enabled) async {
    _settings!.cloudSyncEnabled = enabled;
    await _saveSettings();
    notifyListeners();
  }
  
  Future<void> updateBudgetAlertThreshold(double threshold) async {
    _settings!.budgetAlertThreshold = threshold;
    await _saveSettings();
    notifyListeners();
  }
  
  Future<void> toggleMotivationalQuotes(bool enabled) async {
    _settings!.showMotivationalQuotes = enabled;
    await _saveSettings();
    notifyListeners();
  }
  
  // Category Notifications
  Future<void> toggleCategoryNotification(String category, bool enabled) async {
    _settings!.categoryNotifications[category] = enabled;
    await _saveSettings();
    notifyListeners();
  }
  
  bool getCategoryNotificationEnabled(String category) {
    return _settings?.categoryNotifications[category] ?? true;
  }
  
  // Dispose
  @override
  void dispose() {
    _box?.close();
    super.dispose();
  }
}

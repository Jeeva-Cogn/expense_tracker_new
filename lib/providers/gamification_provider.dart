import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GamificationProvider extends ChangeNotifier {
  
  int _currentXP = 0;
  int _currentLevel = 1;
  List<String> _unlockedAchievements = [];
  Map<String, int> _streaks = {};
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  int get currentXP => _currentXP;
  int get currentLevel => _currentLevel;
  List<String> get unlockedAchievements => _unlockedAchievements;
  Map<String, int> get streaks => _streaks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Simple implementations for now
  int get xpForNextLevel => _currentLevel * 100; // Simple formula
  int get xpInCurrentLevel => _currentXP % 100; // Simple calculation
  double get levelProgress => xpInCurrentLevel / 100.0; // Simple progress

  // Initialize gamification data
  Future<void> initialize() async {
    try {
      _setLoading(true);
      _clearError();
      
      final prefs = await SharedPreferences.getInstance();
      _currentXP = prefs.getInt('current_xp') ?? 0;
      _currentLevel = prefs.getInt('current_level') ?? 1;
      _unlockedAchievements = prefs.getStringList('achievements') ?? [];
      
      // Load streaks
      final Map<String, Object?> streakData = {};
      for (String key in prefs.getKeys()) {
        if (key.startsWith('streak_')) {
          final streakType = key.substring(7);
          streakData[streakType] = prefs.getInt(key) ?? 0;
        }
      }
      _streaks = Map<String, int>.from(streakData);
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to initialize gamification: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Award XP for actions
  Future<void> awardXP(String action, {Map<String, dynamic>? context}) async {
    try {
      _setLoading(true);
      _clearError();
      
      // Simple XP calculation
      int xpGained = _calculateSimpleXP(action);
      _currentXP += xpGained;
      
      // Check for level up
      final newLevel = (_currentXP / 100).floor() + 1;
      if (newLevel > _currentLevel) {
        _currentLevel = newLevel;
        _checkForLevelAchievements();
      }
      
      await _saveProgress();
      notifyListeners();
    } catch (e) {
      _setError('Failed to award XP: $e');
    } finally {
      _setLoading(false);
    }
  }

  int _calculateSimpleXP(String action) {
    switch (action) {
      case 'add_expense': return 10;
      case 'create_budget': return 20;
      case 'daily_login': return 5;
      case 'weekly_review': return 15;
      default: return 5;
    }
  }

  void _checkForLevelAchievements() {
    if (_currentLevel >= 5 && !_unlockedAchievements.contains('Expense Tracker')) {
      _unlockedAchievements.add('Expense Tracker');
    }
    if (_currentLevel >= 10 && !_unlockedAchievements.contains('Budget Master')) {
      _unlockedAchievements.add('Budget Master');
    }
  }

  Future<void> updateStreak(String streakType) async {
    try {
      _streaks[streakType] = (_streaks[streakType] ?? 0) + 1;
      await _saveProgress();
      notifyListeners();
    } catch (e) {
      _setError('Failed to update streak: $e');
    }
  }

  Future<void> resetStreak(String streakType) async {
    try {
      _streaks[streakType] = 0;
      await _saveProgress();
      notifyListeners();
    } catch (e) {
      _setError('Failed to reset streak: $e');
    }
  }

  List<Map<String, dynamic>> getAvailableAchievements() {
    return [
      {
        'title': 'First Expense',
        'description': 'Add your first expense',
        'unlocked': _unlockedAchievements.contains('First Expense'),
      },
      {
        'title': 'Expense Tracker',
        'description': 'Reach level 5',
        'unlocked': _unlockedAchievements.contains('Expense Tracker'),
      },
      {
        'title': 'Budget Master',
        'description': 'Reach level 10',
        'unlocked': _unlockedAchievements.contains('Budget Master'),
      },
    ];
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('current_xp', _currentXP);
    await prefs.setInt('current_level', _currentLevel);
    await prefs.setStringList('achievements', _unlockedAchievements);
    
    for (String streakType in _streaks.keys) {
      await prefs.setInt('streak_$streakType', _streaks[streakType]!);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _setError(String error) {
    _errorMessage = error;
    debugPrint('Gamification Error: $error');
  }
}
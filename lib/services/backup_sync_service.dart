import 'dart:io';
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/budget.dart';
import '../models/goal.dart';
import '../models/wallet.dart';
import '../models/user_settings.dart';
import '../models/bill_reminder.dart';

/// Service for backing up and syncing expense data
class BackupSyncService {
  static const String _backupBoxName = 'backup_metadata';
  static final _dateFormat = DateFormat('yyyy-MM-dd_HH-mm-ss');
  
  /// Create a complete backup of all user data
  static Future<File> createFullBackup({String? customName}) async {
    try {
      final timestamp = DateTime.now();
      final fileName = customName ?? 'expense_tracker_backup_${_dateFormat.format(timestamp)}.json';
      
      // Get all data from Hive boxes
      final expenseBox = await Hive.openBox<Expense>('expenses');
      final budgetBox = await Hive.openBox<Budget>('budgets');
      final goalBox = await Hive.openBox<FinancialGoal>('goals');
      final walletBox = await Hive.openBox<Wallet>('wallets');
      final settingsBox = await Hive.openBox<UserSettings>('user_settings');
      final billReminderBox = await Hive.openBox<BillReminder>('bill_reminders');
      
      // Create backup data structure
      final backupData = {
        'metadata': {
          'version': '1.0',
          'created_at': timestamp.toIso8601String(),
          'app_version': '1.0.0',
          'total_expenses': expenseBox.length,
          'total_budgets': budgetBox.length,
          'total_goals': goalBox.length,
          'total_wallets': walletBox.length,
          'total_reminders': billReminderBox.length,
        },
        'expenses': expenseBox.values.map((e) => {
          'id': e.id,
          'title': e.title,
          'amount': e.amount,
          'category': e.category,
          'date': e.date.toIso8601String(),
          'note': e.note,
          'type': e.type.toString(),
        }).toList(),
        'budgets': budgetBox.values.map((b) => {
          'id': b.id,
          'name': b.name,
          'limit': b.limit,
          'spent': b.spent,
          'category': b.category,
        }).toList(),
        'goals': goalBox.values.map((g) => {
          'id': g.id,
          'name': g.name,
          'targetAmount': g.targetAmount,
          'currentAmount': g.currentAmount,
        }).toList(),
        'wallets': walletBox.values.map((w) => {
          'id': w.id,
          'name': w.name,
          'balance': w.balance,
          'currency': w.currency,
        }).toList(),
        'settings': settingsBox.isNotEmpty ? {
          'currency': settingsBox.values.first.currency,
          'notificationsEnabled': settingsBox.values.first.notificationsEnabled,
          'favoriteCategories': settingsBox.values.first.favoriteCategories,
        } : null,
        'bill_reminders': billReminderBox.values.map((br) => {
          'id': br.id,
          'name': br.name,
          'amount': br.amount,
          'dueDate': br.dueDate.toIso8601String(),
        }).toList(),
      };
      
      // Save to temporary directory
      final tempDir = await getTemporaryDirectory();
      final backupFile = File('${tempDir.path}/$fileName');
      
      // Write JSON data with pretty formatting
      final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);
      await backupFile.writeAsString(jsonString);
      
      // Save backup metadata
      await _saveBackupMetadata(fileName, timestamp, backupFile.lengthSync());
      
      return backupFile;
      
    } catch (e) {
      print('Error creating backup: $e');
      throw Exception('Failed to create backup: ${e.toString()}');
    }
  }
  
  /// Share backup file
  static Future<void> shareBackup({String? customName}) async {
    try {
      final backupFile = await createFullBackup(customName: customName);
      
      await Share.shareXFiles(
        [XFile(backupFile.path)],
        text: 'Expense Tracker Backup - ${_dateFormat.format(DateTime.now())}',
        subject: 'Expense Tracker Data Backup',
      );
      
    } catch (e) {
      print('Error sharing backup: $e');
      throw Exception('Failed to share backup: ${e.toString()}');
    }
  }
  
  /// Restore data from backup file
  static Future<Map<String, dynamic>> restoreFromBackup() async {
    try {
      // Pick backup file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'Select Expense Tracker Backup File',
      );
      
      if (result == null || result.files.isEmpty) {
        throw Exception('No backup file selected');
      }
      
      final file = File(result.files.first.path!);
      if (!await file.exists()) {
        throw Exception('Selected backup file does not exist');
      }
      
      // Read and parse backup data
      final jsonString = await file.readAsString();
      final backupData = json.decode(jsonString) as Map<String, dynamic>;
      
      // Validate backup format
      if (!backupData.containsKey('metadata') || !backupData.containsKey('expenses')) {
        throw Exception('Invalid backup file format');
      }
      
      final metadata = backupData['metadata'] as Map<String, dynamic>;
      
      // Confirm restoration with user (in actual implementation, show dialog)
      print('Backup Info:');
      print('Created: ${metadata['created_at']}');
      print('Expenses: ${metadata['total_expenses']}');
      print('Budgets: ${metadata['total_budgets']}');
      print('Goals: ${metadata['total_goals']}');
      
      // Clear existing data (with confirmation in real app)
      await _clearAllData();
      
      // Restore data
      final restorationResults = await _restoreAllData(backupData);
      
      // Save restoration metadata
      await _saveRestorationMetadata(metadata['created_at'], restorationResults);
      
      return {
        'success': true,
        'metadata': metadata,
        'restored_counts': restorationResults,
        'message': 'Data successfully restored from backup',
      };
      
    } catch (e) {
      print('Error restoring backup: $e');
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Failed to restore from backup',
      };
    }
  }
  
  /// Export data for external sync (Google Drive, Dropbox etc.)
  static Future<void> exportForSync() async {
    try {
      final backupFile = await createFullBackup(
        customName: 'sync_export_${_dateFormat.format(DateTime.now())}.json'
      );
      
      // Create a simplified sync file for cloud storage
      final syncData = await _createSyncData();
      final syncFile = File('${backupFile.parent.path}/sync_data.json');
      await syncFile.writeAsString(json.encode(syncData));
      
      await Share.shareXFiles(
        [XFile(backupFile.path), XFile(syncFile.path)],
        text: 'Expense Tracker Sync Files',
        subject: 'Export for Cloud Sync',
      );
      
    } catch (e) {
      print('Error exporting for sync: $e');
      throw Exception('Failed to export for sync: ${e.toString()}');
    }
  }
  
  /// Get backup history and statistics
  static Future<List<Map<String, dynamic>>> getBackupHistory() async {
    try {
      final box = await Hive.openBox(_backupBoxName);
      final backups = <Map<String, dynamic>>[];
      
      for (var key in box.keys) {
        final metadata = box.get(key) as Map<dynamic, dynamic>?;
        if (metadata != null) {
          backups.add({
            'id': key,
            'fileName': metadata['fileName'],
            'createdAt': DateTime.parse(metadata['createdAt']),
            'fileSize': metadata['fileSize'],
            'formattedSize': _formatFileSize(metadata['fileSize']),
          });
        }
      }
      
      // Sort by creation date (newest first)
      backups.sort((a, b) => (b['createdAt'] as DateTime).compareTo(a['createdAt'] as DateTime));
      
      return backups;
      
    } catch (e) {
      print('Error getting backup history: $e');
      return [];
    }
  }
  
  /// Clear old backups (keep only recent ones)
  static Future<void> cleanupOldBackups({int keepCount = 5}) async {
    try {
      final box = await Hive.openBox(_backupBoxName);
      final keys = box.keys.toList();
      
      if (keys.length <= keepCount) return;
      
      // Sort by creation date and remove oldest
      final keysWithDates = keys.map((key) {
        final metadata = box.get(key) as Map<dynamic, dynamic>?;
        return {
          'key': key,
          'date': metadata != null ? DateTime.parse(metadata['createdAt']) : DateTime.now(),
        };
      }).toList();
      
      keysWithDates.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
      
      // Remove old entries
      for (int i = keepCount; i < keysWithDates.length; i++) {
        await box.delete(keysWithDates[i]['key']);
      }
      
    } catch (e) {
      print('Error cleaning up old backups: $e');
    }
  }
  
  // Private helper methods
  
  static Future<void> _saveBackupMetadata(String fileName, DateTime createdAt, int fileSize) async {
    try {
      final box = await Hive.openBox(_backupBoxName);
      final key = 'backup_${createdAt.millisecondsSinceEpoch}';
      
      await box.put(key, {
        'fileName': fileName,
        'createdAt': createdAt.toIso8601String(),
        'fileSize': fileSize,
        'type': 'full_backup',
      });
    } catch (e) {
      print('Error saving backup metadata: $e');
    }
  }
  
  static Future<void> _saveRestorationMetadata(String backupDate, Map<String, int> restoredCounts) async {
    try {
      final box = await Hive.openBox(_backupBoxName);
      final key = 'restoration_${DateTime.now().millisecondsSinceEpoch}';
      
      await box.put(key, {
        'restoredAt': DateTime.now().toIso8601String(),
        'backupDate': backupDate,
        'restoredCounts': restoredCounts,
        'type': 'restoration',
      });
    } catch (e) {
      print('Error saving restoration metadata: $e');
    }
  }
  
  static Future<void> _clearAllData() async {
    try {
      // Clear all Hive boxes
      final expenseBox = await Hive.openBox<Expense>('expenses');
      final budgetBox = await Hive.openBox<Budget>('budgets');
      final goalBox = await Hive.openBox<FinancialGoal>('goals');
      final walletBox = await Hive.openBox<Wallet>('wallets');
      final settingsBox = await Hive.openBox<UserSettings>('user_settings');
      final billReminderBox = await Hive.openBox<BillReminder>('bill_reminders');
      
      await expenseBox.clear();
      await budgetBox.clear();
      await goalBox.clear();
      await walletBox.clear();
      await settingsBox.clear();
      await billReminderBox.clear();
      
    } catch (e) {
      print('Error clearing data: $e');
      throw Exception('Failed to clear existing data');
    }
  }
  
  static Future<Map<String, int>> _restoreAllData(Map<String, dynamic> backupData) async {
    final results = <String, int>{};
    
    try {
      // Restore expenses
      final expenseBox = await Hive.openBox<Expense>('expenses');
      final expensesData = backupData['expenses'] as List<dynamic>? ?? [];
      for (var expenseJson in expensesData) {
        final expenseData = expenseJson as Map<String, dynamic>;
        final expense = Expense(
          id: expenseData['id'],
          title: expenseData['title'],
          amount: expenseData['amount']?.toDouble() ?? 0.0,
          category: expenseData['category'] ?? 'Other',
          date: DateTime.parse(expenseData['date']),
          note: expenseData['note'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await expenseBox.add(expense);
      }
      results['expenses'] = expensesData.length;
      
      // Restore budgets  
      final budgetBox = await Hive.openBox<Budget>('budgets');
      final budgetsData = backupData['budgets'] as List<dynamic>? ?? [];
      for (var budgetJson in budgetsData) {
        final budgetData = budgetJson as Map<String, dynamic>;
        final budget = Budget(
          id: budgetData['id'],
          name: budgetData['name'],
          limit: budgetData['limit']?.toDouble() ?? 0.0,
          spent: budgetData['spent']?.toDouble() ?? 0.0,
          category: budgetData['category'] ?? 'General',
          period: BudgetPeriod.monthly,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 30)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await budgetBox.add(budget);
      }
      results['budgets'] = budgetsData.length;
      
      // Restore goals
      final goalBox = await Hive.openBox<FinancialGoal>('goals');
      final goalsData = backupData['goals'] as List<dynamic>? ?? [];
      for (var goalJson in goalsData) {
        final goalData = goalJson as Map<String, dynamic>;
        final goal = FinancialGoal(
          id: goalData['id'],
          name: goalData['name'], 
          description: 'Restored goal',
          type: GoalType.savings,
          targetAmount: goalData['targetAmount']?.toDouble() ?? 0.0,
          currentAmount: goalData['currentAmount']?.toDouble() ?? 0.0,
          targetDate: DateTime.now().add(Duration(days: 365)),
          startDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await goalBox.add(goal);
      }
      results['goals'] = goalsData.length;
      
      // Restore wallets
      final walletBox = await Hive.openBox<Wallet>('wallets');
      final walletsData = backupData['wallets'] as List<dynamic>? ?? [];
      for (var walletJson in walletsData) {
        final wallet = Wallet.fromJson(walletJson as Map<String, dynamic>);
        await walletBox.add(wallet);
      }
      results['wallets'] = walletsData.length;
      
      // Restore settings
      final settingsBox = await Hive.openBox<UserSettings>('user_settings');
      final settingsData = backupData['settings'] as Map<String, dynamic>?;
      if (settingsData != null) {
        final settings = UserSettings.fromJson(settingsData);
        await settingsBox.put('user_settings', settings);
        results['settings'] = 1;
      } else {
        results['settings'] = 0;
      }
      
      // Restore bill reminders
      final billReminderBox = await Hive.openBox<BillReminder>('bill_reminders');
      final remindersData = backupData['bill_reminders'] as List<dynamic>? ?? [];
      for (var reminderJson in remindersData) {
        final reminder = BillReminder.fromJson(reminderJson as Map<String, dynamic>);
        await billReminderBox.add(reminder);
      }
      results['bill_reminders'] = remindersData.length;
      
      return results;
      
    } catch (e) {
      print('Error restoring data: $e');
      throw Exception('Failed to restore data: ${e.toString()}');
    }
  }
  
  static Future<Map<String, dynamic>> _createSyncData() async {
    try {
      final expenseBox = await Hive.openBox<Expense>('expenses');
      final settingsBox = await Hive.openBox<UserSettings>('user_settings');
      
      // Create lightweight sync data with only essential information
      return {
        'sync_version': '1.0',
        'last_updated': DateTime.now().toIso8601String(),
        'device_id': 'flutter_device', // In real app, use unique device ID
        'summary': {
          'total_expenses': expenseBox.length,
          'total_amount': expenseBox.values.fold<double>(0, (sum, expense) => sum + expense.amount),
          'categories': expenseBox.values.map((e) => e.category).toSet().toList(),
          'date_range': expenseBox.isNotEmpty ? {
            'start': expenseBox.values.map((e) => e.date).reduce((a, b) => a.isBefore(b) ? a : b).toIso8601String(),
            'end': expenseBox.values.map((e) => e.date).reduce((a, b) => a.isAfter(b) ? a : b).toIso8601String(),
          } : null,
        },
        'checksum': _calculateDataChecksum(),
      };
    } catch (e) {
      print('Error creating sync data: $e');
      return {'error': e.toString()};
    }
  }
  
  static String _calculateDataChecksum() {
    // Simple checksum calculation (in real app, use proper hashing)
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return timestamp.toRadixString(16);
  }
  
  static String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

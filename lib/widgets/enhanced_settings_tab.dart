import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';
import '../models/user_settings.dart';

class EnhancedSettingsTab extends StatefulWidget {
  const EnhancedSettingsTab({super.key});

  @override
  State<EnhancedSettingsTab> createState() => _EnhancedSettingsTabState();
}

class _EnhancedSettingsTabState extends State<EnhancedSettingsTab>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  final _monthlyBudgetController = TextEditingController();
  final _dailyBudgetController = TextEditingController();
  final _categoryController = TextEditingController();
  
  bool _showMonthlyBudget = false;
  bool _showDailyBudget = false;
  
  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    
    _fadeController.forward();
    _scaleController.forward();
  }
  
  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _monthlyBudgetController.dispose();
    _dailyBudgetController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsService>(
      builder: (context, settingsService, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            title: const Text(
              'Settings',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
          body: AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) => FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Profile Section
                    _buildProfileSection(settingsService),
                    const SizedBox(height: 24),
                    
                    // Budget Settings
                    _buildBudgetSection(settingsService),
                    const SizedBox(height: 24),
                    
                    // Categories Section
                    _buildCategoriesSection(settingsService),
                    const SizedBox(height: 24),
                    
                    // Notification Preferences
                    _buildNotificationSection(settingsService),
                    const SizedBox(height: 24),
                    
                    // App Preferences
                    _buildAppPreferencesSection(settingsService),
                    const SizedBox(height: 24),
                    
                    // Advanced Settings
                    _buildAdvancedSection(settingsService),
                    const SizedBox(height: 100), // Bottom padding for FAB
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildProfileSection(SettingsService settingsService) {
    return _buildSettingsCard(
      title: 'Profile',
      icon: Icons.person_rounded,
      color: Colors.blue,
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue.withOpacity(0.1),
            child: const Icon(Icons.person, color: Colors.blue),
          ),
          title: Text(
            settingsService.settings.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(settingsService.settings.email ?? 'No email set'),
          trailing: IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => _showEditProfileDialog(settingsService),
          ),
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.currency_rupee_rounded),
          title: const Text('Currency'),
          subtitle: Text(settingsService.settings.currency),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => _showCurrencyPicker(settingsService),
        ),
      ],
    );
  }
  
  Widget _buildBudgetSection(SettingsService settingsService) {
    return _buildSettingsCard(
      title: 'Budget Settings',
      icon: Icons.account_balance_wallet_rounded,
      color: Colors.green,
      children: [
        // Monthly Budget
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.calendar_month_rounded, color: Colors.green),
          ),
          title: const Text('Monthly Budget'),
          subtitle: Text(
            settingsService.monthlyBudget != null
                ? '${settingsService.settings.currency}${settingsService.monthlyBudget!.toStringAsFixed(0)}'
                : 'Not set',
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  _showMonthlyBudget ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _showMonthlyBudget = !_showMonthlyBudget;
                  });
                },
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
          onTap: () => _showBudgetDialog(
            'Monthly Budget',
            settingsService.monthlyBudget,
            (value) => settingsService.setMonthlyBudget(value),
          ),
        ),
        const Divider(height: 1),
        
        // Daily Budget
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.today_rounded, color: Colors.orange),
          ),
          title: const Text('Daily Budget'),
          subtitle: Text(
            settingsService.dailyBudget != null
                ? '${settingsService.settings.currency}${settingsService.dailyBudget!.toStringAsFixed(0)}'
                : 'Not set',
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  _showDailyBudget ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _showDailyBudget = !_showDailyBudget;
                  });
                },
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
          onTap: () => _showBudgetDialog(
            'Daily Budget',
            settingsService.dailyBudget,
            (value) => settingsService.setDailyBudget(value),
          ),
        ),
      ],
    );
  }
  
  Widget _buildCategoriesSection(SettingsService settingsService) {
    return _buildSettingsCard(
      title: 'Categories',
      icon: Icons.category_rounded,
      color: Colors.purple,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Manage expense categories',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => _showAddCategoryDialog(settingsService),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: settingsService.categories.map((category) {
                  return Chip(
                    label: Text(category),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => settingsService.removeCategory(category),
                    backgroundColor: Colors.purple.withOpacity(0.1),
                    deleteIconColor: Colors.purple,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildNotificationSection(SettingsService settingsService) {
    return _buildSettingsCard(
      title: 'Notification Preferences',
      icon: Icons.notifications_rounded,
      color: Colors.amber,
      children: [
        SwitchListTile(
          secondary: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.notifications_active, color: Colors.amber),
          ),
          title: const Text('Smart Notifications'),
          subtitle: const Text('Budget alerts and reminders'),
          value: settingsService.settings.notificationsEnabled,
          onChanged: (value) => settingsService.toggleNotifications(value),
        ),
        const Divider(height: 1),
        SwitchListTile(
          secondary: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.warning_rounded, color: Colors.red),
          ),
          title: const Text('Budget Alerts'),
          subtitle: Text(
            'Alert at ${(settingsService.settings.budgetAlertThreshold * 100).toInt()}% of budget',
          ),
          value: settingsService.settings.budgetAlertThreshold > 0,
          onChanged: (value) => settingsService.updateBudgetAlertThreshold(
            value ? 0.8 : 0.0,
          ),
        ),
        if (settingsService.settings.budgetAlertThreshold > 0) ...[
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alert Threshold: ${(settingsService.settings.budgetAlertThreshold * 100).toInt()}%',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Slider(
                  value: settingsService.settings.budgetAlertThreshold,
                  min: 0.5,
                  max: 1.0,
                  divisions: 5,
                  label: '${(settingsService.settings.budgetAlertThreshold * 100).toInt()}%',
                  onChanged: (value) =>
                      settingsService.updateBudgetAlertThreshold(value),
                ),
              ],
            ),
          ),
        ],
        const Divider(height: 1),
        
        // Category-specific notifications
        ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.tune_rounded, color: Colors.indigo),
          ),
          title: const Text('Category Notifications'),
          subtitle: const Text('Customize notifications per category'),
          children: settingsService.categories.map((category) {
            return SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 32),
              title: Text(category),
              value: settingsService.getCategoryNotificationEnabled(category),
              onChanged: (value) =>
                  settingsService.toggleCategoryNotification(category, value),
            );
          }).toList(),
        ),
      ],
    );
  }
  
  Widget _buildAppPreferencesSection(SettingsService settingsService) {
    return _buildSettingsCard(
      title: 'App Preferences',
      icon: Icons.tune_rounded,
      color: Colors.indigo,
      children: [
        SwitchListTile(
          secondary: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.pink.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.sms_rounded, color: Colors.pink),
          ),
          title: const Text('SMS Auto-Detection'),
          subtitle: const Text('Automatically detect bank transaction SMS'),
          value: settingsService.settings.smsParsingEnabled,
          onChanged: (value) => settingsService.toggleSMSParsing(value),
        ),
        const Divider(height: 1),
        SwitchListTile(
          secondary: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.format_quote_rounded, color: Colors.teal),
          ),
          title: const Text('Motivational Quotes'),
          subtitle: const Text('Show daily motivational messages'),
          value: settingsService.settings.showMotivationalQuotes,
          onChanged: (value) => settingsService.toggleMotivationalQuotes(value),
        ),
        const Divider(height: 1),
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.deepOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.palette_rounded, color: Colors.deepOrange),
          ),
          title: const Text('Theme'),
          subtitle: Text(_getThemeDisplayName(settingsService.settings.theme)),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => _showThemePicker(settingsService),
        ),
        const Divider(height: 1),
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.cyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.language_rounded, color: Colors.cyan),
          ),
          title: const Text('Language'),
          subtitle: Text(settingsService.settings.languageDisplayName),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => _showLanguagePicker(settingsService),
        ),
      ],
    );
  }
  
  Widget _buildAdvancedSection(SettingsService settingsService) {
    return _buildSettingsCard(
      title: 'Advanced',
      icon: Icons.settings_applications_rounded,
      color: Colors.grey,
      children: [
        SwitchListTile(
          secondary: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.fingerprint_rounded, color: Colors.blue),
          ),
          title: const Text('Biometric Lock'),
          subtitle: const Text('Use fingerprint or face unlock'),
          value: settingsService.settings.biometricEnabled,
          onChanged: (value) => settingsService.toggleBiometric(value),
        ),
        const Divider(height: 1),
        SwitchListTile(
          secondary: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.cloud_sync_rounded, color: Colors.green),
          ),
          title: const Text('Cloud Sync'),
          subtitle: const Text('Sync data across devices'),
          value: settingsService.settings.cloudSyncEnabled,
          onChanged: (value) => settingsService.toggleCloudSync(value),
        ),
        const Divider(height: 1),
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.backup_rounded, color: Colors.orange),
          ),
          title: const Text('Backup & Restore'),
          subtitle: Text(
            settingsService.settings.lastBackup != null
                ? 'Last backup: ${_formatDate(settingsService.settings.lastBackup!)}'
                : 'No backup yet',
          ),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => _showBackupOptions(settingsService),
        ),
      ],
    );
  }
  
  Widget _buildSettingsCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).colorScheme.surface,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
  
  // Dialog Methods
  void _showEditProfileDialog(SettingsService settingsService) {
    final nameController = TextEditingController(text: settingsService.settings.name);
    final emailController = TextEditingController(text: settingsService.settings.email ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email (Optional)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              settingsService.updateUserName(nameController.text);
              settingsService.updateEmail(
                emailController.text.isEmpty ? null : emailController.text,
              );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  
  void _showBudgetDialog(String title, double? currentValue, Function(double?) onSave) {
    final controller = TextEditingController(
      text: currentValue?.toStringAsFixed(0) ?? '',
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set $title'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: title,
            prefixText: '₹ ',
            border: const OutlineInputBorder(),
            helperText: 'Leave empty to remove budget',
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onSave(null);
              Navigator.pop(context);
            },
            child: const Text('Remove'),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              onSave(value);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  
  void _showAddCategoryDialog(SettingsService settingsService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Category'),
        content: TextField(
          controller: _categoryController,
          decoration: const InputDecoration(
            labelText: 'Category Name',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () {
              _categoryController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              settingsService.addCategory(_categoryController.text);
              _categoryController.clear();
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
  
  void _showCurrencyPicker(SettingsService settingsService) {
    final currencies = ['₹', '\$', '€', '£', '¥', '₩', '₽'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: currencies.map((currency) {
            return RadioListTile<String>(
              title: Text(currency),
              value: currency,
              groupValue: settingsService.settings.currency,
              onChanged: (value) {
                if (value != null) {
                  settingsService.updateCurrency(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }
  
  void _showThemePicker(SettingsService settingsService) {
    final themes = [
      ('system', 'System Default'),
      ('light', 'Light'),
      ('dark', 'Dark'),
    ];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: themes.map((theme) {
            return RadioListTile<String>(
              title: Text(theme.$2),
              value: theme.$1,
              groupValue: settingsService.settings.theme,
              onChanged: (value) {
                if (value != null) {
                  settingsService.updateTheme(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }
  
  void _showLanguagePicker(SettingsService settingsService) {
    final languages = [
      ('en', 'English'),
      ('hi', 'हिंदी'),
      ('ta', 'தமிழ்'),
    ];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((language) {
            return RadioListTile<String>(
              title: Text(language.$2),
              value: language.$1,
              groupValue: settingsService.settings.language,
              onChanged: (value) {
                if (value != null) {
                  settingsService.updateLanguage(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }
  
  void _showBackupOptions(SettingsService settingsService) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Backup & Restore',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.backup_rounded),
              title: const Text('Create Backup'),
              subtitle: const Text('Export your data'),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar('Backup created successfully!');
              },
            ),
            ListTile(
              leading: const Icon(Icons.restore_rounded),
              title: const Text('Restore Backup'),
              subtitle: const Text('Import your data'),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar('Select backup file to restore');
              },
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper Methods
  String _getThemeDisplayName(String theme) {
    switch (theme) {
      case 'light':
        return 'Light';
      case 'dark':
        return 'Dark';
      case 'system':
      default:
        return 'System Default';
    }
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

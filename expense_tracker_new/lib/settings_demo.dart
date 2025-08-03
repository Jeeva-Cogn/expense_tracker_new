import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/user_settings.dart';
import 'services/settings_service.dart';
import 'widgets/enhanced_settings_tab.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(UserSettingsAdapter());
  
  // Initialize SettingsService
  final settingsService = SettingsService();
  await settingsService.initialize();
  
  runApp(SettingsDemoApp(settingsService: settingsService));
}

class SettingsDemoApp extends StatelessWidget {
  final SettingsService settingsService;
  
  const SettingsDemoApp({super.key, required this.settingsService});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SettingsService>(
      create: (context) => settingsService,
      child: Consumer<SettingsService>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'Settings Demo - Expense Tracker',
            debugShowCheckedModeBanner: false,
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            themeMode: _getThemeMode(settings.settings.theme),
            home: const SettingsDemoHome(),
          );
        },
      ),
    );
  }
  
  ThemeMode _getThemeMode(String theme) {
    switch (theme) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.indigo,
        brightness: Brightness.light,
      ),
      fontFamily: 'Roboto',
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 4,
        centerTitle: true,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.indigo,
        brightness: Brightness.dark,
      ),
      fontFamily: 'Roboto',
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 4,
        centerTitle: true,
      ),
    );
  }
}

class SettingsDemoHome extends StatelessWidget {
  const SettingsDemoHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          '⚙️ Settings Demo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          Consumer<SettingsService>(
            builder: (context, settings, child) {
              return IconButton(
                icon: Icon(
                  settings.settings.theme == 'dark' 
                    ? Icons.light_mode_rounded 
                    : Icons.dark_mode_rounded,
                ),
                onPressed: () {
                  final newTheme = settings.settings.theme == 'dark' ? 'light' : 'dark';
                  settings.updateTheme(newTheme);
                },
                tooltip: 'Toggle Theme',
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Welcome Header
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.settings_rounded,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Consumer<SettingsService>(
                  builder: (context, settings, child) {
                    return Text(
                      'Welcome, ${settings.settings.name}!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                const Text(
                  'Configure your preferences below',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          
          // Features Overview
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '✨ Available Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                const _FeatureItem(
                  icon: Icons.account_balance_wallet_rounded,
                  title: 'Monthly Budget',
                  description: 'Set and manage your monthly spending limit',
                  color: Colors.green,
                ),
                const _FeatureItem(
                  icon: Icons.today_rounded,
                  title: 'Daily Budget', 
                  description: 'Configure daily spending targets',
                  color: Colors.orange,
                ),
                const _FeatureItem(
                  icon: Icons.visibility_rounded,
                  title: 'Amount Privacy',
                  description: 'Hide/show budget amounts with eye icon',
                  color: Colors.blue,
                ),
                const _FeatureItem(
                  icon: Icons.category_rounded,
                  title: 'Categories',
                  description: 'Customize expense categories',
                  color: Colors.purple,
                ),
                const _FeatureItem(
                  icon: Icons.notifications_rounded,
                  title: 'Smart Notifications',
                  description: 'Budget alerts and category-specific notifications',
                  color: Colors.amber,
                ),
                const _FeatureItem(
                  icon: Icons.sms_rounded,
                  title: 'SMS Auto-Detection',
                  description: 'Toggle automatic bank SMS parsing',
                  color: Colors.pink,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Open Settings Button
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EnhancedSettingsTab(),
                  ),
                );
              },
              icon: const Icon(Icons.settings_rounded, size: 24),
              label: const Text(
                'Open Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Consumer<SettingsService>(
        builder: (context, settings, child) {
          return FloatingActionButton.extended(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    settings.settings.showMotivationalQuotes 
                      ? MotivationalQuotes.getTodaysQuote()
                      : 'Settings are working perfectly! 🎉',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.lightbulb_rounded),
            label: const Text('Show Tip'),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          );
        },
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle_rounded,
            color: Colors.green,
            size: 20,
          ),
        ],
      ),
    );
  }
}

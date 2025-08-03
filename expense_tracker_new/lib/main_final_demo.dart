import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/settings_service.dart';
import 'models/user_settings.dart';
import 'widgets/enhanced_settings_tab.dart';
import 'widgets/calm_animations.dart';
import 'widgets/calm_messaging.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(UserSettingsAdapter());
  
  runApp(const ExpenseTrackerFinalApp());
}

class ExpenseTrackerFinalApp extends StatelessWidget {
  const ExpenseTrackerFinalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SettingsService(),
      child: MaterialApp(
        title: 'Expense Tracker - Final Design',
        theme: AppTheme.lightTheme,
        home: const CalmNotificationOverlay(
          child: FinalDemoScreen(),
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class FinalDemoScreen extends StatefulWidget {
  const FinalDemoScreen({super.key});

  @override
  State<FinalDemoScreen> createState() => _FinalDemoScreenState();
}

class _FinalDemoScreenState extends State<FinalDemoScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Show welcome message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 800), () {
        CalmNotificationManager().showCustomMessage(
          "🎨 New Color Palette Applied! Stress-free financial tracking awaits! ✨",
          CalmNotificationType.success,
        );
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _tabController.animateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💎 Premium Design Showcase'),
        backgroundColor: AppColors.cardBackground,
        elevation: 2,
        shadowColor: AppColors.textSecondary.withOpacity(0.1),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildColorPaletteDemo(),
          _buildAnimationsDemo(),
          _buildMessagingDemo(),
          const EnhancedSettingsTab(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          boxShadow: AppColors.cardShadow,
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onTabSelected,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.primaryAccent,
          unselectedItemColor: AppColors.textSecondary,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.palette_rounded),
              label: 'Colors',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.animation_rounded),
              label: 'Animations',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.message_rounded),
              label: 'Messages',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPaletteDemo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🎨 Recommended Color Palette',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Carefully selected colors that promote calm and positive financial habits.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          _buildColorSection('Primary Colors', [
            ColorDemo('Background', AppColors.background, '#F9FAFB'),
            ColorDemo('Primary Accent', AppColors.primaryAccent, '#3B82F6'),
            ColorDemo('Secondary Accent', AppColors.secondaryAccent, '#2563EB'),
            ColorDemo('Card Background', AppColors.cardBackground, '#FFFFFF'),
          ]),
          
          _buildColorSection('Semantic Colors', [
            ColorDemo('Success', AppColors.success, '#10B981'),
            ColorDemo('Warning', AppColors.warning, '#F59E0B'),
            ColorDemo('Danger', AppColors.danger, '#EF4444'),
          ]),
          
          _buildColorSection('Text Colors', [
            ColorDemo('Text Primary', AppColors.textPrimary, '#111827'),
            ColorDemo('Text Secondary', AppColors.textSecondary, '#6B7280'),
          ]),
          
          _buildColorSection('Category Colors', [
            ColorDemo('Food', AppColors.getCategoryColor('food'), 'Warm Amber'),
            ColorDemo('Transport', AppColors.getCategoryColor('transport'), 'Primary Blue'),
            ColorDemo('Shopping', AppColors.getCategoryColor('shopping'), 'Purple'),
            ColorDemo('Bills', AppColors.getCategoryColor('bills'), 'Success Green'),
          ]),
        ],
      ),
    );
  }

  Widget _buildColorSection(String title, List<ColorDemo> colors) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...colors.map((color) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.color,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.textSecondary.withOpacity(0.3),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          color.name,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          color.hex,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimationsDemo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🎬 Smooth Animations',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Watch the beautiful, stress-free animations in action.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Animated Pie Chart',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: AnimatedPieChart(
                      data: {
                        'Food': 4500,
                        'Transport': 1200,
                        'Shopping': 2300,
                        'Bills': 3200,
                        'Others': 1250,
                      },
                      colors: {
                        'Food': AppColors.getCategoryColor('food'),
                        'Transport': AppColors.getCategoryColor('transport'),
                        'Shopping': AppColors.getCategoryColor('shopping'),
                        'Bills': AppColors.getCategoryColor('bills'),
                        'Others': AppColors.getCategoryColor('others'),
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Animated Bar Chart',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250,
                    child: AnimatedBarChart(
                      data: {
                        'Jan': 8500,
                        'Feb': 12000,
                        'Mar': 9800,
                        'Apr': 15200,
                        'May': 11400,
                        'Jun': 13600,
                      },
                      barColor: AppColors.primaryAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Loading Animation',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: AnalysisLoader(
                      message: 'Analyzing your spending with care...',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagingDemo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💬 Calm Messaging System',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Experience encouraging messages that promote positive financial habits.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          _buildMessageButton(
            'Show Success Message',
            'Fantastic! You stayed under budget this month! 🎉',
            CalmNotificationType.success,
            AppColors.success,
          ),
          
          _buildMessageButton(
            'Show Encouragement',
            'You went over budget this time. Let\'s plan better next month! 📈',
            CalmNotificationType.encouragement,
            AppColors.primaryAccent,
          ),
          
          _buildMessageButton(
            'Show Savings Milestone',
            'Every rupee saved is a step toward your dreams! 💰',
            CalmNotificationType.success,
            AppColors.success,
          ),
          
          _buildMessageButton(
            'Show Tracking Well',
            'You\'re tracking well. Keep it up! 🌟',
            CalmNotificationType.info,
            AppColors.secondaryAccent,
          ),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🧘 Design Philosophy',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  _buildPhilosophyPoint('✅ No harsh red alerts'),
                  _buildPhilosophyPoint('✅ Encouraging instead of punishing'),
                  _buildPhilosophyPoint('✅ Celebrates achievements'),
                  _buildPhilosophyPoint('✅ Gentle guidance for overspending'),
                  _buildPhilosophyPoint('✅ Promotes positive financial habits'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageButton(String title, String message, CalmNotificationType type, Color color) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            type == CalmNotificationType.success ? Icons.celebration_rounded :
            type == CalmNotificationType.encouragement ? Icons.favorite_rounded :
            Icons.info_rounded,
            color: color,
          ),
        ),
        title: Text(title),
        subtitle: Text(message, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.play_arrow_rounded),
        onTap: () {
          CalmNotificationManager().showCustomMessage(message, type);
        },
      ),
    );
  }

  Widget _buildPhilosophyPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class ColorDemo {
  final String name;
  final Color color;
  final String hex;

  ColorDemo(this.name, this.color, this.hex);
}

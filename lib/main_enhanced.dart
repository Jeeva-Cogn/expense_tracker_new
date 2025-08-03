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
  
  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SettingsService(),
      child: MaterialApp(
        title: 'Expense Tracker',
        theme: AppTheme.lightTheme,
        home: const CalmNotificationOverlay(
          child: MainScreen(),
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late TabController _tabController;
  late AnimationController _pageAnimationController;

  final List<TabInfo> _tabs = [
    TabInfo(
      icon: Icons.dashboard_rounded,
      label: 'Dashboard',
      color: AppColors.primaryAccent,
    ),
    TabInfo(
      icon: Icons.analytics_rounded,
      label: 'Analytics',
      color: AppColors.success,
    ),
    TabInfo(
      icon: Icons.add_circle_rounded,
      label: 'Add Expense',
      color: AppColors.warning,
    ),
    TabInfo(
      icon: Icons.history_rounded,
      label: 'History',
      color: AppColors.chartColors[4],
    ),
    TabInfo(
      icon: Icons.settings_rounded,
      label: 'Settings',
      color: AppColors.secondaryAccent,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _pageAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Register with notification manager
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Show welcome message
      Future.delayed(const Duration(milliseconds: 500), () {
        CalmNotificationManager().showCustomMessage(
          "Welcome back! Let's track your expenses mindfully 🌟",
          CalmNotificationType.info,
        );
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageAnimationController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _tabController.animateTo(index);
    _pageAnimationController.forward(from: 0);
    
    // Show relevant messages based on tab
    if (index == 0) { // Dashboard
      Future.delayed(const Duration(milliseconds: 800), () {
        CalmNotificationManager().showTrackingWell();
      });
    } else if (index == 4) { // Settings
      Future.delayed(const Duration(milliseconds: 800), () {
        CalmNotificationManager().showCustomMessage(
          "Customize your experience to match your style! ⚙️",
          CalmNotificationType.info,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildDashboardTab(),
          _buildAnalyticsTab(),
          _buildAddExpenseTab(),
          _buildHistoryTab(),
          const EnhancedSettingsTab(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onTabSelected,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: _tabs[_selectedIndex].color,
          unselectedItemColor: Colors.grey.shade600,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
          items: _tabs.map((tab) => BottomNavigationBarItem(
            icon: Icon(tab.icon),
            activeIcon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: tab.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(tab.icon),
            ),
            label: tab.label,
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          _buildWelcomeSection(),
          const SizedBox(height: 24),
          _buildQuickStats(),
          const SizedBox(height: 24),
          _buildExpenseChart(),
          const SizedBox(height: 24),
          _buildRecentTransactions(),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Colors.indigo.shade700,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good ${_getGreeting()}!',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                      Text(
                        'Let\'s check your financial wellness',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'This Month',
            '₹12,450',
            Icons.calendar_month_rounded,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Today',
            '₹320',
            Icons.today_rounded,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Budget Left',
            '₹7,550',
            Icons.savings_rounded,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String amount, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              amount,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Expense Categories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
    );
  }

  Widget _buildRecentTransactions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Transactions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                CalmButton(
                  onPressed: () => _onTabSelected(3),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTransactionItem('Groceries', '₹850', Icons.shopping_cart_rounded, Colors.orange),
            _buildTransactionItem('Uber Ride', '₹120', Icons.directions_car_rounded, Colors.blue),
            _buildTransactionItem('Coffee', '₹150', Icons.local_cafe_rounded, Colors.brown),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(String title, String amount, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Text(
            'Analytics',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Monthly Spending Trend',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildInsightsCard(),
        ],
      ),
    );
  }

  Widget _buildInsightsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Smart Insights',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInsightItem(
              '🎯',
              'You\'re 25% under your monthly budget',
              'Great job managing your expenses!',
            ),
            _buildInsightItem(
              '📈',
              'Food expenses increased by 15%',
              'Consider meal planning to optimize costs',
            ),
            _buildInsightItem(
              '💡',
              'Best spending day: Weekends',
              'You tend to spend more on leisure activities',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(String emoji, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
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
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddExpenseTab() {
    return const Center(
      child: AnalysisLoader(
        message: 'Add Expense feature coming soon...',
      ),
    );
  }

  Widget _buildHistoryTab() {
    return const Center(
      child: AnalysisLoader(
        message: 'History feature coming soon...',
      ),
    );
  }
}

class TabInfo {
  final IconData icon;
  final String label;
  final Color color;

  TabInfo({
    required this.icon,
    required this.label,
    required this.color,
  });
}

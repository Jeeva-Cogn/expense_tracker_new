import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/settings_service.dart';
import 'services/ai_analysis_service.dart';
import 'models/user_settings.dart';
import 'screens/ai_analysis_screen.dart';
import 'widgets/calm_messaging.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(UserSettingsAdapter());
  
  runApp(const AIAnalysisApp());
}

class AIAnalysisApp extends StatelessWidget {
  const AIAnalysisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SettingsService()),
        ChangeNotifierProvider(create: (context) => AIAnalysisService()),
      ],
      child: MaterialApp(
        title: 'AI Transaction Analysis',
        theme: AppTheme.lightTheme,
        home: const CalmNotificationOverlay(
          child: AIAnalysisDemoHome(),
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AIAnalysisDemoHome extends StatefulWidget {
  const AIAnalysisDemoHome({super.key});

  @override
  State<AIAnalysisDemoHome> createState() => _AIAnalysisDemoHomeState();
}

class _AIAnalysisDemoHomeState extends State<AIAnalysisDemoHome> {
  
  @override
  void initState() {
    super.initState();
    
    // Register notification overlay and show welcome
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        CalmNotificationManager().showCustomMessage(
          "🤖 AI Analysis Ready! Experience intelligent expense tracking! ✨",
          CalmNotificationType.info,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🤖 AI Expense Tracker'),
        backgroundColor: AppColors.cardBackground,
        elevation: 2,
        shadowColor: AppColors.textSecondary.withOpacity(0.1),
      ),
      body: const AIAnalysisScreen(),
    );
  }
}

/// Complete AI Analysis Demo that follows the exact user flow:
/// 1. User opens app
/// 2. Taps "Analyze Transactions"  
/// 3. Animated loader appears: "Analyzing your expenses…"
/// 4. SMS scanned and transactions auto-detected
/// 5. Charts animate with updated data
/// 6. Monthly budget progress bar updates (live)
/// 7. AI gives suggestions: "You spent ₹10,000 on Shopping. Try reducing by ₹1,000 next month."
/// 8. User gets notification for unclassified expense: "What was this ₹500 spent on?"

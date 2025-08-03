import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/expense.dart';
import '../models/budget.dart';
import 'analytics_service.dart';

class SmartNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  // Initialize notification service
  static Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
    _initialized = true;
  }

  // Smart expense alerts based on patterns
  static Future<void> checkSmartAlerts(List<Expense> expenses, List<Budget> budgets) async {
    await initialize();

    // Budget alerts
    await _checkBudgetAlerts(budgets);
    
    // Spending pattern alerts
    await _checkSpendingPatternAlerts(expenses);
    
    // Anomaly alerts
    await _checkAnomalyAlerts(expenses);
    
    // Goal achievement alerts
    await _checkGoalAlerts(expenses, budgets);
  }

  // Budget-related alerts
  static Future<void> _checkBudgetAlerts(List<Budget> budgets) async {
    for (final budget in budgets.where((b) => b.isActive && b.alertsEnabled)) {
      if (budget.isOverBudget) {
        await _showNotification(
          id: budget.hashCode,
          title: '🚨 Budget Exceeded!',
          body: 'You\'ve exceeded your ${budget.name} budget by ₹${(budget.spent - budget.limit).toStringAsFixed(0)}',
          priority: NotificationPriority.high,
        );
      } else if (budget.isNearLimit) {
        await _showNotification(
          id: budget.hashCode + 1000,
          title: '⚠️ Budget Alert',
          body: 'You\'ve used ${(budget.percentageUsed * 100).toInt()}% of your ${budget.name} budget',
          priority: NotificationPriority.medium,
        );
      }

      // Daily budget alerts
      if (budget.daysRemaining > 0 && budget.dailyBudget < budget.averageDailySpending) {
        await _showNotification(
          id: budget.hashCode + 2000,
          title: '📊 Daily Budget Alert',
          body: 'Your daily budget for ${budget.name} is ₹${budget.dailyBudget.toStringAsFixed(0)}, but your average is ₹${budget.averageDailySpending.toStringAsFixed(0)}',
          priority: NotificationPriority.medium,
        );
      }
    }
  }

  // Spending pattern alerts
  static Future<void> _checkSpendingPatternAlerts(List<Expense> expenses) async {
    final recentExpenses = expenses.where((e) => 
      e.date.isAfter(DateTime.now().subtract(const Duration(days: 7)))
    ).toList();

    // High spending day alert
    final today = DateTime.now();
    final todayExpenses = recentExpenses.where((e) => 
      e.date.day == today.day && e.date.month == today.month && e.date.year == today.year
    ).toList();

    final todayTotal = todayExpenses.fold(0.0, (sum, e) => sum + e.amount);
    if (todayTotal > 2000) {
      await _showNotification(
        id: 3001,
        title: '💸 High Spending Day',
        body: 'You\'ve spent ₹${todayTotal.toStringAsFixed(0)} today across ${todayExpenses.length} transactions',
        priority: NotificationPriority.medium,
      );
    }

    // Multiple SMS transactions alert
    final smsExpensesToday = todayExpenses.where((e) => e.isFromSMS).length;
    if (smsExpensesToday >= 5) {
      await _showNotification(
        id: 3002,
        title: '📱 Multiple Transactions',
        body: '$smsExpensesToday transactions detected from SMS today. Review for accuracy.',
        priority: NotificationPriority.medium,
      );
    }

    // Weekend spending reminder
    if (today.weekday >= 6) { // Saturday or Sunday
      final weekendTotal = recentExpenses.where((e) => e.date.weekday >= 6).fold(0.0, (sum, e) => sum + e.amount);
      if (weekendTotal > 1500) {
        await _showNotification(
          id: 3003,
          title: '🎉 Weekend Spending',
          body: 'Weekend spending: ₹${weekendTotal.toStringAsFixed(0)}. Consider your weekly budget.',
          priority: NotificationPriority.low,
        );
      }
    }
  }

  // Anomaly detection alerts
  static Future<void> _checkAnomalyAlerts(List<Expense> expenses) async {
    final anomalies = FinancialAnalytics.detectAnomalies(expenses);
    
    for (final anomaly in anomalies.take(3)) { // Limit to top 3 anomalies
      String title = '';
      String body = '';
      NotificationPriority priority = NotificationPriority.medium;

      switch (anomaly.type) {
        case AnomalyType.unusuallyHigh:
          title = '📈 Unusual High Expense';
          body = '₹${anomaly.expense.amount.toStringAsFixed(0)} expense in ${anomaly.expense.category} is unusually high';
          priority = anomaly.severity == AnomalySeverity.high ? NotificationPriority.high : NotificationPriority.medium;
          break;
        case AnomalyType.suspiciousTransaction:
          title = '🔒 Suspicious Transaction';
          body = 'Review transaction: ${anomaly.expense.title} - ₹${anomaly.expense.amount.toStringAsFixed(0)}';
          priority = NotificationPriority.high;
          break;
        case AnomalyType.unusuallyLow:
          title = '📉 Unusual Low Expense';
          body = 'Unexpectedly low spending in ${anomaly.expense.category}';
          priority = NotificationPriority.low;
          break;
        default:
          continue;
      }

      await _showNotification(
        id: 4000 + anomaly.expense.hashCode % 1000,
        title: title,
        body: body,
        priority: priority,
      );
    }
  }

  // Goal achievement alerts
  static Future<void> _checkGoalAlerts(List<Expense> expenses, List<Budget> budgets) async {
    final thisMonth = DateTime.now();
    final monthStart = DateTime(thisMonth.year, thisMonth.month, 1);
    final monthExpenses = expenses.where((e) => e.date.isAfter(monthStart)).toList();
    
    final totalIncome = monthExpenses.where((e) => e.isIncome).fold(0.0, (sum, e) => sum + e.amount);
    final totalExpenses = monthExpenses.where((e) => e.isExpense).fold(0.0, (sum, e) => sum + e.amount);
    final savingsRate = totalIncome > 0 ? (totalIncome - totalExpenses) / totalIncome : 0.0;

    // Savings goal achievements
    if (savingsRate >= 0.2) {
      await _showNotification(
        id: 5001,
        title: '🎯 Savings Goal Achieved!',
        body: 'Excellent! You\'ve saved ${(savingsRate * 100).toInt()}% of your income this month.',
        priority: NotificationPriority.medium,
      );
    } else if (savingsRate >= 0.1) {
      await _showNotification(
        id: 5002,
        title: '💰 Good Savings Progress',
        body: 'You\'re saving ${(savingsRate * 100).toInt()}% this month. Keep it up!',
        priority: NotificationPriority.low,
      );
    }

    // Budget compliance achievements
    final budgetsOnTrack = budgets.where((b) => b.isActive && !b.isOverBudget && b.percentageUsed < 0.8).length;
    if (budgetsOnTrack == budgets.length && budgets.isNotEmpty) {
      await _showNotification(
        id: 5003,
        title: '📊 All Budgets On Track!',
        body: 'Amazing! All your budgets are within limits this period.',
        priority: NotificationPriority.medium,
      );
    }
  }

  // Personalized insights notifications
  static Future<void> sendInsightNotification(String insight, {NotificationPriority priority = NotificationPriority.medium}) async {
    await initialize();
    
    await _showNotification(
      id: DateTime.now().millisecondsSinceEpoch % 10000,
      title: '💡 Financial Insight',
      body: insight,
      priority: priority,
    );
  }

  // SMS expense confirmation notifications
  static Future<void> notifyNewSMSExpense(Expense expense) async {
    await initialize();
    
    await _showNotification(
      id: 6000 + expense.hashCode % 1000,
      title: '📱 New SMS Expense Detected',
      body: '${expense.title} - ₹${expense.amount.toStringAsFixed(0)} in ${expense.category}',
      priority: NotificationPriority.medium,
      actions: [
        const AndroidNotificationAction(
          'confirm',
          'Confirm',
          showsUserInterface: true,
        ),
        const AndroidNotificationAction(
          'edit',
          'Edit',
          showsUserInterface: true,
        ),
      ],
    );
  }

  // Weekly financial summary
  static Future<void> sendWeeklySummary(List<Expense> weeklyExpenses, List<Budget> budgets) async {
    await initialize();
    
    final totalSpent = weeklyExpenses.where((e) => e.isExpense).fold(0.0, (sum, e) => sum + e.amount);
    final totalIncome = weeklyExpenses.where((e) => e.isIncome).fold(0.0, (sum, e) => sum + e.amount);
    final netFlow = totalIncome - totalSpent;
    
    final body = netFlow >= 0 
        ? 'This week: ₹${totalSpent.toStringAsFixed(0)} spent, ₹${netFlow.toStringAsFixed(0)} saved'
        : 'This week: ₹${totalSpent.toStringAsFixed(0)} spent, ₹${netFlow.abs().toStringAsFixed(0)} overspent';

    await _showNotification(
      id: 7001,
      title: '📊 Weekly Financial Summary',
      body: body,
      priority: NotificationPriority.low,
    );
  }

  // Monthly insights notification
  static Future<void> sendMonthlyInsights(FinancialHealthReport report) async {
    await initialize();
    
    final body = 'Health Score: ${report.healthScore.toInt()}/100 (${report.healthGrade})\n'
                 'Savings Rate: ${(report.savingsRate * 100).toInt()}%\n'
                 'Risk Level: ${report.riskLevel}';

    await _showNotification(
      id: 7002,
      title: '📈 Monthly Financial Health',
      body: body,
      priority: NotificationPriority.medium,
    );
  }

  // Helper method to show notifications
  static Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    NotificationPriority priority = NotificationPriority.medium,
    List<AndroidNotificationAction>? actions,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'expense_tracker_channel',
      'Expense Tracker Notifications',
      channelDescription: 'Smart notifications for expense tracking and budget alerts',
      importance: _getImportance(priority),
      priority: _getPriority(priority),
      actions: actions,
      styleInformation: BigTextStyleInformation(body),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details);
  }

  static Importance _getImportance(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.high:
        return Importance.high;
      case NotificationPriority.medium:
        return Importance.defaultImportance;
      case NotificationPriority.low:
        return Importance.low;
    }
  }

  static Priority _getPriority(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.high:
        return Priority.high;
      case NotificationPriority.medium:
        return Priority.defaultPriority;
      case NotificationPriority.low:
        return Priority.low;
    }
  }

  // Schedule recurring notifications
  static Future<void> scheduleRecurringAlerts() async {
    await initialize();

    // Daily spending check at 8 PM
    await _notifications.zonedSchedule(
      8001,
      '💰 Daily Spending Check',
      'How did your spending go today? Review your expenses.',
      _nextInstanceOfTime(20, 0), // 8 PM
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel',
          'Daily Reminders',
          channelDescription: 'Daily spending check reminders',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    // Weekly budget review on Sunday at 10 AM
    await _notifications.zonedSchedule(
      8002,
      '📊 Weekly Budget Review',
      'Time to review your weekly budgets and plan for the week ahead.',
      _nextInstanceOfWeekday(DateTime.sunday, 10, 0),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'weekly_review_channel',
          'Weekly Reviews',
          channelDescription: 'Weekly budget and spending reviews',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  static tz.TZDateTime _nextInstanceOfWeekday(int weekday, int hour, int minute) {
    tz.TZDateTime scheduledDate = _nextInstanceOfTime(hour, minute);
    while (scheduledDate.weekday != weekday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Cancel specific notification
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }
}

enum NotificationPriority {
  low,
  medium,
  high,
}

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_colors.dart';

class CalmMessaging {
  // Friendly tracking messages
  static const List<String> trackingWellMessages = [
    "You're tracking well. Keep it up! 🌟",
    "Great job staying on top of your expenses! 💪",
    "Your spending awareness is impressive! ✨",
    "You're building excellent financial habits! 🎯",
    "Keep up the wonderful tracking! 🌈",
    "Your financial mindfulness is paying off! 💎",
    "You're doing amazing with your budget! 🚀",
    "This level of tracking shows real commitment! 🏆",
    "Your future self will thank you! 💫",
    "Excellent work managing your money! 🌸",
  ];

  // Encouraging overspending messages
  static const List<String> overspendingEncouragement = [
    "You went over budget this time. Let's plan better next month! 📈",
    "Small overspend happens to everyone. You've got this! 💪",
    "Every month is a fresh start. Let's adjust and move forward! 🌱",
    "Your awareness is the first step to improvement! ✨",
    "Let's look at this as valuable learning for next time! 📚",
    "Minor budget adjustments can make a big difference! 🎯",
    "You're still on track for long-term success! 🚀",
    "Consider this practice for better budgeting skills! 🌟",
    "Every financial journey has learning moments! 💎",
    "Let's turn this into motivation for next month! 🔥",
  ];

  // Budget achievement messages
  static const List<String> budgetAchievements = [
    "Fantastic! You stayed under budget this month! 🎉",
    "Well done! Your budgeting skills are improving! 🏆",
    "Amazing discipline staying within limits! 💪",
    "You're a budgeting champion this month! 👑",
    "Excellent financial self-control! Keep it up! ⭐",
    "Your budget awareness is truly impressive! 🌟",
    "This is how financial success is built! 🏗️",
    "You're mastering the art of mindful spending! 🧘",
    "Your commitment to budgeting shows! 💯",
    "Outstanding budget management! 🎯",
  ];

  // Savings milestone messages
  static const List<String> savingsMessages = [
    "Every rupee saved is a step toward your dreams! 💰",
    "Your savings are growing beautifully! 🌱",
    "Small consistent saves lead to big results! 📈",
    "You're building a stronger financial future! 🏦",
    "Your saving habit is becoming second nature! ✨",
    "Watching your savings grow must feel great! 😊",
    "You're proving that consistent saving works! 💪",
    "Your financial discipline is inspiring! 🌟",
    "Each saving milestone is worth celebrating! 🎊",
    "You're turning dreams into achievable goals! 🎯",
  ];

  static String getTrackingMessage() {
    return trackingWellMessages[math.Random().nextInt(trackingWellMessages.length)];
  }

  static String getOverspendingMessage(double amount, String currency) {
    final baseMessage = overspendingEncouragement[
        math.Random().nextInt(overspendingEncouragement.length)];
    
    if (amount > 0) {
      return "You went $currency${amount.toStringAsFixed(0)} over budget. Let's plan better next month! 📈";
    }
    return baseMessage;
  }

  static String getBudgetAchievementMessage() {
    return budgetAchievements[math.Random().nextInt(budgetAchievements.length)];
  }

  static String getSavingsMessage() {
    return savingsMessages[math.Random().nextInt(savingsMessages.length)];
  }
}

class CalmNotification extends StatefulWidget {
  final String message;
  final CalmNotificationType type;
  final VoidCallback? onDismiss;
  final Duration displayDuration;

  const CalmNotification({
    super.key,
    required this.message,
    this.type = CalmNotificationType.info,
    this.onDismiss,
    this.displayDuration = const Duration(seconds: 4),
  });

  @override
  State<CalmNotification> createState() => _CalmNotificationState();
}

class _CalmNotificationState extends State<CalmNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();

    // Auto-dismiss after duration
    Future.delayed(widget.displayDuration, () {
      if (mounted) {
        _dismissNotification();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismissNotification() async {
    await _controller.reverse();
    if (widget.onDismiss != null) {
      widget.onDismiss!();
    }
  }

  Color _getBackgroundColor() {
    switch (widget.type) {
      case CalmNotificationType.success:
        return AppColors.celebrationBg;
      case CalmNotificationType.warning:
        return AppColors.warningBg;
      case CalmNotificationType.encouragement:
        return AppColors.encouragementBg;
      case CalmNotificationType.info:
        return AppColors.infoBg;
    }
  }

  Color _getBorderColor() {
    switch (widget.type) {
      case CalmNotificationType.success:
        return AppColors.celebrationBorder;
      case CalmNotificationType.warning:
        return AppColors.warningBorder;
      case CalmNotificationType.encouragement:
        return AppColors.encouragementBorder;
      case CalmNotificationType.info:
        return AppColors.infoBorder;
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case CalmNotificationType.success:
        return Icons.celebration_rounded;
      case CalmNotificationType.warning:
        return Icons.lightbulb_rounded;
      case CalmNotificationType.encouragement:
        return Icons.favorite_rounded;
      case CalmNotificationType.info:
        return Icons.info_rounded;
    }
  }

  Color _getIconColor() {
    switch (widget.type) {
      case CalmNotificationType.success:
        return AppColors.celebrationIcon;
      case CalmNotificationType.warning:
        return AppColors.warningIcon;
      case CalmNotificationType.encouragement:
        return AppColors.encouragementIcon;
      case CalmNotificationType.info:
        return AppColors.infoIcon;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _getBorderColor(),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _getBorderColor().withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getIconColor().withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIcon(),
                  color: _getIconColor(),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.message,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                    height: 1.4,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _dismissNotification,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.grey.shade500,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum CalmNotificationType {
  info,
  success,
  warning,
  encouragement,
}

// Helper widget for showing calm notifications
class CalmNotificationOverlay extends StatefulWidget {
  final Widget child;

  const CalmNotificationOverlay({
    super.key,
    required this.child,
  });

  @override
  State<CalmNotificationOverlay> createState() => _CalmNotificationOverlayState();
}

class _CalmNotificationOverlayState extends State<CalmNotificationOverlay> {
  final List<Widget> _notifications = [];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 0,
          right: 0,
          child: Column(
            children: _notifications,
          ),
        ),
      ],
    );
  }

  void showCalmNotification({
    required String message,
    CalmNotificationType type = CalmNotificationType.info,
    Duration? displayDuration,
  }) {
    final notification = CalmNotification(
      message: message,
      type: type,
      displayDuration: displayDuration ?? const Duration(seconds: 4),
      onDismiss: () {
        setState(() {
          _notifications.removeAt(0);
        });
      },
    );

    setState(() {
      _notifications.add(notification);
    });

    // Limit to 3 notifications at once
    if (_notifications.length > 3) {
      setState(() {
        _notifications.removeAt(0);
      });
    }
  }
}

// Global notification manager
class CalmNotificationManager {
  static final CalmNotificationManager _instance = CalmNotificationManager._internal();
  factory CalmNotificationManager() => _instance;
  CalmNotificationManager._internal();

  _CalmNotificationOverlayState? _overlayState;

  void registerOverlay(_CalmNotificationOverlayState state) {
    _overlayState = state;
  }

  void showTrackingWell() {
    _overlayState?.showCalmNotification(
      message: CalmMessaging.getTrackingMessage(),
      type: CalmNotificationType.success,
    );
  }

  void showOverspending(double amount, String currency) {
    _overlayState?.showCalmNotification(
      message: CalmMessaging.getOverspendingMessage(amount, currency),
      type: CalmNotificationType.encouragement,
    );
  }

  void showBudgetAchievement() {
    _overlayState?.showCalmNotification(
      message: CalmMessaging.getBudgetAchievementMessage(),
      type: CalmNotificationType.success,
    );
  }

  void showSavingsMilestone() {
    _overlayState?.showCalmNotification(
      message: CalmMessaging.getSavingsMessage(),
      type: CalmNotificationType.success,
    );
  }

  void showCustomMessage(String message, CalmNotificationType type) {
    _overlayState?.showCalmNotification(
      message: message,
      type: type,
    );
  }
}

// Calm snackbar replacement
class CalmSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    CalmNotificationType type = CalmNotificationType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: MediaQuery.of(context).padding.bottom + 16,
        left: 16,
        right: 16,
        child: CalmNotification(
          message: message,
          type: type,
          displayDuration: duration,
          onDismiss: () => entry.remove(),
        ),
      ),
    );

    overlay.insert(entry);
  }
}

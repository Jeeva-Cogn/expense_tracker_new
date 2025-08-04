import 'package:flutter/material.dart';

/// 🎨 Calm Color Palette - Designed for stress-free financial tracking
/// Based on user-recommended colors that promote positive financial habits
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // ===== BACKGROUND COLORS =====
  /// Light and soft base background - promotes calm and focus
  static const Color background = Color(0xFFF9FAFB);
  
  /// Pure white for UI elements like tiles/cards
  static const Color cardBackground = Color(0xFFFFFFFF);

  // ===== PRIMARY COLORS =====
  /// Main brand color for buttons and headings - trustworthy blue
  static const Color primary = Color(0xFF3B82F6);
  static const Color primaryAccent = Color(0xFF3B82F6);
  
  /// Deeper blue for hover/active states - maintains consistency
  static const Color secondary = Color(0xFF2563EB);
  static const Color secondaryAccent = Color(0xFF2563EB);

  // ===== SEMANTIC COLORS =====
  /// Positive indicators - savings, achievements, good news
  /// Gentle green that celebrates without overwhelming
  static const Color success = Color(0xFF10B981);
  
  /// Budget warnings - informative without being alarming
  /// Warm amber that guides rather than scares
  static const Color warning = Color(0xFFF59E0B);
  
  /// Overspend notifications - gentle guidance
  /// Soft red that encourages rather than punishes
  static const Color danger = Color(0xFFEF4444);

  // ===== TEXT COLORS =====
  /// Main text color - readable dark gray (not harsh black)
  static const Color textPrimary = Color(0xFF111827);
  
  /// Labels and secondary text - softer gray for hierarchy
  static const Color textSecondary = Color(0xFF6B7280);

  // ===== BORDER COLORS =====
  /// Border color for dividers and subtle borders
  static const Color border = Color(0xFFE5E7EB);

  // ===== CHART COLORS =====
  /// Expense category colors - balanced and distinguishable
  static const List<Color> chartColors = [
    Color(0xFF3B82F6), // Blue - Transport, Bills
    Color(0xFF10B981), // Green - Savings, Income
    Color(0xFFF59E0B), // Amber - Food, Shopping
    Color(0xFF8B5CF6), // Purple - Entertainment
    Color(0xFFF97316), // Orange - Health, Misc
    Color(0xFFEC4899), // Pink - Personal Care
    Color(0xFF06B6D4), // Cyan - Education
    Color(0xFF84CC16), // Lime - Investments
  ];

  // ===== CATEGORY SPECIFIC COLORS =====
  static const Map<String, Color> categoryColors = {
    'food': Color(0xFFF59E0B),        // Warm amber
    'transport': Color(0xFF3B82F6),   // Primary blue
    'shopping': Color(0xFF8B5CF6),    // Purple
    'bills': Color(0xFF10B981),       // Success green
    'entertainment': Color(0xFFEC4899), // Pink
    'health': Color(0xFFF97316),      // Orange
    'education': Color(0xFF06B6D4),   // Cyan
    'savings': Color(0xFF84CC16),     // Lime
    'others': Color(0xFF6B7280),      // Secondary gray
  };

  // ===== NOTIFICATION COLORS =====
  /// Celebration notifications - achievements and milestones
  static const Color celebrationBg = Color(0xFFF0FDF4); // Very light green
  static const Color celebrationBorder = Color(0xFFBBF7D0); // Light green
  static const Color celebrationIcon = success;

  /// Encouragement notifications - gentle guidance
  static const Color encouragementBg = Color(0xFFF0F9FF); // Very light blue
  static const Color encouragementBorder = Color(0xFFBAE6FD); // Light blue
  static const Color encouragementIcon = primaryAccent;

  /// Warning notifications - budget alerts
  static const Color warningBg = Color(0xFFFFFBEB); // Very light amber
  static const Color warningBorder = Color(0xFFFED7AA); // Light amber
  static const Color warningIcon = warning;

  /// Info notifications - general information
  static const Color infoBg = Color(0xFFF8FAFC); // Very light gray
  static const Color infoBorder = Color(0xFFE2E8F0); // Light gray
  static const Color infoIcon = textSecondary;

  // ===== GRADIENT COMBINATIONS =====
  /// Success gradient for achievements and positive outcomes
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Primary gradient for main actions and highlights
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Warning gradient for gentle alerts
  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ===== HELPER METHODS =====
  
  /// Get color for expense category with fallback
  static Color getCategoryColor(String category) {
    return categoryColors[category.toLowerCase()] ?? chartColors[0];
  }

  /// Get appropriate text color for background
  static Color getTextColorForBackground(Color backgroundColor) {
    // Calculate luminance to determine if background is light or dark
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? textPrimary : Colors.white;
  }

  /// Create a subtle shadow for cards and elevated elements
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: textSecondary.withOpacity(0.1),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  /// Create a more prominent shadow for floating elements
  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: textSecondary.withOpacity(0.15),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  // ===== MATERIAL THEME INTEGRATION =====
  
  /// Convert to Material ColorScheme for theme integration
  static ColorScheme get colorScheme => ColorScheme.fromSeed(
    seedColor: primaryAccent,
    brightness: Brightness.light,
    surface: cardBackground,
    primary: primaryAccent,
    secondary: secondaryAccent,
    error: danger,
    onSurface: textPrimary,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onError: Colors.white,
  );

  // ===== OPACITY VARIANTS =====
  
  /// Create subtle variants for hover states
  static Color get primaryHover => primaryAccent.withOpacity(0.8);
  static Color get successHover => success.withOpacity(0.8);
  static Color get warningHover => warning.withOpacity(0.8);
  
  /// Create background variants for disabled states
  static Color get disabledBackground => textSecondary.withOpacity(0.1);
  static Color get disabledText => textSecondary.withOpacity(0.5);
}

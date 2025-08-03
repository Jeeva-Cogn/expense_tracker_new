# 🚀 AI-Powered Expense Tracker

> **Production-Ready Flutter App with Advanced AI Features**

[![Flutter](https://img.shields.io/badge/Flutter-3.22.2-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.4.0-blue.svg)](https://dart.dev/)
[![Build Status](https://img.shields.io/badge/Build-Passing-brightgreen.svg)](https://flutter.dev/)
[![Web Ready](https://img.shields.io/badge/Web-Ready-orange.svg)](https://flutter.dev/web)

## 🌟 **Features**

### 🤖 **AI-Powered Intelligence**
- **Smart SMS Parsing**: Automatically extract expenses from bank SMS messages
- **Intelligent Categorization**: ML-like pattern recognition for expense categories
- **Fraud Detection**: Advanced algorithms to detect suspicious transactions
- **Merchant Recognition**: Extract and analyze merchant information with confidence scoring
- **Financial Health Scoring**: AI-driven financial wellness analysis

### 📊 **Advanced Analytics**
- **Interactive Dashboards**: Beautiful, responsive financial visualizations
- **Predictive Analytics**: Spending pattern analysis and budget predictions
- **Budget Health Monitoring**: Real-time budget adherence tracking
- **Goal Progress Tracking**: Smart financial goal management with AI recommendations
- **Comprehensive Reports**: Detailed expense analysis and insights

### 🎯 **Smart Features**
- **Intelligent Notifications**: Context-aware spending alerts and reminders
- **Auto-Categorization**: Smart expense categorization using AI patterns
- **Receipt Scanning**: OCR-powered receipt processing
- **Multi-Currency Support**: Global currency handling with real-time conversion
- **Recurring Expense Detection**: Automatic identification of recurring transactions

### 💾 **Technical Excellence**
- **Offline-First**: Local Hive database with sync capabilities
- **Material 3 Design**: Modern, beautiful UI with dark/light themes
- **Cross-Platform**: Web, Android, iOS ready
- **Type-Safe**: Full null safety and strong typing
- **Performance Optimized**: Efficient data handling and smooth animations

## 🏗️ **Architecture**

```
lib/
├── models/           # Data models with Hive annotations
│   ├── expense.dart     # Core expense model with AI features
│   ├── budget.dart      # Advanced budget management
│   ├── goal.dart        # Financial goal tracking
│   └── bill_reminder.dart # Smart bill reminders
├── services/         # Business logic layer
│   ├── analytics_service.dart    # Financial analytics engine
│   ├── notification_service.dart # Smart notification system
│   ├── database_service.dart     # Data management
│   └── ai_service.dart          # AI processing engine
├── widgets/          # Reusable UI components
│   ├── financial_dashboard.dart # Interactive charts
│   ├── expense_list.dart       # Smart expense listing
│   └── budget_widgets.dart     # Budget management UI
└── main.dart         # App entry point
```

## 🚀 **Quick Start**

### Prerequisites
- Flutter SDK 3.22.2+
- Dart SDK 3.4.0+
- Android Studio / VS Code

### Installation

```bash
# Clone the repository
git clone https://github.com/Jeeva-Cogn/ExpenseT.git
cd ExpenseT/expense_tracker_new

# Install dependencies
flutter pub get

# Generate Hive type adapters
dart run build_runner build

# Run the app
flutter run
```

### Web Deployment

```bash
# Build for web
flutter build web --release

# Deploy to hosting (Firebase, Netlify, etc.)
# Files will be in build/web/
```

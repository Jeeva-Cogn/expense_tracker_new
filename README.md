# 💎 Walletflow - AI-Powered Personal Finance Tracker

**Walletflow** is a beautifully designed, intelligent, and motivational expense tracker app built with Flutter. It helps users manage money smartly, track expenses via SMS, set budgets, visualize spending, and receive AI-driven financial advice — all while maintaining privacy and emotional well-being.

---

## 🔷 1. App Overview

An intelligent personal finance app that:
- Parses SMS messages to extract transaction data
- Categorizes expenses using AI
- Tracks budgets and spending visually
- Offers financial suggestions via an AI assistant
- Syncs securely with Google Sign-In and Firebase
- Supports gamification and multilingual UI
- Delivers a Cred-like UI with smooth animations, gradients, and emotional design

---

## 🧠 2. Core Features

### 🔹 A. SMS Transaction Analysis Engine

**Goal**: Extract and analyze financial SMS messages.

**Tech Stack**:
- Android SMS Retriever API / READ_SMS
- Regex + lightweight NLP (BERT fine-tuned on Indian bank SMS)
- Scheduled parsing via WorkManager (10 PM daily)

**Example SMS**:  
`₹2500 debited via UPI to Amazon on 2nd August.`

---

### 🔹 B. Expense Categorization System

**Goal**: Classify transactions into categories like Food, Bills, Rent, etc.

**AI Strategy**:
- Naive Bayes / LightGBM / fine-tuned LLM
- Features: Merchant name, description, time, amount

**Fallback Heuristics**:
| Merchant         | Category  |
|------------------|-----------|
| Swiggy, Zomato   | Food      |
| Amazon, Flipkart | Shopping  |
| UPI to friend    | Personal  |
| Rent, maintenance| Home      |

**User Feedback Loop**:
- Prompt user when uncertain:  
  _“We found ₹620 to 'Dream Bakers'. Is this Food, Shopping, or Personal?”_

---

### 🔹 C. Budget Tracker & Visual Dashboard

**Goal**: Let users set monthly budgets and track spending visually.

**UI Components**:
- Pie chart (category-wise spend %)
- Progress bar (monthly budget usage)
- Line chart (daily spend trend)
- Style: Inspired by Cred, Google Finance, YNAB
- Animations: `fl_chart`, `rive`, `animated_widgets`

---

### 🔹 D. AI-Based Financial Advisor

**Goal**: Provide smart, personalized financial insights.

**Capabilities**:
- Detect overspending trends
- Alert for missed bills
- Suggest category caps
- Compare weekly/monthly spending
- Forecast future expenses

**AI Options**:
| Type       | Tool                        |
|------------|-----------------------------|
| On-device  | TensorFlow Lite / EdgeBERT  |
| Cloud      | OpenAI API / Google Vertex AI |

**Example Prompt**:  
_“You’ve spent 25% over your food budget. Suggest skipping outside food this week?”_

---

### 🔹 E. Google Sign-In & Cloud Sync

**Goal**: Secure login and data backup.

**Implementation**:
| Task        | Tool                    |
|-------------|-------------------------|
| Login       | Firebase Authentication |
| Cloud DB    | Firebase Firestore      |
| Data Path   | `/users/<email>/data/`  |
| Auto-restore| On first login          |

**Synced Data**:
- SMS transaction history
- Categorization feedback
- Budgets
- AI suggestions
- Gamification progress

---

### 🔹 F. Gamification Engine

**Goal**: Motivate users with levels, badges, and streaks.

**Features**:
- Levels: Based on goals achieved
- Badges: “Saved ₹10,000”, “Zero Spend Day”
- Streak Tracker: Days without overspending

**UI**:
- Progress ring on dashboard
- Achievement screen
- Motivational alerts:  
  _“Level up! You’ve saved consistently for 7 days!”_

---

## 🎨 3. UI/UX Design Guidelines
**Visual Style (Cred-Inspired)**:
- Smooth animations using `rive`, `flutter_animate`, `hero`
- Gradient backgrounds, glassmorphism cards
- Minimalist layout with emotional design
- Motivational quotes on dashboard
- Light/Dark theme toggle
- Localized UI: Hindi, Tamil, etc.

**Screen Flow**:
| Screen         | Description                          |
|----------------|--------------------------------------|
| Welcome/Login  | Google Sign-In                       |
| Home Dashboard | Budget summary, pie chart, daily advice |
| Transactions   | Filter by date/category              |
| Category Insights | Drill-down per category           |
| AI Advisor     | Suggestions, alerts, goals           |
| Profile        | Google email, badges, level          |

**Home Screen Mock (in words)**:


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



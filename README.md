# ✈️ Travel Planner - AI-Powered Travel Assistant

A premium, AI-powered travel planning application built with Flutter. Designed with a sleek, modern dark theme (Glassmorphism), fluid animations, and robust offline caching, it delivers a state-of-the-art travel organization experience.

---

## 🌟 Key Features

*   **🤖 AI Travel Assistant Chatbot**: A smart virtual tour guide that answers travel questions, suggests local attractions, details accommodations, and dynamically updates your plans.
*   **📅 Smart Itinerary Generator**: Custom-tailor your trips by selecting destination details, travel moods/styles, number of days, and budget limits.
*   **📊 Visual Budget & Expense Tracker**: Keep tabs on your expenses during travel with interactive, beautiful charts (`fl_chart`) categorized by transport, food, accommodation, and activities.
*   **💫 Premium UX & Micro-Animations**: Built using `flutter_animate` to feature glassmorphic cards, smooth page transitions, and interactive visual feedback.
*   **💾 Offline Cache Support**: Local-first storage using Hive, ensuring your travel plans and budgets are fully accessible without internet access.
*   **🎨 Elegant Custom Dark Mode**: Implements a curated dark mode layout with custom HSL-tailored colors, gradients, and modern Google Fonts (`Outfit` / `Inter`).

---

## 🛠️ Technology Stack

| Technology / Library | Purpose |
| :--- | :--- |
| **Flutter / Dart** | Core cross-platform app framework |
| **Flutter Riverpod** | Robust state management & dependency injection |
| **Hive & Hive Flutter** | High-performance, lightweight local NoSQL database |
| **FL Chart** | Rich interactive charts for budget visualizer |
| **Flutter Animate** | Premium animations and card hover effects |
| **Google Fonts** | Typography (`Outfit` & `Inter` custom integration) |
| **Lucide Icons** | Sleek and modern icon system |
| **Share Plus** | Social features to share itineraries |

---

## 📂 Project Architecture & Directory Structure

The application follows a clean, feature-first structure:

```
lib/
├── core/                  # Core constants, mock data, and global models
│   ├── constants/         # App colors, sizes, and layout configurations
│   ├── data/              # Mock travel and itinerary data
│   └── models/            # Data models (Trip, Expense, Message, etc.)
├── features/              # Feature modules (Feature-driven design)
│   ├── auth/              # SplashScreen, Onboarding, and Login screens
│   ├── budget/            # Budget analysis screens and FL charts
│   ├── home/              # MainShell (navigation) and settings panel
│   ├── itinerary/         # AI Chatbot screen and Itinerary planner views
│   ├── providers/         # Global state providers (trip_provider, budget_provider, etc.)
│   └── trip/              # Trip details and trip generation flow
├── shared/                # Global reusable components (buttons, text fields)
├── theme/                 # AppTheme configurations (Colors, Fonts, Glassmorphic decorators)
└── main.dart              # Main application entry point
```

---

## 🚀 Getting Started & Installation

To run this application locally on your machine, follow these steps:

### Prerequisites

*   Flutter SDK installed (v3.10.7 or later recommended)
*   Dart SDK
*   An Android/iOS Emulator or connected physical device

### Step 1: Clone the Repository
```bash
git clone https://github.com/utsavgaywala/TravellPlanner-Flutter-App.git
cd TravellPlanner-Flutter-App
```

### Step 2: Install Dependencies
Fetch all required packages using pub:
```bash
flutter pub get
```

### Step 3: Run Code Generation
If you are generating/modifying the Hive type adapters:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Step 4: Launch the App
Run on your connected simulator or device:
```bash
flutter run
```

---

## 🎨 Design Philosophy

*   **Modern Aesthetics**: Glassmorphic UI overlays over rich background gradients.
*   **Intuitive Hierarchy**: Bold Outfit titles combined with clean Inter body copy to maximize readability.
*   **Micro-interactions**: Subtle scales, fades, and slides on card buttons to make the app feel alive.

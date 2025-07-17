# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**KimLedger** is a secure, cross-platform desktop application for personal finance tracking built with Flutter and Dart. The application focuses on providing a secure, encrypted solution for tracking personal expenses and financial data.

### Project Goals
- Build a secure personal finance tracking application
- Support cross-platform desktop deployment
- Maintain data security with encrypted local storage
- Provide intuitive expense categorization and tracking

### Target Platform
- **Primary**: Desktop applications (Windows, macOS, Linux)
- **Secondary**: Mobile and web support available through Flutter

## Current Development Status

The project has completed the **initial setup and entire data layer**. All core infrastructure is functional:

✅ **Completed Components:**
- Project structure and organization
- Complete data models (Category, Expense)
- Full database service with encryption
- State management with Provider
- Basic UI displaying expense list
- Encrypted SQLite database integration

🔄 **Ready for Next Phase:**
- UI/UX enhancements
- Additional screens and features
- Advanced expense management functionality

## Development Commands

### Flutter Commands
- `flutter run` - Run the app on connected device/emulator
- `flutter build apk` - Build Android APK
- `flutter build ios` - Build iOS app
- `flutter test` - Run all tests
- `flutter test test/widget_test.dart` - Run specific test file
- `flutter pub get` - Install dependencies
- `flutter pub upgrade` - Update dependencies
- `flutter clean` - Clean build artifacts
- `flutter analyze` - Run static analysis (lint checking)

### Platform-Specific Commands
- `cd android && ./gradlew assembleDebug` - Build Android debug APK
- `cd ios && xcodebuild -workspace Runner.xcworkspace -scheme Runner build` - Build iOS app

## Architecture Overview

This is a Flutter expense tracking application called "KimLedger" with the following structure:

### Core Architecture
- **State Management**: Provider pattern for managing app state
- **Database**: SQLite with encryption (sqflite_sqlcipher) for secure data storage
- **UI Framework**: Flutter Material Design

### Key Components

#### Database Layer (`lib/services/database_service.dart`)
- **Singleton pattern** for database access across the app
- **Encrypted SQLite database** with sqflite_sqlcipher for secure data storage
- **Database schema**: Two main tables with foreign key relationship
  - `categories`: id, name
  - `expenses`: id, description, value, user, date, category_id
- **CRUD operations**: Complete methods for adding/retrieving categories and expenses
- **Development features**: Includes dummy data generation and database reset functionality
- **SECURITY NOTE**: Database password is currently hardcoded as 'your-super-secret-password' - this should be changed in production

#### Data Models (`lib/models/`)
- **`Category`** (`category.dart`): Represents expense categories with id and name fields
- **`Expense`** (`expense.dart`): Represents financial transactions with:
  - Core fields: id, description, value, date, categoryId
  - Additional fields: user, categoryName (for JOIN results)
  - Database serialization methods (toMap/fromMap)

#### State Management (`lib/services/data_provider.dart`)
- **ChangeNotifier-based** DataProvider class using Provider package
- **Bridge layer** between UI and DatabaseService
- **Data management**: Handles expenses and categories throughout the app
- **Reactive updates**: Notifies UI of data changes via fetchData() method

#### UI Structure (`lib/screens/`)
- **`HomeScreen`** (`home_screen.dart`): Main application screen
  - Uses Provider.of<DataProvider> to access data
  - Displays expense list from the database
  - Material Design components
- **`main.dart`**: Application entry point with ChangeNotifierProvider setup

### Dependencies
- `sqflite_sqlcipher`: Encrypted SQLite database
- `provider`: State management
- `intl`: Internationalization support
- `cupertino_icons`: iOS-style icons

### Development Notes
- **Database reset**: Database is automatically deleted and recreated on app start (see `main.dart:14`) - useful for development
- **App theme**: Uses Teal as primary color theme with Material Design
- **Cross-platform**: Supports Android, iOS, Web, Windows, macOS, Linux
- **Development data**: Includes dummy expense data for testing (4 categories, 4 sample expenses)

## Working with This Project

### File Organization
```
lib/
├── models/          # Data models (Category, Expense)
├── screens/         # UI screens (HomeScreen)
├── services/        # Business logic (DatabaseService, DataProvider)
└── widgets/         # Reusable UI components (empty, ready for expansion)
```

### Key Implementation Details
- **Database initialization**: Handled in main() with proper async/await
- **Data flow**: UI → DataProvider → DatabaseService → SQLite
- **Security**: All financial data is encrypted at rest using SQLite cipher
- **State management**: Provider pattern ensures UI reactivity to data changes
- **Development workflow**: Database reset on each run for consistent testing
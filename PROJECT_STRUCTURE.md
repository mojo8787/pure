# PureFlow App - Project Structure

This document outlines the structure of the PureFlow app, explaining the purpose of each directory and how it contributes to the overall architecture.

## Overview

PureFlow follows a feature-first, clean architecture that organizes code into logical modules. The app uses Riverpod for state management, GoRouter for navigation, and Supabase for backend services.

## Directory Structure

```
lib/
├── app/                 # Application entry point
│   └── app.dart         # Root widget with providers
│
├── core/                # Core infrastructure
│   ├── config/          # App configuration
│   ├── di/              # Dependency injection
│   ├── models/          # Shared domain models
│   ├── router/          # Navigation system
│   ├── services/        # Backend services
│   ├── theme/           # UI theme configuration
│   └── utils/           # Utility functions
│
├── features/            # Feature modules
│   ├── admin/           # Admin web dashboard
│   ├── appointments/    # Scheduling functionality
│   ├── authentication/  # Authentication
│   ├── contracts/       # Contract management
│   ├── dashboard/       # Customer dashboard
│   ├── invoices/        # Invoice handling
│   ├── onboarding/      # User onboarding
│   ├── payments/        # Payment processing
│   ├── support/         # Support ticket system
│   └── technician/      # Technician portal
│
└── shared/              # Shared components
    ├── constants/       # App-wide constants
    ├── helpers/         # Helper functions
    └── widgets/         # Reusable UI widgets
```

## Feature Structure

Each feature module follows a consistent structure:

```
features/feature_name/
├── data/                # Data layer
│   ├── datasources/     # Remote and local data sources
│   └── repositories/    # Implementation of repositories
│
├── domain/              # Domain layer
│   ├── entities/        # Feature-specific domain models
│   ├── repositories/    # Repository interfaces
│   └── usecases/        # Business logic use cases
│
├── presentation/        # UI layer
│   ├── providers/       # Riverpod providers/notifiers
│   ├── screens/         # Feature screens
│   └── widgets/         # Feature-specific widgets
│
└── providers/           # Top-level providers for the feature
```

## Key Architecture Patterns

### State Management

- **Riverpod**: Main state management solution with `@riverpod` annotations
- **AsyncValue**: Loading, error, and data states in a single object
- **Notifiers**: Feature-specific state logic

### Navigation

- **GoRouter**: Declarative routing system
- **Deep linking**: Support for external links and notifications

### Backend

- **Supabase**: Authentication, database, storage, and functions
- **RLS**: Row-level security for data access control

## Data Flow

1. **UI Layer**: User interactions trigger provider methods
2. **Providers**: Handle state updates and delegate to services
3. **Services**: Communicate with Supabase
4. **Models**: Represent domain data with Freezed

## Code Generation

Several parts of the codebase use code generation:

- **Freezed**: For immutable models
- **Riverpod**: For generated providers
- **JSON Serialization**: For model serialization

Run code generation with:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## App Flow

The app follows this flow:

1. **Splash → Onboard → Auth**
2. **Accept Terms & Plan → e‑Sign Contract → Pay**
3. **Schedule Installation → Confirmation**
4. **Dashboard**

Technicians authenticate through the same splash/auth, but their JWT role claim directs them to a different flow: Today's Schedule → Job Detail → Checklist → Complete.

Admins use a separate web URL to access their dashboard. 
# Todo Feature

A fully functional Todo management module built with Flutter, Riverpod, Freezed, and Supabase.

## Features

- Create, read, update, and delete todos
- Mark todos as complete/incomplete
- Filter todos by completion status
- Set priority (low, medium, high)
- Proper error handling
- Pull-to-refresh
- Swipe to delete

## Architecture

The Todo feature follows a clean architecture approach:

- **Domain**: Contains the data models (Todo)
- **Data**: Contains the repository/service implementation
- **Presentation**: Contains screens and UI components
- **Providers**: Contains the Riverpod state management code

## Setup

### 1. Database Setup

Run the `migrations/create_todos_table.sql` script in your Supabase SQL editor to create the required table with proper row-level security policies.

### 2. Code Generation

The Todo feature requires code generation for Freezed models and Riverpod providers. Run the following command to generate the required files:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This will generate:
- `todo.freezed.dart` and `todo.g.dart` for the Todo model
- `todo_providers.g.dart` for the Riverpod providers
- `todo_service.g.dart` for the service provider

## Usage

The Todo feature can be accessed via:

1. Navigation drawer menu item "Todo List"
2. Quick action "Todo List" button on the dashboard
3. Direct URL navigation to `/todos`

## Implementation Details

- Uses `AsyncValue` from Riverpod for proper loading, data, and error state handling
- Implements proper error handling with custom error messages
- Uses Freezed for immutable data models
- Implements soft delete for todos (using `is_deleted` flag)
- Uses proper validation for form inputs 
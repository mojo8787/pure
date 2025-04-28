# PureFlow – RO Subscription & Maintenance App

Mobile application for reverse osmosis (RO) water filter subscription service, maintenance scheduling, and support.

## Project Overview

PureFlow is a comprehensive platform that connects:
- **End Users** (homeowners/renters): Manage water filter subscriptions, schedule maintenance, and request support
- **Maintenance Staff**: Track daily routes and complete installation/maintenance checklists
- **Administrators**: Manage customers, technicians, subscriptions, and monitor KPIs

## Architecture

The project follows a feature-first, clean architecture approach with:

### Core Layers
- **App**: Application entry point and global providers
- **Core**: Base infrastructure (config, theme, router, DI, models, services)
- **Features**: Feature modules with domain logic and presentation
- **Shared**: Reusable components across features

### State Management
- **Riverpod**: Main state management solution
- **Flutter Hooks**: For UI state and effects
- **AsyncValue**: For handling loading, error, and success states

### Backend
- **Supabase**: For authentication, database, storage, and edge functions
- **Row-Level Security**: For secure data access control

## Features & Screens

1. **Onboarding & Authentication**
   - Splash, onboarding, email/OTP authentication
   - Role-based routing (customer, technician, admin)

2. **Subscription Flow**
   - Terms & plan selection
   - Contract e-signing
   - Payment processing (Apple Pay/card)
   - Installation scheduling

3. **Customer Dashboard**
   - Next visit tracking
   - Invoice history
   - Support ticket creation

4. **Technician Portal**
   - Daily schedule management
   - Job checklists
   - Offline functionality

5. **Admin Platform**
   - Customer management
   - Subscription handling
   - Appointment scheduling
   - Invoice and support management

## Data Model

Built on Supabase with key tables:
- users
- customer_profiles
- technician_profiles
- contracts
- subscriptions
- appointments
- maintenance_visits
- invoices
- tickets

## Getting Started

1. **Setup Environment**
   ```bash
   flutter pub get
   ```

2. **Code Generation**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

3. **Configure Supabase**
   - Update environment variables in `.env`
   - Apply migrations for database schema

4. **Run the App**
   ```bash
   flutter run
   ```

## Coding Standards

- Use Freezed for immutable state models
- Use Riverpod's @riverpod annotations
- Follow Flutter's style guide and linting rules
- Write unit and integration tests for core functionality

## Deployment

- iOS: TestFlight → App Store
- Android: Internal Testing → Play Store
- Web: Firebase Hosting (Admin Dashboard)

## License

Proprietary - All Rights Reserved

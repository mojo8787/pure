import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pureflow/core/router/routes.dart';
import 'package:pureflow/features/subscriptions/presentation/screens/subscriptions_screen.dart';
import 'package:pureflow/features/subscriptions/presentation/screens/add_subscription_screen.dart';
import 'package:pureflow/features/authentication/presentation/screens/login_screen.dart';
import 'package:pureflow/features/authentication/presentation/screens/signup_screen.dart';
import 'package:pureflow/features/authentication/presentation/screens/verification_screen.dart';
import 'package:pureflow/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:pureflow/features/dashboard/presentation/screens/schedule_visit_screen.dart';
import 'package:pureflow/features/todo/presentation/components/todo_screen.dart';
import 'package:pureflow/features/todo/presentation/screens/todo_detail_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    initialLocation: Routes.login,
    debugLogDiagnostics: true,
    routes: [
      // Auth
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: Routes.verification,
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return VerificationScreen(email: email);
        },
      ),
      GoRoute(
        path: '/auth/callback',
        builder: (context, state) {
          // This page will receive the auth callback from Supabase for web platform
          // Extract the auth parameters from the URL
          final queryParams = state.uri.queryParameters;
          
          // Handle the callback
          if (queryParams.containsKey('error')) {
            // Handle error
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text('Authentication Error: ${queryParams['error_description'] ?? queryParams['error']}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.go(Routes.login),
                      child: const Text('Go to Login'),
                    ),
                  ],
                ),
              ),
            );
          } else {
            // For successful authentication, redirect to login (user still needs to enter credentials)
            Future.delayed(Duration.zero, () {
              context.go(Routes.login);
            });
            
            // Show a loading screen while redirecting
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Email verified! Redirecting...'),
                  ],
                ),
              ),
            );
          }
        },
      ),
      
      // Dashboard
      GoRoute(
        path: Routes.dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      
      // Subscriptions
      GoRoute(
        path: Routes.subscriptions,
        builder: (context, state) => const SubscriptionsScreen(),
      ),
      GoRoute(
        path: Routes.addSubscription,
        builder: (context, state) => const AddSubscriptionScreen(),
      ),
      GoRoute(
        path: Routes.subscriptionDetail,
        builder: (context, state) {
          final subscriptionId = state.pathParameters['id']!;
          // Implement subscription detail screen in the future
          return Scaffold(
            appBar: AppBar(title: const Text('Subscription Details')),
            body: Center(child: Text('Subscription ID: $subscriptionId')),
          );
        },
      ),
      
      // Todo
      GoRoute(
        path: Routes.todos,
        builder: (context, state) => const TodoScreen(),
      ),
      GoRoute(
        path: Routes.todoDetail,
        builder: (context, state) {
          final todoId = state.pathParameters['id']!;
          return TodoDetailScreen(todoId: todoId);
        },
      ),
      GoRoute(
        path: Routes.scheduleVisit,
        builder: (context, state) => const ScheduleVisitScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Route not found: ${state.uri}'),
      ),
    ),
  );
} 
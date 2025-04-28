import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../exceptions/app_exception.dart';

/// A utility class for handling errors in the UI
class ErrorHandler {
  /// Handles AsyncValue states and renders appropriate UI based on the state
  /// 
  /// [value] - The AsyncValue to handle
  /// [onData] - Builder function that builds the UI when data is available
  /// [loadingBuilder] - Optional builder for loading state (defaults to CircularProgressIndicator)
  /// [onRetry] - Optional callback to trigger when retry is pressed
  /// [align] - Whether to center the error and loading states (defaults to true)
  static Widget handleAsyncValue<T>({
    required AsyncValue<T> value,
    required Widget Function(T data) onData,
    Widget Function()? loadingBuilder,
    VoidCallback? onRetry,
    bool align = true,
  }) {
    return value.when(
      data: onData,
      loading: () {
        final loadingWidget = loadingBuilder?.call() ?? 
          const CircularProgressIndicator();
        
        return align
          ? Center(child: loadingWidget)
          : loadingWidget;
      },
      error: (error, stackTrace) {
        String errorMessage = 'An unexpected error occurred';
        IconData errorIcon = Icons.error_outline;
        
        if (error is AppException) {
          errorMessage = error.when(
            authentication: (message) {
              errorIcon = Icons.lock_outline;
              return message;
            },
            network: (message) {
              errorIcon = Icons.wifi_off;
              return message;
            },
            data: (message) {
              errorIcon = Icons.data_array;
              return message;
            },
            permission: (message) {
              errorIcon = Icons.no_accounts;
              return message;
            },
            serviceUnavailable: (message) {
              errorIcon = Icons.cloud_off;
              return message;
            },
            unknown: (message) {
              errorIcon = Icons.question_mark;
              return message;
            },
            validation: (message) {
              errorIcon = Icons.assignment_late;
              return message;
            },
            duplicated: (message) {
              errorIcon = Icons.copy_all;
              return message;
            },
            notFound: (message) {
              errorIcon = Icons.search_off;
              return message;
            },
          );
        } else {
          errorMessage = error.toString();
        }
        
        final errorWidget = _buildErrorWidget(
          errorMessage: errorMessage,
          errorIcon: errorIcon,
          onRetry: onRetry,
        );
        
        return align
          ? Center(child: errorWidget)
          : errorWidget;
      },
    );
  }
  
  /// Builds an error widget with icon, message and optional retry button
  static Widget _buildErrorWidget({
    required String errorMessage,
    required IconData errorIcon,
    VoidCallback? onRetry,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          errorIcon,
          color: Colors.red,
          size: 48,
        ),
        const SizedBox(height: 16),
        SelectableText.rich(
          TextSpan(
            text: errorMessage,
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          textAlign: TextAlign.center,
        ),
        if (onRetry != null) ...[
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ],
    );
  }
} 
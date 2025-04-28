import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_exception.freezed.dart';

/// A generic exception type for app-specific errors
@freezed
class AppException with _$AppException {
  /// Create an authentication error (user not logged in, session expired, etc.)
  const factory AppException.authentication(String message) = _AuthenticationException;
  
  /// Create a network error (no connection, server unavailable, etc.)
  const factory AppException.network(String message) = _NetworkException;
  
  /// Create a data error (parsing failed, invalid format, etc.)
  const factory AppException.data(String message) = _DataException;
  
  /// Create a permission error (insufficient permissions)
  const factory AppException.permission(String message) = _PermissionException;

  /// Create a service unavailable error (service down, maintenance, etc.)
  const factory AppException.serviceUnavailable(String message) = _ServiceUnavailableException;
  
  /// Create a general error (catches all other error types)
  const factory AppException.unknown(String message) = _UnknownException;
  
  /// Create a validation error (form validation, etc.)
  const factory AppException.validation(String message) = _ValidationException;
  
  /// Create a duplicated entity error (trying to create existing resource)
  const factory AppException.duplicated(String message) = _DuplicatedException;
  
  /// Create a not found error (resource not found)
  const factory AppException.notFound(String message) = _NotFoundException;
} 
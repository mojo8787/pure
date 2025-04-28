import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

part 'app_config.freezed.dart';

final appConfigProvider = Provider<AppConfig>((ref) {
  throw UnimplementedError('Should be overridden in ProviderScope');
});

@freezed
class AppConfig with _$AppConfig {
  const factory AppConfig({
    required String supabaseUrl,
    required String supabaseAnonKey,
    required bool debug,
    @Default('JOD') String currencyCode,
    @Default(25.0) double monthlyPrice,
  }) = _AppConfig;

  static Future<AppConfig> load() async {
    // Load environment variables from .env file
    await dotenv.load(fileName: '.env').catchError((e) {
      // If .env file doesn't exist, load from example file
      return dotenv.load(fileName: 'lib/core/config/env_example.txt');
    });

    return AppConfig(
      supabaseUrl: dotenv.env['SUPABASE_URL'] ?? 'http://localhost:8000',
      supabaseAnonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? 
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJvbGUiOiJhbm9uIn0.ZopqoUt20nEV9cklpv_ZJFJpr0vPpGvZtLNJR-cni5Y',
      debug: kDebugMode,
    );
  }
} 
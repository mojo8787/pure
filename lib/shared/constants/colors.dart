import 'package:flutter/material.dart';

class AppColors {
  // Brand colors
  static const primary = Color(0xFF0087D6);
  static const secondary = Color(0xFF00C6F8);
  static const accent = Color(0xFF2DD4BF);
  
  // Gradient colors
  static const gradientStart = Color(0xFF0087D6);
  static const gradientEnd = Color(0xFF00C6F8);
  
  // Text colors
  static const textDark = Color(0xFF1F2937);
  static const textMedium = Color(0xFF6B7280);
  static const textLight = Color(0xFFD1D5DB);
  
  // Background colors
  static const backgroundLight = Color(0xFFF9FAFB);
  static const backgroundDark = Color(0xFF111827);
  
  // Card colors
  static const cardLight = Color(0xFFFFFFFF);
  static const cardDark = Color(0xFF1F2937);
  
  // Status colors
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);
  
  // Button states
  static const buttonDisabled = Color(0xFFE5E7EB);
  static const buttonPressed = Color(0xFF0072B5);
  
  // Linear gradient for brand
  static const brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientEnd],
  );
} 
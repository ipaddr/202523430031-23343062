import 'package:flutter/material.dart';

// Color Palette
const Color primaryColor = Color(0xFF148B9A); // biru lembut (ocean)
const Color secondaryColor = Color(0xFFD81159); // magenta
const Color accentColor = Color(0xFFA0F4FF); // cyan light
const Color successColor = Color(0xFF4CAF50); // green
const Color warningColor = Color(0xFFFFC107); // amber
const Color errorColor = Color(0xFFE63946); // red
const Color backgroundColor = Color(0xFFF5FAFB); // very light blue
const Color surfaceColor = Colors.white;
const Color textPrimaryColor = Color(0xFF101720); // dark blue
const Color textSecondaryColor = Color(0xFF6B7280); // gray

// Gradients
const LinearGradient mainGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [secondaryColor, primaryColor],
);

const LinearGradient accentGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [accentColor, primaryColor],
);

// Text Styles
TextStyle bold = const TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w800,
  fontFamily: 'Raleway',
  color: textPrimaryColor,
);

TextStyle regular = bold.copyWith(fontSize: 11, fontWeight: FontWeight.normal);
TextStyle medium = bold.copyWith(fontSize: 11, fontWeight: FontWeight.w600);

// Enhanced Text Styles
const TextStyle heading1 = TextStyle(
  fontSize: 32,
  fontWeight: FontWeight.w800,
  color: textPrimaryColor,
  fontFamily: 'Raleway',
);

const TextStyle heading2 = TextStyle(
  fontSize: 28,
  fontWeight: FontWeight.w700,
  color: textPrimaryColor,
  fontFamily: 'Raleway',
);

const TextStyle heading3 = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.w600,
  color: textPrimaryColor,
  fontFamily: 'Raleway',
);

const TextStyle bodyLarge = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w500,
  color: textPrimaryColor,
  fontFamily: 'Raleway',
);

const TextStyle bodyMedium = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w500,
  color: textPrimaryColor,
  fontFamily: 'Raleway',
);

const TextStyle bodySmall = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w400,
  color: textSecondaryColor,
  fontFamily: 'Raleway',
);

const TextStyle labelLarge = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w600,
  color: textPrimaryColor,
  fontFamily: 'Raleway',
);

const TextStyle labelSmall = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w600,
  color: textPrimaryColor,
  fontFamily: 'Raleway',
);

// Shadow constants
const BoxShadow elevationShadow1 = BoxShadow(
  color: Color.fromARGB(20, 0, 0, 0),
  blurRadius: 4,
  offset: Offset(0, 2),
);

const BoxShadow elevationShadow2 = BoxShadow(
  color: Color.fromARGB(24, 0, 0, 0),
  blurRadius: 8,
  offset: Offset(0, 4),
);

const BoxShadow elevationShadow3 = BoxShadow(
  color: Color.fromARGB(32, 0, 0, 0),
  blurRadius: 16,
  offset: Offset(0, 8),
);

const List<BoxShadow> cardShadow = [elevationShadow2];
const List<BoxShadow> buttonShadow = [elevationShadow2];
const List<BoxShadow> dialogShadow = [elevationShadow3];

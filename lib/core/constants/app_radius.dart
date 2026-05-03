import 'package:flutter/material.dart';

/// Border-radius scale — Design.md Section 2.3
/// Default (cards, inputs, small elements): 8px
/// Large (dialogs, large cards): 16px
/// Buttons: 8px (rectangular), 12px (larger)
/// Chips/Badges: 16px (fully rounded pill)
class AppRadius {
  AppRadius._();

  // Base radius values
  static const double xs = 4;    // Small elements
  static const double sm = 8;    // Default: cards, inputs, small elements
  static const double md = 12;   // Larger buttons
  static const double lg = 16;   // Large: dialogs, large cards, chips/badges
  static const double pill = 999; // Fully rounded

  // Radius objects
  static const Radius radiusXs = Radius.circular(xs);
  static const Radius radiusSm = Radius.circular(sm);
  static const Radius radiusMd = Radius.circular(md);
  static const Radius radiusLg = Radius.circular(lg);
  static const Radius radiusPill = Radius.circular(pill);

  // BorderRadius constants
  static const BorderRadius allXs = BorderRadius.all(radiusXs);
  static const BorderRadius allSm = BorderRadius.all(radiusSm);
  static const BorderRadius allMd = BorderRadius.all(radiusMd);
  static const BorderRadius allLg = BorderRadius.all(radiusLg);
  static const BorderRadius allPill = BorderRadius.all(radiusPill);

  // Design.md semantic aliases
  /// Cards, inputs, small elements — 8px
  static const BorderRadius card = allSm;

  /// Dialog backgrounds, large cards — 16px
  static const BorderRadius dialog = allLg;

  /// Standard buttons — 8px
  static const BorderRadius button = allSm;

  /// Larger buttons — 12px
  static const BorderRadius buttonLarge = allMd;

  /// Chips and badges — 16px (fully rounded)
  static const BorderRadius chip = allLg;
}

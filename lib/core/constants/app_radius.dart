import 'package:flutter/material.dart';

/// Border-radius scale — only the values declared here may be used in the UI.
class AppRadius {
  AppRadius._();

  static const double xs = 6;
  static const double sm = 9;
  static const double md = 11;
  static const double lg = 14;
  static const double pill = 999;

  static const Radius radiusXs = Radius.circular(xs);
  static const Radius radiusSm = Radius.circular(sm);
  static const Radius radiusMd = Radius.circular(md);
  static const Radius radiusLg = Radius.circular(lg);
  static const Radius radiusPill = Radius.circular(pill);

  static const BorderRadius allXs = BorderRadius.all(radiusXs);
  static const BorderRadius allSm = BorderRadius.all(radiusSm);
  static const BorderRadius allMd = BorderRadius.all(radiusMd);
  static const BorderRadius allLg = BorderRadius.all(radiusLg);
  static const BorderRadius allPill = BorderRadius.all(radiusPill);
}

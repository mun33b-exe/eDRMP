import 'package:flutter/material.dart';

class AppRadius {
  static const double xs = 4.0;
  static const double s = 8.0;
  static const double m = 12.0;
  static const double l = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;

  static const Radius radiusXS = Radius.circular(xs);
  static const Radius radiusS = Radius.circular(s);
  static const Radius radiusM = Radius.circular(m);
  static const Radius radiusL = Radius.circular(l);
  static const Radius radiusXL = Radius.circular(xl);

  static BorderRadius get allXS => BorderRadius.circular(xs);
  static BorderRadius get allS => BorderRadius.circular(s);
  static BorderRadius get allM => BorderRadius.circular(m);
  static BorderRadius get allL => BorderRadius.circular(l);
  static BorderRadius get allXL => BorderRadius.circular(xl);
  static BorderRadius get allXXL => BorderRadius.circular(xxl);
}

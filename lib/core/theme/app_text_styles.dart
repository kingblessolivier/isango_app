import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTextStyles {
  static final display = GoogleFonts.splineSans(
    fontSize: 32,
    height: 1.25,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.02 * 32,
    color: AppColors.logisticsNavy,
  );

  static final headline = GoogleFonts.splineSans(
    fontSize: 24,
    height: 1.33,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.01 * 24,
    color: AppColors.logisticsNavy,
  );

  static final title = GoogleFonts.lexend(
    fontSize: 18,
    height: 1.33,
    fontWeight: FontWeight.w600,
    color: AppColors.nearBlackInk,
  );

  static final body = GoogleFonts.lexend(
    fontSize: 16,
    height: 1.5,
    color: AppColors.nearBlackInk,
  );

  static final bodyMuted = GoogleFonts.lexend(
    fontSize: 14,
    height: 1.43,
    color: AppColors.mutedOperationalInk,
  );

  static final label = GoogleFonts.lexend(
    fontSize: 12,
    height: 1.33,
    fontWeight: FontWeight.w600,
    color: AppColors.mutedOperationalInk,
  );
}

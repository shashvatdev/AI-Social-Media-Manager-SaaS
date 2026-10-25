import 'package:flutter/material.dart';

class AppColors {
  // --- PRIMARY LUXURY PALETTE (from Brand Design Brief) ---
  static const Color iceSilver = Color(0xFFDDE3E8);
  static const Color deepAubergine = Color(0xFF3A0F34);
  static const Color marigold = Color(0xFFEAAA00);

  // --- LUXURY DARK MODE CANVAS & SURFACES ---
  static const Color obsidian = Color(0xFF110410);          // Deepest background
  static const Color darkCanvas = Color(0xFF190618);        // Main screen background
  static const Color surfaceAubergine = Color(0xFF260A23);  // Card surfaces
  static const Color elevatedSurface = Color(0xFF320E2E);   // Modals / Elevated cards
  static const Color borderAubergine = Color(0xFF4C1544);   // Crisp hairline borders
  static const Color borderHighlight = Color(0xFF6B2060);   // Focused borders

  // --- ACCENTS & GLOWS ---
  static const Color marigoldGlow = Color(0x33EAAA00);      // 20% glow
  static const Color electricAmber = Color(0xFFFFBF00);
  static const Color emeraldSuccess = Color(0xFF00E599);     // Published / Verified badge
  static const Color crimsonReject = Color(0xFFFF3366);      // Reject / Danger badge
  static const Color cobaltInfo = Color(0xFF2D8CFF);

  // --- TEXT SYSTEM ---
  static const Color textPrimary = Color(0xFFF5F8FA);       // 100% white-silver
  static const Color textSecondary = Color(0xFFAEBCC7);     // 70% silver muted
  static const Color textTertiary = Color(0xFF708090);      // 40% subtle labels
  static const Color textOnMarigold = Color(0xFF190618);    // High contrast black on yellow
}

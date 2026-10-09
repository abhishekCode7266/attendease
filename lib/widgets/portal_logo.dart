import 'package:flutter/material.dart';

/// PortalLogo renders the official Student Attendance Portal emblem
class PortalLogo extends StatelessWidget {
  final double size;
  final bool showBadge;

  const PortalLogo({
    super.key,
    this.size = 64,
    this.showBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E3A8A), // Deep Royal Blue
            Color(0xFF2563EB), // Vibrant Blue
            Color(0xFF0284C7), // Sky/Cyan Accent
          ],
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(
          color: const Color(0xFFFBBF24).withValues(alpha: 0.8), // Gold trim
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.35),
            blurRadius: size * 0.25,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Shield Glow
          Icon(
            Icons.shield_rounded,
            size: size * 0.72,
            color: const Color(0xFF0284C7).withValues(alpha: 0.3),
          ),
          // Graduation Cap
          Positioned(
            top: size * 0.16,
            child: Icon(
              Icons.school_rounded,
              size: size * 0.44,
              color: Colors.white,
            ),
          ),
          // Checkmark verification badge
          Positioned(
            bottom: size * 0.16,
            child: Container(
              padding: EdgeInsets.all(size * 0.04),
              decoration: const BoxDecoration(
                color: Color(0xFF10B981), // Emerald Green
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                size: size * 0.24,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

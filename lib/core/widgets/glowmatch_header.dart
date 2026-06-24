import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glowmatch/features/profile/profile_screen.dart';

class GlowMatchHeader extends StatelessWidget {
  final VoidCallback? onProfileTap;

  const GlowMatchHeader({super.key, this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RichText(
          text: TextSpan(
            text: 'GlowMatch',
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: -0.5,
            ),
            children: const [
              TextSpan(
                text: '.',
                style: TextStyle(color: Colors.red, fontSize: 32),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.account_circle_outlined, size: 28, color: textColor),
          onPressed:
              onProfileTap ??
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
        ),
      ],
    );
  }
}

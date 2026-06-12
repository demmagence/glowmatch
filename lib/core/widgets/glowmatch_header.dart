import 'package:flutter/material.dart';
import 'package:glowmatch/features/profile/profile_screen.dart';

class GlowMatchHeader extends StatelessWidget {
  final VoidCallback? onProfileTap;

  const GlowMatchHeader({
    super.key,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RichText(
          text: const TextSpan(
            text: 'GlowMatch',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.black,
              letterSpacing: -0.5,
            ),
            children: [
              TextSpan(
                text: '.',
                style: TextStyle(color: Colors.red, fontSize: 32),
              )
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.account_circle_outlined, size: 28),
          onPressed: onProfileTap ??
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
        ),
      ],
    );
  }
}

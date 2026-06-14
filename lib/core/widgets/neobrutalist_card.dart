import 'package:flutter/material.dart';

class NeobrutalistCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final Color? shadowColor;
  final Color? borderColor;
  final double borderWidth;
  final double borderRadius;
  final Offset shadowOffset;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const NeobrutalistCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.shadowColor,
    this.borderColor,
    this.borderWidth = 1.2,
    this.borderRadius = 4.0,
    this.shadowOffset = const Offset(4, 4),
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resolvedBg =
        backgroundColor ?? (isDark ? const Color(0xFF1E1E1E) : Colors.white);
    final resolvedBorder =
        borderColor ?? (isDark ? Colors.white : Colors.black);
    final resolvedShadow =
        shadowColor ??
        (isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black87);

    final cardWidget = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: resolvedBg,
        border: Border.all(color: resolvedBorder, width: borderWidth),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(color: resolvedShadow, blurRadius: 0, offset: shadowOffset),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: cardWidget);
    }

    return cardWidget;
  }
}

import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double elevation;
  final ShapeBorder? shape;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.elevation = 1,
    this.shape,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      color: color ?? Theme.of(context).cardColor,
      shape: shape ?? RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: padding != null 
        ? Padding(padding: padding!, child: child)
        : child,
    );
  }
} 
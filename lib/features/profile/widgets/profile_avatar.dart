import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String? url;
  final VoidCallback? onTap;
  final double size;

  const ProfileAvatar({
    super.key,
    this.url,
    this.onTap,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: size / 2,
        backgroundColor: Colors.grey[200],
        backgroundImage: url == null ? null : NetworkImage(url!),
        child: url == null ? Icon(Icons.person, size: size * 0.6) : null,
      ),
    );
  }
} 
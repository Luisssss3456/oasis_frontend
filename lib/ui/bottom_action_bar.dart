// bottom_action_bar.dart
import 'package:flutter/material.dart';

class BottomActionBar extends StatelessWidget {
  final VoidCallback onCenter;
  final VoidCallback onClear;
  final bool showClear;

  const BottomActionBar({
    Key? key,
    required this.onCenter,
    required this.onClear,
    required this.showClear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 140, 0),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (showClear)
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color.fromARGB(255,70, 75, 87)
                ),
                onPressed: onClear,
                child: const Text('Clear'),
              )
            else
              const SizedBox.shrink(),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color.fromARGB(255,70, 75, 87)
              ),
              onPressed: onCenter,
              child: const Text('Center'),
            ),
          ],
        ),
      ),
    );
  }
}
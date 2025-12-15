import 'package:flutter/material.dart';
import 'confirm_dialog.dart';

class RightPanel extends StatelessWidget{
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  // To control position on screen
  final double topBelowSearch;
  final double rightEdge;

  const RightPanel({
    Key? key,
    required this.onZoomIn,
    required this.onZoomOut,

    this.topBelowSearch = 100,
    this.rightEdge = 16,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Positioned (
      top: topBelowSearch,
      right: rightEdge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color.fromARGB(255,70, 75, 87)
          ),
            onPressed: onZoomIn,
            child: const Text('+'),
        ),
          const SizedBox(height: 12),
          TextButton(
            style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color.fromARGB(255,70, 75, 87)
          ),
          onPressed: onZoomOut,
          child: const Text('-'),
        ),
      ],
      ),
    );
  }
}
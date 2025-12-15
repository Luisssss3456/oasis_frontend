import 'package:flutter/material.dart';

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
          IconButton(
            style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color.fromARGB(255,70, 75, 87)
          ),
            onPressed: onZoomIn,
            icon: const Icon(Icons.add),
            tooltip: "Zoom in",
        ),
          const SizedBox(height: 7),
          IconButton(
            style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color.fromARGB(255,70, 75, 87)
          ),
          onPressed: onZoomOut,
          icon: const Icon(Icons.remove),
          tooltip: "Zoom out",
        ),
      ],
      ),
    );
  }
}
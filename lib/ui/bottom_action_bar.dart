// bottom_action_bar.dart
import 'package:flutter/material.dart';
import 'confirm_dialog.dart';

class BottomActionBar extends StatelessWidget {
  final VoidCallback onCenter;
  final VoidCallback onClear;
  final bool showClear;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  const BottomActionBar({
    Key? key,
    required this.onCenter,
    required this.onClear,
    required this.showClear,
    required this.onZoomIn,
    required this.onZoomOut,
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
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => const ConfirmDialog(
                    title: "Clear Route", 
                    content: "Do you want to clear the route?",
                    ),
                  );
                  if (confirm == true){
                    onClear();
                  }
                },
                child: const Text('Clear'),
              )
            else
              //const SizedBox.shrink(),
              Opacity(
                opacity: 0,
                child: TextButton(
                  onPressed: null,
                  child: Text("")
                )),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color.fromARGB(255,70, 75, 87)
              ),
              onPressed: onZoomIn,
              child: const Text('+'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color.fromARGB(255,70, 75, 87)
              ),
              onPressed: onZoomOut,
              child: const Text('-'),
            ),
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
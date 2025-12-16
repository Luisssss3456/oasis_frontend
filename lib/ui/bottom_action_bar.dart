// bottom_action_bar.dart
import 'package:flutter/material.dart';
import 'confirm_dialog.dart';

class BottomActionBar extends StatelessWidget {
  final VoidCallback onCenter;
  final VoidCallback onClear;
  final bool showClear;
  final double shadeValue;
  final double ndviValue;

  const BottomActionBar({
    Key? key,
    required this.onCenter,
    required this.onClear,
    required this.showClear,
    required this.shadeValue,
    required this.ndviValue,
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
              IconButton(
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
                icon: const Icon(Icons.close),
                tooltip: 'Clear Route',
                //child: const Text('Clear'),
              )
            else
              //const SizedBox.shrink(),
              Opacity(
                opacity: 0,
                child: TextButton(
                  onPressed: null,
                  child: Text("")
                )),
            if (showClear)
              RichText(
                text: TextSpan(
                  //text: 'Shade: $shadeValue',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    ),
                  children: [
                    WidgetSpan(
                      child: Icon(Icons.person, size: 35),
                      ),
                  ],
                  text: '$shadeValue',
                )
              )
            else 
              Opacity(
                opacity: 0,
                child: Text("")
                ),
            if (showClear)
              RichText(
                text: TextSpan(
                  //text: 'Shade: $shadeValue',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    ),
                  children: [
                    WidgetSpan(
                      child: Icon(Icons.park, size: 35),
                      ),
                  ],
                  text: '$ndviValue',
                )
              )
            else 
              Opacity(
                opacity: 0,
                child: Text("")
                ),
            IconButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color.fromARGB(255,70, 75, 87)
              ),
              onPressed: onCenter,
              icon: const Icon(Icons.explore),
              tooltip: "Center to current location",
            ),
          ],
        ),
      ),
    );
  }
}
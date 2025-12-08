import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class RouteLayerWidget extends StatelessWidget {
  final List<LatLng> linePoints;
  final Color color;
  final double strokeWidth;

  const RouteLayerWidget({
    Key? key,
    required this.linePoints,
    this.color = const Color.fromARGB(255, 61, 153, 112),
    this.strokeWidth = 6.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (linePoints.isEmpty) {
      return const SizedBox.shrink(); 
    }

    return PolylineLayer(
      polylines: [
        Polyline(
          points: linePoints,
          color: color,
          strokeWidth: strokeWidth,
        ),
      ],
    );
  }
}
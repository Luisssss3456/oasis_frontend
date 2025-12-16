import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class RouteLayerWidget extends StatelessWidget {
  final List<LatLng> linePoints;
  //final Color color;
  final double strokeWidth;
  final List<Color> colors;

  const RouteLayerWidget({
    Key? key,
    required this.linePoints,
    required this.colors,
    this.strokeWidth = 6.0,
  }) : super(key: key);

  List<Polyline> _drawPoints(List<LatLng> polys){

    List<Polyline> polyPoints = [];

    for (int i = 0; i < polys.length - 1; i++) {

      polyPoints.add(
          Polyline(
            points: [polys[i], polys[i + 1]],
            color: colors[i],
            strokeWidth: strokeWidth
            ),
        );
    }

    return polyPoints;

  }

  @override
  Widget build(BuildContext context) {
    if (linePoints.isEmpty) {
      return const SizedBox.shrink(); 
    }

    return PolylineLayer(

      polylines: _drawPoints(linePoints),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class RouteLayerWidget extends StatelessWidget {
  final List<LatLng> linePoints;
  //final Color color;
  final double strokeWidth;
  final List<double> shadeValue;

  const RouteLayerWidget({
    Key? key,
    required this.linePoints,
    required this.shadeValue,
    //this.color = const Color.fromARGB(255, 61, 153, 112),
    this.strokeWidth = 6.0,
  }) : super(key: key);

  List<Polyline> _drawPoints(List<LatLng> polys){

    List<Polyline> polyPoints = [];

    Color color;

    for (int i = 0; i < polys.length - 1; i++) {

      switch (polys[i]) {
        default:
          color = const Color.fromARGB(255, 61, 153, 112);
          break;
      }

      polyPoints.add(
          Polyline(
            points: [polys[i], polys[i + 1]],
            color: color,
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
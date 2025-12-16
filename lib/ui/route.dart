import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class RouteLayerWidget extends StatelessWidget {
  final List<LatLng> linePoints;
  //final Color color;
  final double strokeWidth;
  final List<double> shadeSegments;
  final List<double> ndviSegments;

  const RouteLayerWidget({
    Key? key,
    required this.linePoints,
    required this.shadeSegments,
    required this.ndviSegments,
    this.strokeWidth = 6.0,
  }) : super(key: key);

  List<Polyline> _drawPoints(List<LatLng> polys, List<double> shades, List<double> ndvis){

    List<Polyline> polyPoints = [];

    Color color;

    for (int i = 0; i < polys.length - 1; i++) {

      // if(shades[i] > 0.66 && ndvis[i] > 0.66){
      //   color = Color.fromRGBO(90, 77, 164, 255);
      // }
      // else if(shades[i] > 0.66 && ndvis[i] > 0.33){
      //   color = Color.fromRGBO(205, 154, 204, 255);
      // }
      // else if(shades[i] > 0.66 && ndvis[i] <= 0.33){
      //   color = Color.fromRGBO(240, 4, 127, 255);
      // }
      // else if(shades[i] > 0.33 && ndvis[i] > 0.66){
      //   color = Color.fromRGBO(154, 201, 213, 255);
      // }
      // else if(shades[i] > 0.33 && ndvis[i] > 0.33){
      //   color = Color.fromRGBO(230, 230, 230, 255);
      // }
      // else if(shades[i] > 0.33 && ndvis[i] <= 0.33){
      //   color = Color.fromRGBO(254, 154, 166, 255);
      // }
      // else if(shades[i] <= 0.33 && ndvis[i] > 0.66){
      //   color = Color.fromRGBO(0, 136, 55, 255);
      // }
      // else if(shades[i] <= 0.33 && ndvis[i] > 0.33){
      //   color = Color.fromRGBO(204, 232, 139, 255);
      // }
      // else{
      //   color = Color.fromRGBO(243, 115, 0, 255);
      // }

      color = Colors.blue; //Test

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

      polylines: _drawPoints(linePoints, shadeSegments, ndviSegments),
    );
  }
}
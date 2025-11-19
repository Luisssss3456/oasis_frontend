// Source: https://medium.com/@developerimad70/mastering-flutter-map-a-practical-guide-part-1-e353fabf30ae

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController mapController = MapController();


  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: const LatLng(18.3974229, -66.050111),
        initialZoom: 13,
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://{s}.google.com/vt/lyrs=m,h&x={x}&y={y}&z={z}&hl=es-PR&gl=PR',
          subdomains: const ['mt0', 'mt1', 'mt2', 'mt3'],
          userAgentPackageName: 'com.example.oasis_frontend',
        ),
        CurrentLocationLayer(),
        PolylineLayer(polylines: 
        [
          Polyline(points: [
            LatLng(18.3974229, -66.050111), // Example 1
            LatLng(18.4974229, -66.050111)
          ],
          color: const Color.fromARGB(255, 1, 132, 255),
          strokeWidth: 6,
          ),
        ]
        ),
        const RichAttributionWidget(
          attributions: [
            TextSourceAttribution(
              'OpenStreetMap contributors',
              // onTap: () =>
              // launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
            ),
          ],
        ),
      ],
    );
  }
}
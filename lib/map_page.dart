// Sources: 
// https://medium.com/@developerimad70/mastering-flutter-map-a-practical-guide-part-1-e353fabf30ae
// https://medium.com/@111anilsahu/flutter-initstate-method-1aaddbf5d625
// https://fernandoptr.medium.com/how-to-get-users-current-location-address-in-flutter-geolocator-geocoding-be563ad6f66a#14f8
// https://api.flutter.dev/flutter/material/CircularProgressIndicator-class.html
// https://stackoverflow.com/questions/75177492/how-to-automatically-update-gps-coordinate-values-in-flutter-using-geolocator-pa

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController mapController = MapController();

  Position? _currentPosition;


  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getCurrentPosition();
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if(!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {   
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }


  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    await Geolocator.getCurrentPosition(
      locationSettings: locationSettings)
      .then((Position position) {
        setState(() => _currentPosition = position);
      }).catchError((e) {
        debugPrint(e);
      });

      // This is where the position updates with the device location
      _positionStream = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen((Position? position) {
        setState(() {
          _currentPosition = position;
        });
      });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // Application first loads to retrieve current location
    if(_currentPosition == null){
      return const Center(child: CircularProgressIndicator());
    }

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        //initialCenter: const LatLng(18.3974229, -66.050111),
        initialCenter: LatLng(
          _currentPosition!.latitude, 
          _currentPosition!.longitude
          ),
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
          // These are polyline constants I am trying out
          // Will be removed later
          Polyline(points: [
            LatLng(_currentPosition!.latitude, _currentPosition!.longitude), // Example 1
            LatLng(_currentPosition!.latitude + .02, _currentPosition!.longitude + .03),
            LatLng(_currentPosition!.latitude - .03, _currentPosition!.longitude + .05),
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
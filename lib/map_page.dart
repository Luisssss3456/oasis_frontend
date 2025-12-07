// Sources: 
// https://medium.com/@developerimad70/mastering-flutter-map-a-practical-guide-part-1-e353fabf30ae
// https://medium.com/@111anilsahu/flutter-initstate-method-1aaddbf5d625
// https://fernandoptr.medium.com/how-to-get-users-current-location-address-in-flutter-geolocator-geocoding-be563ad6f66a#14f8
// https://api.flutter.dev/flutter/material/CircularProgressIndicator-class.html
// https://stackoverflow.com/questions/75177492/how-to-automatically-update-gps-coordinate-values-in-flutter-using-geolocator-pa
// https://stackoverflow.com/questions/60600699/how-to-remove-a-specific-marker-from-google-maps-in-flutter
// https://docs.fleaflet.dev/layers/polyline-layer
// https://docs.fleaflet.dev/layers/marker-layer

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';

import 'package:oasis_frontend/request.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController mapController = MapController();

  Position? _currentPosition;

  List<Marker>? _pois;


  StreamSubscription<Position>? _positionStream;

  final Set<Marker> _markers = {};
  List<LatLng> _linePoints = [];

  bool _canShowClear = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getCurrentPosition();
    _getPOIs();
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

  Future<void> _centerCurrentLocation() async {
    if(_currentPosition != null){
        mapController.move(LatLng(_currentPosition!.latitude, _currentPosition!.longitude), 13);
    }
    else {
        CupertinoAlertDialog(
          title: Text("Error"),
          content: Text("Cannot find user location")
        );
    }
  }

  Future<void> _getPOIs() async {
    _pois = await fetchPOIs();
  } 

  @override
  void dispose() {
    // TODO: implement dispose
    _positionStream?.cancel();
    super.dispose();
  }

  void _addMarkerPressed(LatLng pos) {
    setState((){
      _markers.add(
        Marker(
          point: pos, 
          child: FlutterLogo(),
        ),
      );
      _canShowClear = true;
    });
  }

  Future<void> _drawLine(LatLng pos) async {
    _linePoints = await fetchPath(LatLng(_currentPosition!.latitude, _currentPosition!.longitude), pos);
  }

  void _clearMarker() {
    setState(() {
      _linePoints.clear();
      _markers.clear();
      _canShowClear = false;
    });
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
        onTap: (tapPosition, pos) {
            _markers.clear();
            _addMarkerPressed(pos);
            // _linePoints = [
            //   LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            //   pos];
            _drawLine(pos);
        },
      ),

      children: [
        TileLayer(
          urlTemplate:
              'https://{s}.google.com/vt/lyrs=m,h&x={x}&y={y}&z={z}&hl=es-PR&gl=PR',
          subdomains: const ['mt0', 'mt1', 'mt2', 'mt3'],
          userAgentPackageName: 'com.example.oasis_frontend',
        ),
        MarkerLayer(markers: _markers.toList()),
        CurrentLocationLayer(),
        MarkerLayer(markers: _pois!),
        Padding(
          padding: const EdgeInsets.only(top: 40),
          child: SearchAnchor(
            builder: (BuildContext context, SearchController controller) {
              return SearchBar(
                controller: controller,
                padding: const WidgetStatePropertyAll<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: 16.0),
                ),
                onTap: () {
                  controller.openView();
                },
                onChanged: (_) {
                  controller.openView();
                },
                leading: const Icon(Icons.search),
              );
            },
            suggestionsBuilder: (BuildContext context, SearchController controller) {
              return List<ListTile>.generate(5, (int index) {
                final String item = 'item $index';
                return ListTile(
                  title: Text(item),
                  onTap: () {
                    setState(() {
                      controller.closeView(item);
                    });
                  },
                );
              });
            }, 
          ),
        ),
        Positioned(
          left: 16,
          bottom: 16,
          child: TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.black,
            ),
            onPressed: _centerCurrentLocation, 
            child: Text('Center')
            ),
        ),
        if (_canShowClear)
          Positioned(
            left: 16,
            bottom: 66,
            child: 
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.black,
              ),
              onPressed: _clearMarker, 
              child: Text('Clear')
            ),
          ),
        // SHOULD INVESTIGATE FURTHER
        if (_linePoints.isNotEmpty)
          PolylineLayer(polylines: 
          [
            Polyline(
              points: _linePoints,
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
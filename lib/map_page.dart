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
import 'package:flutter/material.dart';
import 'ui/route.dart';
import 'ui/search.dart';
import "ui/bottom_action_bar.dart";
import "services/api.dart";


class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController mapController = MapController();

  Position? _currentPosition;
  StreamSubscription<Position>? _positionStream;
  List<LatLng> _route = [];


  List<Marker> _pois = [];


  final Set<Marker> _destination = {};

  bool _isLoading = false;
  bool _canShowClear = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getCurrentPosition();
    _getPOIs();
  }

// Location permitions
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

    setState(() {
      _isLoading = true;
    });

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

      setState(() {
        _isLoading = false;
      });
  }

  Future<void> _centerCurrentLocation() async {
    if(_currentPosition != null){
        mapController.move(LatLng(_currentPosition!.latitude, _currentPosition!.longitude), 18);
    }
    else {
        CupertinoAlertDialog(
          title: Text("Error"),
          content: Text("Cannot find user location")
        );
    }
  }

  Future<void> _getPOIs() async {
    setState(() {
      _isLoading = true;
    });

    List<Marker> pointsOfInterest = [];

    final responseData = await fetchPOIs();
    final features = responseData['features'] as List;
    for (var feature in features) {
      //String name = feature["properties"]["name"];
      double lat = feature["geometry"]["coordinates"][0];
      double long = feature["geometry"]["coordinates"][1];

      final IconData markerIcon;
      final MaterialColor markerColor;

      switch (feature["properties"]["category"]) {
        case "agua-potable":
          markerIcon = Icons.water_drop;
          markerColor = Colors.blue;
          break;
        
        case "refugio-climatico":
          markerIcon = Icons.sunny;
          markerColor = Colors.yellow;
          break;
        
        default:
          markerIcon = Icons.local_hospital;
          markerColor = Colors.red;
          break;
      }

      final poi = Marker(
        point: LatLng(lat, long),
        width: 40,
        height: 40,
        child: CircleAvatar(
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: 35.0,
            backgroundColor: markerColor,
            child: 
              Icon(markerIcon, color: Colors.white),
          ),
        )
      );
      
      pointsOfInterest.add(poi);
    }
    _pois = pointsOfInterest;

    setState(() {
      _isLoading = false;
    });
  } 

  @override
  void dispose() {
    // TODO: implement dispose
    _positionStream?.cancel();
    super.dispose();
  }

  void _setDestination(LatLng pos) {
    setState((){
      _destination.add(
        Marker(
          point: pos, 
          child: Icon(
            IconData(0xe3ac, fontFamily: 'MaterialIcons'), size: 40, color: Color.fromARGB(255,255,99,71),
            shadows: [Shadow(color: Colors.black, blurRadius: 15.0)]
            ),
        ),
      );
      _canShowClear = true;
    });
  }

  Future<void> _drawLine(LatLng pos) async {

    setState(() {
      _isLoading = true;
    });

    _route.clear();
    final responseData = await fetchRoute(LatLng(_currentPosition!.latitude, _currentPosition!.longitude), pos);
    final coordinates = responseData["route"]["points"]["coordinates"];     

    List<LatLng> polyline = coordinates.map<LatLng>((pair) {
      double lng = pair[0];
      double lat = pair[1];
      return LatLng(lat, lng);
    }).toList();

    _route = polyline;

    setState(() {
      _isLoading = false;
    });
  }

  void _clearMarker() {
    setState(() {
      _route.clear();
      _destination.clear();
      _canShowClear = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    if(_currentPosition == null || _pois.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if(_isLoading){
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
        initialZoom: 15,
        onTap: (tapPosition, pos) {
            _destination.clear();
            _setDestination(pos);
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
        CurrentLocationLayer(
          style: LocationMarkerStyle(
           headingSectorColor: Color.fromARGB(255, 65,105,225),
            showAccuracyCircle: true,
            accuracyCircleColor: Color.fromARGB(255,255,99,71)
          ),
        ),
        SearchWidget(
          onItemSelected: (String item) {
            setState(() {
              //TODO: Implement search thigns
            });
          },
        ),
        BottomActionBar(
          onCenter: _centerCurrentLocation,
          onClear: _clearMarker,
          showClear: _canShowClear,
        ),
        if (_route.isNotEmpty) 
          RouteLayerWidget(
            linePoints: _route,
          ),
        MarkerLayer(markers: _destination.toList()),
        MarkerLayer(markers: _pois!),


        // const RichAttributionWidget(
        //   alignment: AttributionAlignment.bottomLeft,
        //   attributions: [
        //     TextSourceAttribution(
        //       'OpenStreetMap contributors',
        //     ),
        //   ],
        // ),
      ],
    );
  }
}
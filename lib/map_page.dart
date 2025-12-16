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
import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:oasis_frontend/ui/confirm_dialog.dart';
import 'package:oasis_frontend/ui/right_panel.dart';
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
  Map<String, List<dynamic>> _poiCoords = {};

  List<String> _poiNames = [];


  final Set<Marker> _destination = {};

  bool _isLoading = false;
  bool _canShowClear = false;

  double _shadeValue = 0;
  double _ndviValue = 0;

  List<dynamic> _shadeSegments = [];
  List<dynamic> _ndviSegments = [];

  List<Color> _colorSet = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getCurrentPosition();
    _getPOIs();
    //_getPOINames();
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

  Future<void> _zoomIn() async{
    mapController.move(mapController.camera.center, mapController.camera.zoom + 1);
  }

  Future<void> _zoomOut() async{
    mapController.move(mapController.camera.center, mapController.camera.zoom - 1);
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

      String name = feature["properties"]["name"];
      double lat = feature["geometry"]["coordinates"][0];
      double long = feature["geometry"]["coordinates"][1];

      _poiNames.add(name);

      _poiCoords.addAll({name: [lat, long]});

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

  LatLng _getPOICoords(String pointName) {

    if (_poiCoords.containsKey(pointName)) {
      return LatLng(_poiCoords[pointName]![0], _poiCoords[pointName]![1]);
    }

    return LatLng(0, 0);
  }

  Future<void> _drawSelectedItem(String pointName) async {
    // El auxilio mutuo sin funciona
    _destination.clear();
    LatLng points = _getPOICoords(pointName);
    _setDestination(points);
    _drawLine(points);
  }

  void _setDestination(LatLng pos) {
    setState((){
      _destination.add(
        Marker(
          point: pos, 

          child: Icon(
            Icons.place,
            size: 36,
            color: const Color.fromARGB(255, 11, 78, 13)
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
  

    final coordinates;

    try {
        coordinates = responseData["route"]["points"]["coordinates"];
    } catch(e) {
      _clearMarker();
      _routeAlert();
      setState(() {
        _isLoading = false;
      });
      return;
    }

      List <LatLng> polyline = coordinates.map<LatLng>((pair) {
        double lng = pair[0].toDouble();
        double lat = pair[1].toDouble();
        return LatLng(lat, lng);
      }).toList();

    _route = polyline;

    _shadeValue = responseData["route"]["shade"];
    _ndviValue = responseData["route"]["ndvi"];

     _shadeSegments = responseData["route"]["shade_segment_list"] as List<dynamic>;
     _ndviSegments = responseData["route"]["ndvi_segment_list"] as List<dynamic>;

     setColors();

    setState(() {
      _isLoading = false;
    });
  }

  void setColors() {

    _colorSet.clear();

    Color color;

    for (var i = 0; i < _route.length - 1; i++){
      if(_shadeSegments[i] > 0.66 && _ndviSegments[i] > 0.66){
        color = Color.fromRGBO(90, 77, 164, 255);
      }
      else if(_shadeSegments[i] > 0.66 && _ndviSegments[i] > 0.33){
        color = Color.fromRGBO(205, 154, 204, 255);
      }
      else if(_shadeSegments[i] > 0.66 && _ndviSegments[i] <= 0.33){
        color = Color.fromRGBO(240, 4, 127, 255);
      }
      else if(_shadeSegments[i] > 0.33 && _ndviSegments[i] > 0.66){
        color = Color.fromRGBO(154, 201, 213, 255);
      }
      else if(_shadeSegments[i] > 0.33 && _ndviSegments[i] > 0.33){
        color = Color.fromRGBO(230, 230, 230, 255);
      }
      else if(_shadeSegments[i] > 0.33 && _ndviSegments[i] <= 0.33){
        color = Color.fromRGBO(254, 154, 166, 255);
      }
      else if(_shadeSegments[i] <= 0.33 && _ndviSegments[i] > 0.66){
        color = Color.fromRGBO(0, 136, 55, 255);
      }
      else if(_shadeSegments[i] <= 0.33 && _ndviSegments[i] > 0.33){
        color = Color.fromRGBO(204, 232, 139, 255);
      }
      else{
        color = Color.fromRGBO(243, 115, 0, 255);
      }

      _colorSet.add(color);
      
    }
  }

  void _clearMarker() {
    setState(() {
      _route.clear();
      _destination.clear();
      _canShowClear = false;
    });
  }

  Future<void> _routeAlert() async {
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text("Cannot process route"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Exit")
          )
        ]
      )
    );
  }

  @override
  Widget build(BuildContext context) {

    if(_currentPosition == null) {
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
        onTap: (tapPosition, pos) async {
          if (_route.isEmpty) {
            _destination.clear();
            _setDestination(pos);
            _drawLine(pos);
          }
          else {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (_) => const ConfirmDialog(
                title: "Change Route", 
                content: "Do you want to change route?",
                ),
            );
            if (confirm == true){
              _destination.clear();
              _setDestination(pos);
              _drawLine(pos);
          }
        }
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
        MarkerLayer(markers: _destination.toList()),
        MarkerLayer(markers: _pois),
        SearchWidget(
          itemList: _poiNames,
          onItemSelected: _drawSelectedItem,
        ),
        RightPanel(
          onZoomIn: _zoomIn, 
          onZoomOut: _zoomOut
        ),
        BottomActionBar(
          onCenter: _centerCurrentLocation,
          onClear: _clearMarker,
          showClear: _canShowClear,
          shadeValue: _shadeValue,
          ndviValue: _ndviValue,
        ),
        if (_route.isNotEmpty) 
          RouteLayerWidget(
            linePoints: _route,
            colors: _colorSet,
          ),
      ],
    );
  }
}
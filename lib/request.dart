// References:
// https://stackoverflow.com/questions/58377795/how-to-pass-headers-in-the-http-post-request-in-flutter
// https://stackoverflow.com/questions/50244416/how-to-pass-basic-auth-credentials-in-api-call-for-a-flutter-mobile-application
// https://docs.flutter.dev/cookbook/networking/send-data

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

import 'auth/secrets.dart';

String _retrieveCreds() {
  String username = secretUser;
  String password = secretPassword;
  return 'Basic ' + base64.encode(utf8.encode('$username:$password'));
}

Future<List<LatLng>> fetchPath(LatLng currLoc, LatLng destination) async {
    final url  = Uri.parse(urlRouting);
    
    final basicAuth = _retrieveCreds();

    final response = await http.post(
      url,
      headers: {
        'Content-Type': "application/json",
        'Authorization': basicAuth
      },
      body: jsonEncode({
        "origin": {
          "lat": currLoc.latitude,
          "lng": currLoc.longitude
          },
        "destination": {
          "lat": destination.latitude,
          "lng": destination.longitude
        }})
      );


    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      final coordinates = responseData["route"]["points"]["coordinates"];
      
      List<LatLng> polyline = coordinates.map<LatLng>((pair) {
        double lng = pair[0];
        double lat = pair[1];
        return LatLng(lat, lng);
      }).toList();

      return polyline;
    } else {
      print("Error: ${response.statusCode}");
      return [];
    }
}

Future<List<Marker>> fetchPOIs() async {

  List<Marker> pointsOfInterest = [];

  final url = Uri.parse(urlPOIs);

  final basicAuth = _retrieveCreds();

  final response = await http.get(

      url,
      headers: {
        'Content-Type': "application/json",
        'Authorization': basicAuth
      });

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

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
    }
    
    return pointsOfInterest;
}
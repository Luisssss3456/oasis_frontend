// References:
// https://stackoverflow.com/questions/58377795/how-to-pass-headers-in-the-http-post-request-in-flutter
// https://stackoverflow.com/questions/50244416/how-to-pass-basic-auth-credentials-in-api-call-for-a-flutter-mobile-application
// https://docs.flutter.dev/cookbook/networking/send-data

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

import '../auth/secrets.dart';

String _retrieveCreds() {
  String username = secretUser;
  String password = secretPassword;
  return 'Basic ' + base64.encode(utf8.encode('$username:$password'));
}

Future<dynamic> fetchRoute(LatLng currentLocation, LatLng destination) async {
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
          "lat": currentLocation.latitude,
          "lng": currentLocation.longitude
          },
        "destination": {
          "lat": destination.latitude,
          "lng": destination.longitude
        }})
      );


    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData;
    } else {
      print("Error: ${response.statusCode}");
      return [];
    }
      
}

Future<dynamic> fetchPOIs() async {


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
      return responseData;
    }
}
// References:
// https://stackoverflow.com/questions/58377795/how-to-pass-headers-in-the-http-post-request-in-flutter
// https://stackoverflow.com/questions/50244416/how-to-pass-basic-auth-credentials-in-api-call-for-a-flutter-mobile-application
// https://docs.flutter.dev/cookbook/networking/send-data

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';

String _retrieveCreds() {
  String username = '';
  String password = '';
  return 'Basic ' + base64.encode(utf8.encode('$username:$password'));
}

Future<List<LatLng>> fetchPath(LatLng currLoc, LatLng destination) async {
    final url  = Uri.parse("");
    
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
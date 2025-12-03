// References:
// https://stackoverflow.com/questions/58377795/how-to-pass-headers-in-the-http-post-request-in-flutter
// https://stackoverflow.com/questions/50244416/how-to-pass-basic-auth-credentials-in-api-call-for-a-flutter-mobile-application
// https://docs.flutter.dev/cookbook/networking/send-data

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';

Future<List<LatLng>> fetchPath() async {
    final url  = Uri.parse("http://10.0.2.2:8000/routing/");
    
    String username = 'your-user';
    String password = 'your-password';
    String basicAuth = 
    'Basic ' + base64.encode(utf8.encode('$username:$password'));

    final response = await http.post(
      url,
      headers: {
        'Content-Type': "application/json",
        'Authorization': basicAuth
      },
      body: jsonEncode({
        "origin": {
          "lat": 18.404520310646078,
          "lng": -66.05455910070414
          },
        "destination": {
          "lat": 18.39823227684525,
          "lng": -66.04749513648974
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
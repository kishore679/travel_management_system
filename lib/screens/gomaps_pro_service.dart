import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class GoMapsProService {
  final String apiKey =
      'AlzaSyTltiQJ2Ocd8J4rQ_08m7YZ7Pg0j1nft4b'; // Replace with your GoMaps Pro API key
  final String baseUrl = 'https://maps.gomaps.pro/maps/api';

  Future<Map<String, dynamic>> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Location services are disabled.');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return {'latitude': position.latitude, 'longitude': position.longitude};
    } catch (e) {
      throw Exception('Error fetching current location: $e');
    }
  }

  Future<Map<String, dynamic>?> findPlaceFromText(String place) async {
    try {
      // Step 1: Call findplacefromtext to get the place_id
      final findPlaceResponse = await http.get(
        Uri.parse(
            '$baseUrl/place/findplacefromtext/json?input=${Uri.encodeComponent(place)}&inputtype=textquery&key=$apiKey'),
      );

      if (findPlaceResponse.statusCode == 200) {
        final findPlaceData = json.decode(findPlaceResponse.body);

        if (findPlaceData['status'] == 'OK' &&
            findPlaceData['candidates'] != null &&
            findPlaceData['candidates'].isNotEmpty) {
          final placeId = findPlaceData['candidates'][0]['place_id'];

          // Step 2: Call placedetails to get the geometry data
          final placeDetailsResponse = await http.get(
            Uri.parse(
                '$baseUrl/place/details/json?place_id=$placeId&key=$apiKey'),
          );

          if (placeDetailsResponse.statusCode == 200) {
            final placeDetailsData = json.decode(placeDetailsResponse.body);

            if (placeDetailsData['status'] == 'OK' &&
                placeDetailsData['result'] != null &&
                placeDetailsData['result']['geometry'] != null) {
              return {
                'lat': placeDetailsData['result']['geometry']['location']
                    ['lat'],
                'lng': placeDetailsData['result']['geometry']['location']
                    ['lng'],
                'place_id': placeId,
              };
            } else {
              throw Exception('Invalid geometry data in API response');
            }
          } else {
            throw Exception(
                'Failed to fetch place details: ${placeDetailsResponse.body}');
          }
        } else {
          throw Exception('No place found for input: $place');
        }
      } else {
        throw Exception(
            'Failed to fetch place details: ${findPlaceResponse.body}');
      }
    } catch (e) {
      throw Exception('Error fetching place details: $e');
    }
  }

  Future<Map<String, dynamic>> getNavigationDirections(
      String startLocation, String endLocation) async {
    try {
      final startPlace = await findPlaceFromText(startLocation);
      final endPlace = await findPlaceFromText(endLocation);

      if (startPlace == null || endPlace == null) {
        throw Exception('Failed to get location coordinates');
      }

      final response = await http.get(
        Uri.parse(
            '$baseUrl/directions/json?origin=${startPlace['lat']},${startPlace['lng']}&destination=${endPlace['lat']},${endPlace['lng']}&key=$apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return data;
        } else {
          throw Exception('Failed to fetch directions: ${data['status']}');
        }
      } else {
        throw Exception('Failed to fetch directions: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching navigation directions: $e');
    }
  }
}

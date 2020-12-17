// TODO: mettre en Helper

import 'dart:convert';

import 'package:http/http.dart';

// For storing our result
class Suggestion {
  final String placeId;
  final String description;

  Suggestion(this.placeId, this.description);

  @override
  String toString() {
    return 'Suggestion(description: $description, placeId: $placeId)';
  }
}

class PlaceOutput {
  final String address;
  final double lat;
  final double lng;

  PlaceOutput({this.address, this.lat, this.lng});
}

class PlaceApiProvider {
  final client = Client();

  final sessionToken;

  PlaceApiProvider(this.sessionToken);

  final apiKey = 'AIzaSyAbIexxkCVCCAQZA3_8Fl26qpsFuHIst88';

  Future<List<Suggestion>> fetchSuggestions(String input, String lang) async {
    final request =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&language=$lang&key=$apiKey&sessiontoken=$sessionToken';
    final response = await client.get(request);

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        // compose suggestions in a list
        return result['predictions']
            .map<Suggestion>((p) => Suggestion(p['place_id'], p['description']))
            .toList();
      }
      if (result['status'] == 'ZERO_RESULTS') {
        return [];
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }

  Future<PlaceOutput> getPlaceDetailFromId(String placeId) async {
    // if you want to get the details of the selected place by place_id
    final request =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=formatted_address,geometry&key=$apiKey&sessiontoken=$sessionToken';
    final response = await client.get(request);

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        final address = result['result']['formatted_address'] as String;
        final loc =
            result['result']['geometry']['location'] as Map<String, dynamic>;
        // build result
        final place = PlaceOutput(
          address: address,
          lat: loc['lat'] as double,
          lng: loc['lng'] as double,
        );

        return place;
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }
}

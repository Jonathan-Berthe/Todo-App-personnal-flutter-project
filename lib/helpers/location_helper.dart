import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;


const GOOGLE_API_KEY = 'AIzaSyAbIexxkCVCCAQZA3_8Fl26qpsFuHIst88';

class LocationHelper {
  static String generateLocationPreviewImage(
      {double latitude, double longitude}) {
    return "https://maps.googleapis.com/maps/api/staticmap?center=$latitude,$longitude&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%7C$latitude,$longitude&key=$GOOGLE_API_KEY";
  }


  static Future<String> getPlaceAddress(
      {double latitude, double longitude}) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$GOOGLE_API_KEY';

    try {
      final response = await http.get(url);
      if (response.statusCode != 200) throw HttpException('error');   
      return json.decode(response.body)['results'][0][
          'formatted_address'];
    } catch(e) {
      throw e;
    }
    
  }
}

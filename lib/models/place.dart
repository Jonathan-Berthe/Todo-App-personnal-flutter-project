import 'package:flutter/foundation.dart';

class PlaceLocation {
  final double latitude;
  final double longitude;
  final String address;
  final String name;

  const PlaceLocation({
    this.latitude,
    this.longitude,
    this.address = '',
    this.name = '',
  });
  
}


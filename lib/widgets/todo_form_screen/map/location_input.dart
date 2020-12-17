// TODO: Faire "synthese" du: errorBuild dans le Image.network, le check permission du geoLocator, le try catch d'internet pour avoir le nom de la place
// TODO: faire synthese de l'internet connection

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import '../../../helpers/location_helper.dart';
import '../../../screens/map_screen.dart';

import '../../../models/place.dart';

import 'package:connectivity/connectivity.dart';
import 'dart:async';
import 'package:flutter/services.dart';

//import '../screens/map_screen.dart';

class LocationInput extends StatefulWidget {
  final Function onSelectPlace;
  final PlaceLocation initLocation;
  final Function changeOccur;

  const LocationInput({this.onSelectPlace, this.initLocation, this.changeOccur});

  @override
  _LocationInputState createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  String _previewImageUrl;
  LatLng _selectedLocation;
  String _placeAdress;
  String _placeName;
  String _connectionStatus = 'Unknown';

  bool _withLoc = false;

  TextEditingController _controller;
  bool _showClearButton = false;

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(() {
      setState(() {
        _showClearButton = _controller.text.length > 0;
      });
    });
    KeyboardVisibility.onChange.listen((bool visible) {
      if (!visible) {
        Future.delayed(Duration(milliseconds: 300), () {
          _unFocus();
        });
      }
    });

    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    if (widget.initLocation != null) {
      double lat = widget.initLocation.latitude;
      double lng = widget.initLocation.longitude;
      _selectedLocation =
          (lat == null || lng == null) ? null : LatLng(lat, lng);
      _placeAdress = widget.initLocation.address;
      _placeName = widget.initLocation.name;
      _controller.text = _placeName;
      if (_selectedLocation != null)
        _previewImageUrl = LocationHelper.generateLocationPreviewImage(
          latitude: lat,
          longitude: lng,
        );
      _withLoc = true;
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
        setState(() => _connectionStatus = 'ok');
        break;
      case ConnectivityResult.mobile:
        setState(() => _connectionStatus = 'ok');
        break;
      case ConnectivityResult.none:
        setState(() => _connectionStatus = 'Unknown');
        break;
      default:
        setState(() => _connectionStatus = 'Unknown');
        break;
    }
  }

  void _unFocus() {
    if (context == null) return;
    FocusScopeNode currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  Widget _getClearButton() {
    // TODO: faire synthere la dessus
    if (!_showClearButton) {
      return null;
    }
    return IconButton(
      onPressed: () {
        _controller.clear();
      },
      icon: Icon(
        Icons.clear,
        size: 18,
      ),
    );
  }

  Future<void> _showPreview({
    double lat,
    double lng,
  }) async {
    if (lat == null || lng == null) {
      setState(() {
        _previewImageUrl = null;
        _selectedLocation = null;
        widget.onSelectPlace(null, null, '', _placeName);
      });
      return;
    }

    String tmp;

    try {
      tmp = await LocationHelper.getPlaceAddress(latitude: lat, longitude: lng);
    } on SocketException {
      final snackBar = SnackBar(
        content: Text(
            'Not possible to find the name of the place without internet connection'),
        duration: Duration(seconds: 2),
      );
      Scaffold.of(context).showSnackBar(snackBar);
    } on HttpException {
      final snackBar = SnackBar(
        content: Text('Error when retrieving the name of the place'),
        duration: Duration(seconds: 2),
      );
      Scaffold.of(context).showSnackBar(snackBar);
    }

    widget.onSelectPlace(lat, lng, tmp ?? '', _placeName ?? '');

    final staticMapImageUrl = LocationHelper.generateLocationPreviewImage(
      latitude: lat,
      longitude: lng,
    );

    setState(() {
      _previewImageUrl = staticMapImageUrl;
      _selectedLocation = LatLng(lat, lng);
      _placeAdress = tmp ?? '';
    });
  }

  Future<bool> _checkPermissions() async {
    bool isLocationServiceEnabled = await geo.isLocationServiceEnabled();

    if (!isLocationServiceEnabled) {
      final snackBar = SnackBar(
        content: Text('You have to enable location !'),
        duration: Duration(seconds: 2),
      );
      Scaffold.of(context).showSnackBar(snackBar);
      return false;
    }

    geo.LocationPermission permission = await geo.checkPermission();

    if (permission == geo.LocationPermission.deniedForever) {
      final snackBar = SnackBar(
        content: Text('You have to update the permission in the App settings'),
        duration: Duration(seconds: 2),
      );
      Scaffold.of(context).showSnackBar(snackBar);
      return false;
    } else if (permission == geo.LocationPermission.denied) {
      permission = await geo.requestPermission();
      if (permission == geo.LocationPermission.denied ||
          permission == geo.LocationPermission.deniedForever) {
        final snackBar = SnackBar(
          content: Text('You have accept if you want using this feature'),
          duration: Duration(seconds: 2),
        );
        Scaffold.of(context).showSnackBar(snackBar);
        return false;
      }
    }
    return true;
  }

  Future<void> _getCurrentUserLocation() async {
    bool permission = await _checkPermissions();
    if (!permission) return;
    geo.Position position = await geo.getCurrentPosition(
      desiredAccuracy: geo.LocationAccuracy.high,
    );
    _showPreview(lat: position.latitude, lng: position.longitude);
  }

  Future<void> _selectOnMap() async {
    final LatLng selectedLocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => MapScreen(
          isSelecting: true,
          initialLocation: _selectedLocation != null
              ? PlaceLocation(
                  latitude: _selectedLocation.latitude,
                  longitude: _selectedLocation.longitude,
                  address: _placeAdress)
              : null,
        ),
      ),
    );

    if (selectedLocation == null) {
      return;
    }
    _showPreview(
        lat: selectedLocation.latitude, lng: selectedLocation.longitude);
  }

  Widget _buildErrorConnectionWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          Icons.warning,
          size: 28,
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Center(
              child: Text(
                  'Error when loading the preview image, please check your internet connection.')),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          child: Row(
            children: <Widget>[
              if (_withLoc)
                InkWell(
                    child: Icon(Icons.settings_backup_restore),
                    onTap: () {
                      widget.onSelectPlace(null, null, '', '');
                      setState(() {
                        _previewImageUrl = null;
                        _selectedLocation = null;
                        _withLoc = false;
                        _placeName = '';
                        _placeAdress = '';
                      });
                    }),
              if (_withLoc) SizedBox(width: 10),
              Expanded(
                //constraints: BoxConstraints(maxWidth: 200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if ((_placeName == null || _placeName == '') &&
                        _selectedLocation == null)
                      Text(
                        'No place Chosen',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (_placeName != null && _placeName != '')
                      Text(
                        _placeName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (_selectedLocation != null &&
                        _placeAdress != '' &&
                        _placeAdress != null)
                      Text(
                        _placeAdress,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    if (_selectedLocation != null &&
                        _selectedLocation.latitude != null &&
                        _selectedLocation.longitude != null)
                      Text(
                        "(${_selectedLocation.latitude.toStringAsFixed(4)},${_selectedLocation.longitude.toStringAsFixed(4)})",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: 10),
              FlatButton(
                textColor: Theme.of(context).primaryColor,
                child: Text(
                  "Choose a place",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: _withLoc == true
                    ? null
                    : () {
                        setState(() {
                          _withLoc = true;
                        });
                      },
              ),
            ],
          ),
        ),
        if (_withLoc) ...[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width * 0.75,
                child: TextField(
                  controller: _controller,
                  onSubmitted: (value) {
                    setState(() {
                      _placeName = value;
                    });
                    widget.onSelectPlace(
                        _selectedLocation == null
                            ? null
                            : _selectedLocation.latitude,
                        _selectedLocation == null
                            ? null
                            : _selectedLocation.longitude,
                        _placeAdress,
                        _placeName);
                  },
                  decoration: InputDecoration(
                    hintText: 'ex: house',
                    labelText: 'Name of the place',
                    suffixIcon: _getClearButton(),
                  ),
                  onChanged: (_) {
                    widget.changeOccur();
                  },
                ),
              ),
              Expanded(
                child: SizedBox(),
              )
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            height: 170,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: Colors.grey,
              ),
            ),
            child: _previewImageUrl == null
                ? Text(
                    'No Location Choser',
                    textAlign: TextAlign.center,
                  )
                : (_connectionStatus == 'Unknown')
                    ? _buildErrorConnectionWidget()
                    : Image.network(
                        _previewImageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        errorBuilder: (BuildContext context, Object exception,
                            StackTrace stackTrace) {
                          return _buildErrorConnectionWidget();
                        },
                      ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: (MediaQuery.of(context).size.width - 35) * 0.4,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: FlatButton.icon(
                    onPressed: _getCurrentUserLocation,
                    icon: Icon(Icons.location_on),
                    label: Text('Current Location'),
                    textColor: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              Container(
                width: (MediaQuery.of(context).size.width - 35) * 0.4,
                child: FittedBox(
                  child: FlatButton.icon(
                    onPressed: _selectOnMap,
                    icon: Icon(Icons.map),
                    label: Text('Select on Map'),
                    textColor: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              if (_selectedLocation != null)
                InkWell(
                    child: Icon(
                      Icons.settings_backup_restore,
                      color: Theme.of(context).primaryColor,
                    ),
                    onTap: () {
                      _showPreview(lat: null, lng: null);
                    }),
            ],
          )
        ],
      ],
    );
  }
}

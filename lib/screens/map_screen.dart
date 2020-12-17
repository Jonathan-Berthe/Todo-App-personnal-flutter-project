

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:connectivity/connectivity.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:todo_marie/widgets/todo_form_screen/map/autocomplete_widget.dart';

import '../models/place.dart';

class MapScreen extends StatefulWidget {
  final PlaceLocation initialLocation;
  final bool isSelecting; // if 'false' we only show the map and not select

  const MapScreen(
      {this.initialLocation,
      this.isSelecting = false});
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng _pickedLocation;
  String _connectionStatus = 'Unknown';
  GoogleMapController _mapController;
  final LatLng initialDefaultLocation = LatLng(50.827995,4.409286);

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    if (widget.initialLocation != null) {
      _selectLocation(widget.initialLocation.latitude, widget.initialLocation.longitude);
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
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

  void _selectLocation(double lat, double lng, {fromOut = false}) {
    setState(() {
      _pickedLocation = LatLng(lat, lng);
    });
    if (fromOut){
      _mapController.moveCamera(CameraUpdate.newLatLng(_pickedLocation));
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenSize = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        kToolbarHeight -
        MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        actions: <Widget>[
          if (widget.isSelecting && _connectionStatus == 'ok')
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _pickedLocation == null
                  ? null
                  : () {
                      Navigator.of(context).pop(_pickedLocation);
                    },
            ),
        ],
      ),
      body: _connectionStatus == 'ok'
          ? Column(
              children: <Widget>[
                Expanded(
                    child: AutoCompleteWidget(
                  selectLocation: _selectLocation,
                  initAddress: (widget.initialLocation != null) ? widget.initialLocation.address : null,
                )),
                Container(
                  height: screenSize * 0.9,
                  child: GoogleMap(
                    onMapCreated: (controller){
                      _mapController = controller;
                    },
                    initialCameraPosition: CameraPosition(
                      target:widget.initialLocation == null ? initialDefaultLocation :  LatLng(widget.initialLocation.latitude,
                          widget.initialLocation.longitude),
                      zoom: 16,
                    ),
                    onTap: widget.isSelecting
                        ? (latLng) {
                            _selectLocation(latLng.latitude, latLng.longitude);
                          }
                        : null,
                    markers: (_pickedLocation == null && widget.isSelecting)
                        ? null
                        : {
                            Marker(
                              markerId: MarkerId('m1'),
                              position: _pickedLocation ??
                                  LatLng(widget.initialLocation.latitude,
                                      widget.initialLocation.longitude),
                            )
                          },
                  ),
                ),
              ],
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const <Widget>[
                  const Icon(
                    Icons.warning,
                    size: 30,
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    'Error',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const Text(
                    'No internet connection',
                    style: TextStyle(fontStyle: FontStyle.italic, fontSize: 20),
                  ),
                ],
              ),
            ),
    );
  }
}

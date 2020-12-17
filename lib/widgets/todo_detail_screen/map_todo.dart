import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:connectivity/connectivity.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:todo_marie/widgets/todo_form_screen/map/autocomplete_widget.dart';

import '../../models/place.dart';

class MapTodo extends StatefulWidget {
  final LatLng location;

  MapTodo({
    Key key,
    this.location,
  }) : super(key: key);

  @override
  _MapTodoState createState() => _MapTodoState();
}

class _MapTodoState extends State<MapTodo> {
  String _connectionStatus = 'Unknown';
  GoogleMapController _mapController;

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      height: 230,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Colors.grey,
        ),
      ),
      child: _connectionStatus == 'ok'
          ? GoogleMap(
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                new Factory<OneSequenceGestureRecognizer>(
                  () => new EagerGestureRecognizer(),
                ),
              ].toSet(),
              zoomGesturesEnabled: true,
              onMapCreated: (controller) {
                _mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: widget.location,
                zoom: 16,
              ),
              markers: (widget.location == null)
                  ? null
                  : {
                      Marker(
                        markerId: MarkerId('m1'),
                        position: widget.location,
                      )
                    },
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.warning,
                    size: 30,
                  ),
                  SizedBox(height: 25),
                  Text(
                    'Error',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Text(
                    'No internet connection',
                    style: TextStyle(fontStyle: FontStyle.italic, fontSize: 20),
                  ),
                ],
              ),
            ),
    );
  }
}

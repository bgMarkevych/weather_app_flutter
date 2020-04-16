import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meteoshipflutter/utils/colors.dart';

class MapsWidget extends StatefulWidget {
  CameraPosition _currentLocation;
  LatLng _currentCoordinates;

  MapsWidget(double _lat, double _lon) {
    _currentCoordinates = LatLng(_lat, _lon);
    _currentLocation = CameraPosition(
      target: _currentCoordinates,
      zoom: 10,
    );
  }

  @override
  _MapsWidgetState createState() => _MapsWidgetState();
}

class _MapsWidgetState extends State<MapsWidget> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};

  @override
  void initState() {
    _markers.add(_createMarker("current", widget._currentCoordinates));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        compassEnabled: false,
        myLocationButtonEnabled: false,
        onTap: (coordinates) {
          setState(() {
            widget._currentCoordinates = coordinates;
            _markers = {_createMarker(coordinates.toString(), coordinates)};
          });
        },
        markers: _markers,
        initialCameraPosition: widget._currentLocation,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: FloatingActionButton(
          onPressed: (){
            Navigator.pop(context, widget._currentCoordinates);
          },
          backgroundColor: sunnyColor,
          child: Icon(
            Icons.cached,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Marker _createMarker(String id, LatLng coordinates) {
    return Marker(
      markerId: MarkerId(id),
      position: coordinates,
    );
  }
}

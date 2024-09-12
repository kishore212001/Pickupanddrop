import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pickupanddropapp/GlobalComponents/GlobalPackages.dart';

import 'HomeScreen.dart';

class RidePage extends StatefulWidget {
  const RidePage({super.key});

  @override
  State<RidePage> createState() => _RidePageState();
}

class _RidePageState extends State<RidePage> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = <Marker>{};
  final Set<Polygon> _polygons = <Polygon>{};
  final Set<Polyline> _polylines = <Polyline>{};
  List<LatLng> polygonLatLngs = <LatLng>[];
  int _polylineIdCounter = 1;

  BitmapDescriptor? _destinationIcon; // Destination icon

  static const CameraPosition _initial = CameraPosition(
    target: LatLng(0, 0),
    zoom: 14,
  );

  @override
  void initState() {
    super.initState();
    _setMarker(const LatLng(0, 0), false);
    _loadCustomMarker();
    directions();
  }

  // Load the custom marker image
  void _loadCustomMarker() async {
    _destinationIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      'assets/Marker.png',
    );
    setState(() {});
  }

  void _setMarker(LatLng point, bool isDestination) {
    setState(() {
      _markers.add(
        Marker(
            markerId: MarkerId(isDestination ? 'destination' : 'origin'),
            position: point,
            icon: isDestination
                ? (_destinationIcon ??
                    BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed))
                : BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueViolet)),
      );
    });
  }

  void _setPolyline(List<PointLatLng> points) {
    _polylines.clear();
    final String polylineIdVal = 'polyline_$_polylineIdCounter';
    _polylineIdCounter++;
    _polylines.add(
      Polyline(
        polylineId: PolylineId(polylineIdVal),
        width: 2,
        color: Colors.blue,
        points: points
            .map(
              (point) => LatLng(point.latitude, point.longitude),
            )
            .toList(),
      ),
    );
  }

  Future<void> _goToPlace(double lat, double lng, Map<String, dynamic> boundsNe,
      Map<String, dynamic> boundsSw,
      {bool isDestination = false}) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 14),
      ),
    );
    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(boundsSw['lat'], boundsSw['lng']),
          northeast: LatLng(boundsNe['lat'], boundsNe['lng']),
        ),
        25,
      ),
    );

    _setMarker(LatLng(lat, lng), isDestination);
  }

  void directions() async {
    var directions = await LocationService().getDirections(
      GlobalFunction.Origin,
      GlobalFunction.destination,
    );
    _goToPlace(
      directions['start_location']['lat'],
      directions['start_location']['lng'],
      directions['bounds_ne'],
      directions['bounds_sw'],
    );

    _goToPlace(
      directions['end_location']['lat'],
      directions['end_location']['lng'],
      directions['bounds_ne'],
      directions['bounds_sw'],
      isDestination: true,
    );

    _setPolyline(directions['polyline_decoded']);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF19427C),
          automaticallyImplyLeading: false,
          title: const Text(
            'Route Map',
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HomeScreen()));
              },
              child: const Text(
                'End Trip',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: GoogleMap(
                mapType: MapType.normal,
                markers: _markers,
                polylines: _polylines,
                initialCameraPosition: _initial,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

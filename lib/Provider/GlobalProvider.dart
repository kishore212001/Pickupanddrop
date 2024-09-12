import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class LocationService with ChangeNotifier {
  final String key = 'your api key';
  String distance = '';
  Marker? originMarker; // Store the origin marker
  Marker? destinationMarker; // Store the destination marker
  Marker? currentlocationMarker;
  late Completer<GoogleMapController> googleMapController = Completer();
  CameraPosition? cameraPosition;
  Location? _location;
  LocationData? currentLocation;
  LatLng initialCameraPosition = const LatLng(0, 0);
  final Set<Marker> markers = <Marker>{};
  double totalcost = 0;
  int calculatedistance = 0;
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;

  Future<void> addCustomIcon() async {
    markers.clear();
    final icon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      "assets/Marker.png",
    );
    markerIcon = icon;
    notifyListeners();
  }

//===============================Marker=========================//

  void setMarker(LatLng point, String markerId) {
    if (markerId == 'currentlocationMarker') {
      markers.clear();
      originMarker = Marker(
        markerId: const MarkerId('currentlocationMarker'),
        position: point,
        icon: BitmapDescriptor.defaultMarker,
      );
      markers.add(originMarker!);
    } else if (markerId == 'origin') {
      markers.clear();
      originMarker = Marker(
        markerId: const MarkerId('origin'),
        position: point,
        icon: BitmapDescriptor.defaultMarker,
        infoWindow: const InfoWindow(title: 'Origin'),
      );
      markers.add(originMarker!); // Add only the origin marker
    } else if (markerId == 'destination') {
      // Keep the origin marker if set, and add the destination marker
      markers.removeWhere((m) =>
          m.markerId.value ==
          'destination'); // Remove old destination marker if exists
      destinationMarker = Marker(
        markerId: const MarkerId('destination'),
        position: point,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        infoWindow: const InfoWindow(title: 'Destination'),
      );
      markers.add(destinationMarker!);

      if (originMarker != null) {
        markers.add(originMarker!); // Keep origin marker if already set
      }
    }
  }

//===============================Location=========================//
  init() async {
    _location = Location();
    cameraPosition = const CameraPosition(
        target: LatLng(
            0, 0), // this is just the example lat and lng for initializing
        zoom: 15);
    _initLocation();
  }

  _initLocation() {
    _location?.getLocation().then((location) {
      currentLocation = location;
      initialCameraPosition = LatLng(
        currentLocation?.latitude ?? 0,
        currentLocation?.longitude ?? 0,
      );
      setMarker(initialCameraPosition, 'currentlocationMarker');
      notifyListeners();
    });
  }

//----------------------------------------------------------------------------//

  //============================GetDirections=================================//
  Future<Map<String, dynamic>> getDirections(
      String origin, String destination) async {
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$key';

    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var results = {
      'bounds_ne': json['routes'][0]['bounds']['northeast'],
      'bounds_sw': json['routes'][0]['bounds']['southwest'],
      'start_location': json['routes'][0]['legs'][0]['start_location'],
      'end_location': json['routes'][0]['legs'][0]['end_location'],
      'polyline': json['routes'][0]['overview_polyline']['points'],
      'polyline_decoded': PolylinePoints()
          .decodePolyline(json['routes'][0]['overview_polyline']['points']),
    };
    print(results);
    notifyListeners();
    return results;
  }

//===================================CalculateDistance========================//
  Future<void> calculateDistance(String origin, String destination) async {
    var response = await http.get(
      Uri.parse(
        "https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$key",
      ),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var distanceText = data['routes'][0]['legs'][0]['distance']['text'];
      distance = ' $distanceText';
      calculatedistance = int.parse(distanceText.replaceAll(" km", ""));
      notifyListeners();
    }

    if (calculatedistance > 0 && calculatedistance <= 5) {
      totalcost = calculatedistance * 10;
      notifyListeners();
    } else if (calculatedistance > 5 && calculatedistance <= 10) {
      totalcost = calculatedistance * 45;
      notifyListeners();
    } else if (calculatedistance > 10) {
      totalcost = calculatedistance * 100;
      notifyListeners();
    } else {
      print('error');
    }
  }

  Future<void> goToPlace(
    double originLat,
    double originLng,
    double destinationLat,
    double destinationLng,
    Map<String, dynamic> boundsNe,
    Map<String, dynamic> boundsSw,
  ) async {
    final GoogleMapController controller = await googleMapController.future;

    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(destinationLat, destinationLng), zoom: 20),
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

    setMarker(
        LatLng(
          originLat,
          originLng,
        ),
        'origin');
    setMarker(LatLng(destinationLat, destinationLng), 'destination');
    notifyListeners();
  }

//===================================suggestions===================================//
  Future<List<dynamic>> getPlacePredictions(String input) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$key';

    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);

    var predictions = json['predictions'] as List;
    notifyListeners();
    return predictions;
  }
}

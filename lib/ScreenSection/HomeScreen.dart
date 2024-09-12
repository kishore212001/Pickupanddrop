import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pickupanddropapp/GlobalComponents/GlobalPackages.dart';
import 'package:pickupanddropapp/ScreenSection/RideHistory.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  //-------------------------------------------------------------------//
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final FocusNode _originFocusNode = FocusNode();
  final _destinationFocusNode = FocusNode();
//--------------------------------------------------------------------------//
  final Set<Polyline> _polylines = <Polyline>{};
  List<LatLng> polygonLatLngs = <LatLng>[];
  int _polylineIdCounter = 1;
  //---------------------------------------------------------------------//
  bool originenable = true;
//------------------------------------------------------------------------//
  List<dynamic> _originPredictions = [];
  List<dynamic> _destinationPredictions = [];

  @override
  void initState() {
    super.initState();
    LocationService locationService =
        Provider.of<LocationService>(context, listen: false);
    locationService.init();
    _originFocusNode.addListener(() {
      if (_originFocusNode.hasFocus) {
        _destinationFocusNode.unfocus();
      }
    });
    _destinationFocusNode.addListener(() {
      if (_destinationFocusNode.hasFocus) {
        _originFocusNode.unfocus();
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _originController.dispose();
    _originFocusNode.dispose();
    _destinationController.dispose();
    _destinationFocusNode.dispose();
  }

//----------------------------------------------------------------------//
  Future<void> _setPolyline(List<PointLatLng> points) async {
    _polylines.clear();
    final String polylineIdVal = 'polyline_$_polylineIdCounter';
    _polylineIdCounter++;

    _polylines.add(
      Polyline(
        polylineId: PolylineId(polylineIdVal),
        width: 2,
        color: Colors.blue,
        points: points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList(),
      ),
    );
  }

//-----------------------------------------------------------------------------//
  @override
  Widget build(BuildContext context) {
    LocationService locationService =
        Provider.of<LocationService>(context, listen: true);
    return Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: AppBar(
          automaticallyImplyLeading: true,
          iconTheme: const IconThemeData(
            color: Colors.white, // Change this to the desired color
          ),
          title: const Text(
            'Pickup&Drop',
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF19427C),
        ),
        drawer: Drawer(
            child: ListView(padding: EdgeInsets.zero, children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF19427C),
            ),
            child: Center(
              child: Text(
                'Welcome to the Pick&Drop app',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('History'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (builder) => const RideHistory()));
            },
          ),
        ])),
        body: locationService.initialCameraPosition != const LatLng(0, 0)
            ? Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white, // Border color
                        width: 2.0, // Border width
                      ),
                      borderRadius: BorderRadius.circular(
                          8.0), // Rounded corners (optional)
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _originController,
                                  onTap: () {},
                                  decoration: InputDecoration(
                                    hintText: 'Origin',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: const BorderSide(
                                        color: Colors.blue,
                                        width: 2.0,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: const BorderSide(
                                        color: Colors.blue,
                                        width: 2.0,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: const BorderSide(
                                        color: Colors.grey,
                                        width: 2.0,
                                      ),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    _getOriginPredictions(value);
                                    if (value.isNotEmpty) {
                                      setState(() {
                                        originenable =
                                            false; // Enable the second field
                                      });
                                    } else {
                                      setState(() {
                                        originenable =
                                            true; // Keep the second field disabled
                                      });
                                    }
                                  },
                                ),
                                _buildPredictionList(
                                    _originPredictions, _originController),
                                const SizedBox(
                                  height: 15,
                                ),
                                originenable
                                    ? Container()
                                    : TextFormField(
                                        controller: _destinationController,
                                        decoration: InputDecoration(
                                          hintText: 'Destination',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            borderSide: const BorderSide(
                                              color: Colors.blue,
                                              width: 2.0,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            borderSide: const BorderSide(
                                              color: Colors.blue,
                                              width: 2.0,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            borderSide: const BorderSide(
                                              color: Colors.grey,
                                              width: 2.0,
                                            ),
                                          ),
                                        ),
                                        onChanged: (value) {
                                          _getDestinationPredictions(value);
                                        },
                                      ),
                                _buildPredictionList(_destinationPredictions,
                                    _destinationController),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            GlobalFunction.hideKeyboard(context);
                            var directions =
                                await locationService.getDirections(
                              _originController.text,
                              _destinationController.text,
                            );
                            locationService.goToPlace(
                              directions['start_location']['lat'],
                              directions['start_location']['lng'],
                              directions['end_location']['lat'],
                              directions['end_location']['lng'],
                              directions['bounds_ne'],
                              directions['bounds_sw'],
                            );
                            await _setPolyline(directions['polyline_decoded']);
                            await locationService.calculateDistance(
                              _originController.text,
                              _destinationController.text,
                            );
                            _ShowBottomSheet(context);
                          },
                          icon: const Icon(
                            Icons.search,
                            size: 35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GoogleMap(
                      mapType: MapType.normal,
                      polylines: _polylines,
                      initialCameraPosition: CameraPosition(
                        target: locationService.initialCameraPosition,
                        zoom: 20.0,
                      ),
                      onMapCreated: (GoogleMapController controller) {
                        if (!locationService.googleMapController.isCompleted) {
                          locationService.googleMapController
                              .complete(controller);
                        } else {
                          locationService.googleMapController =
                              Completer(); // Reset Completer
                          locationService.googleMapController.complete(
                              controller); // Recomplete with the new controller
                        }
                      },
                      markers: locationService.markers,
                    ),
                  ),
                ],
              )
            : const Center(child: CircularProgressIndicator()));
  }

  //=================PlaceSuggestions=====================//

  Future<void> _getOriginPredictions(String input) async {
    if (input.isEmpty) {
      setState(() {
        _originPredictions = [];
      });
      return;
    }

    var predictions = await LocationService().getPlacePredictions(input);
    setState(() {
      _originPredictions = predictions;
    });
  }

  Future<void> _getDestinationPredictions(String input) async {
    if (input.isEmpty) {
      setState(() {
        _destinationPredictions = [];
      });
      return;
    }

    var predictions = await LocationService().getPlacePredictions(input);
    setState(() {
      _destinationPredictions = predictions;
    });
  }

  Widget _buildPredictionList(
      List<dynamic> predictions, TextEditingController controller) {
    return predictions.isNotEmpty
        ? Container(
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.blue, // Border color
                width: 2.0, // Border width
              ),
              borderRadius:
                  BorderRadius.circular(8.0), // Rounded corners (optional)
            ),
            child: ListView.builder(
              itemCount: predictions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(predictions[index]['description']),
                  onTap: () {
                    setState(() {
                      controller.text = predictions[index]['description'];
                      if (controller == _originController) {
                        _originPredictions = [];
                      } else {
                        _destinationPredictions = [];
                      }
                    });
                  },
                );
              },
            ),
          )
        : Container();
  }

  //==========================Bottomsheet=====================//

  void _ShowBottomSheet(BuildContext context) {
    showModalBottomSheet(
        //  backgroundColor: GlobalAppColor.WhiteColorCode,
        backgroundColor: Colors.blueGrey,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        )),
        context: context,
        builder: (_) {
          return SizedBox(
            height: 200,
            //color: Colors.blueGrey,
            child: Consumer<LocationService>(
              builder: (context, providervalue, Widget? child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Total Distance:',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          providervalue.distance,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'TotalCost:Rs.',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          providervalue.totalcost.toString(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          GlobalFunction.Origin = _originController.text.trim();
                          GlobalFunction.destination =
                              _destinationController.text.trim();
                        });

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (builder) => const Paymentscreen()),
                        ).then((_) {
                          Navigator.pop(context);
                          // Reset the HomeScreen state after returning from Paymentscreen
                          setState(() {
                            _originController.clear();
                            _destinationController.clear();
                            originenable = true;
                            _polylines.clear();
                          });
                        });
                      },
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        });
  }
}

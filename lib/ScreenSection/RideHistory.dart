import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class RideHistory extends StatefulWidget {
  const RideHistory({super.key});

  @override
  State<RideHistory> createState() => _RideHistoryState();
}

class _RideHistoryState extends State<RideHistory> {
  //--------------------------------------------------//
  final trip = Hive.box('trip');
  List<Map<String, dynamic>> _items = [];
  //-----------------------------------------------------//
  void _refereshhistory() {
    final data = trip.keys.map((key) {
      final item = trip.get(key);
      return {
        'keys': key,
        'orgin': item['orgin'],
        'destination': item['destination'],
        'totalcost': item['totalcost'],
        'distance': item['distance'],
      };
    }).toList();
    setState(() {
      _items = data.reversed.toList();
      print(_items.length);
    });
  }

//---------------------------------------------------------------------------//
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _refereshhistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Ride History',
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            color: Colors.white,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          backgroundColor: Color(0xFF19427C),
        ),
        body: ListView.builder(
          itemCount: _items.length,
          itemBuilder: (context, index) {
            print(_items.length);
            print('hi');
            final currentitem = _items[index];
            if (currentitem.isEmpty) {
              return Text('No History');
            } else {
              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text((index + 1).toString()),
                      Text('Orgin: ${currentitem['orgin']}'),
                      const SizedBox(
                        height: 5,
                      ),
                      Text('Destination: ${currentitem['destination']}'),
                      const SizedBox(
                        height: 5,
                      ),
                      Text('Distance: ${currentitem['distance']}'),
                      const SizedBox(
                        height: 5,
                      ),
                      Text('TotalCost: ${currentitem['totalcost']}'),
                    ],
                  ),
                  // subtitle:
                ),
              );
            }
          },
        ));
  }
}

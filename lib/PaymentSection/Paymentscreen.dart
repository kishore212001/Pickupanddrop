import 'package:flutter/material.dart';

import '../GlobalComponents/GlobalPackages.dart';
import '../ScreenSection/RidePage.dart';

class Paymentscreen extends StatefulWidget {
  const Paymentscreen({super.key});

  @override
  State<Paymentscreen> createState() => _PaymentscreenState();
}

class _PaymentscreenState extends State<Paymentscreen> {
  //------------------------------------------------------//
  final trip = Hive.box('trip');
  //-----------------------------------------------------------//
  Future<void> createitem(Map<String, dynamic> newiteam) async {
    await trip.add(newiteam);
    print(trip.length);
  }

  @override
  Widget build(BuildContext context) {
    LocationService locationService =
        Provider.of<LocationService>(context, listen: true);
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text(
          'Confirm',
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
        backgroundColor: const Color(0xFF19427C),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Note!!!',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 8,
            ),
            const Text(
              'Without paying the ride can start',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 15,
            ),
            TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Origin",
                hintStyle: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                    fontWeight: FontWeight.w400),
                floatingLabelStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
                hintText: GlobalFunction.Origin,
                labelStyle: const TextStyle(color: Colors.grey),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                errorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedErrorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Destination",
                hintStyle: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                    fontWeight: FontWeight.w400),
                floatingLabelStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
                hintText: GlobalFunction.destination,
                labelStyle: const TextStyle(color: Colors.grey),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                errorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedErrorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: "TotalDistance",
                hintStyle: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                    fontWeight: FontWeight.w400),
                floatingLabelStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
                hintText: locationService.distance,
                labelStyle: const TextStyle(color: Colors.grey),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                errorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedErrorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
            Consumer<LocationService>(
              builder: (context, providervalue, Widget? child) {
                return ElevatedButton(
                    onPressed: () {
                      Razorpay razorpay = Razorpay();
                      var options = {
                        'key': 'rzp_live_ILgsfZCZoFIKMb',
                        'amount': providervalue.totalcost * 100,
                        'name': 'Pick&Drop',
                        'description': 'Trip',
                        'retry': {'enabled': true, 'max_count': 1},
                        'send_sms_hash': true,
                        'prefill': {
                          'contact': '8888888888',
                          'email': 'tech@pickanddrop.com'
                        },
                        'external': {
                          'wallets': ['paytm']
                        }
                      };
                      razorpay.on(Razorpay.EVENT_PAYMENT_ERROR,
                          handlePaymentErrorResponse);
                      razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS,
                          handlePaymentSuccessResponse);
                      razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET,
                          handleExternalWalletSelected);
                      razorpay.open(options);
                    },
                    child: Text('Pay ${providervalue.totalcost}'));
              },
            ),
            const SizedBox(
              height: 15,
            ),
            ElevatedButton(
                onPressed: () {
                  createitem({
                    'orgin': GlobalFunction.Origin,
                    'destination': GlobalFunction.destination,
                    'totalcost': locationService.totalcost,
                    'distance': locationService.distance,
                  });
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (builder) => const RidePage()));
                },
                child: const Text('start the ride')),
          ],
        ),
      ),
    );
  }

//---------------------------------Handle RazerPay response------------------------//
  void handlePaymentErrorResponse(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('something went wrong'),
      duration: Duration(seconds: 2),
    ));
  }

  void handlePaymentSuccessResponse(PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Payment received successfully'),
      duration: Duration(seconds: 2),
    ));
  }

  void handleExternalWalletSelected(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('External Wallet selected'),
      duration: Duration(seconds: 2),
    ));
  }
}

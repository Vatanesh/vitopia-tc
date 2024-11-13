import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

void main() {
  runApp(const MaterialApp(home: Scanning(),
    debugShowCheckedModeBanner: false,
  ));
}

class Scanning extends StatefulWidget {
  const Scanning({Key? key}) : super(key: key);

  @override
  _ScanningState createState() => _ScanningState();
}

class _ScanningState extends State<Scanning> {
  FocusNode _scanidFocusNode = FocusNode();
  TextEditingController textController = TextEditingController();
  TextEditingController apiController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  String scanid = '';
  bool success = false;
  String url = ''; // Replace with your actual API endpoint
  Color col = Colors.transparent;

  Future<void> sendToApi(String scanid) async {
    try {
      final Map<String, dynamic> requestBody = {'scanid': scanid};
      final String requestBodyJson = jsonEncode(requestBody);

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: requestBodyJson,
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        setState(() {
          success = jsonResponse['message'] == "success" ? true : false;
        });
        print("API Response Flag: $success");
      } else {
        print("Error: ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    col = success ? Colors.green : Colors.red;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vitopia TC', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                Image.asset("assets/logo.png"),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                  onPressed: () {
                    scanBarcode();
                  },
                  child: const Text('Camera Scan', style: TextStyle(color: Colors.black)),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.green,
                  ),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        url = value;
                      });
                    },
                    controller: apiController,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    decoration: const InputDecoration(
                      hintText: '\t\t\tAPI',
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.blueAccent,
                  ),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        scanid = value;
                      });
                      if (scanid.length == 13) {
                        sendToApi(scanid);
                        _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                        _scanidFocusNode.unfocus();
                        textController.clear();
                      }
                    },
                    controller: textController,
                    focusNode: _scanidFocusNode,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    decoration: const InputDecoration(
                      hintText: '\t\tTap and Scan with barcode reader/enter manually',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black, // You can change the color
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Scroll down to see Camera Scan result',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 110),
                if (scanid.length == 13)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    height: success ? 0 : null,
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(20),
                      color: col,
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          success ? 'Valid' : 'Invalid',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 69,
                          ),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              scanid = ''; // Reset scanid
                              success = false; // Reset success
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black, // You can change the color
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Tap before next scan',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> scanBarcode() async {
    try {
      final String barcode = await FlutterBarcodeScanner.scanBarcode(
          "#000000", "Cancel", true, ScanMode.BARCODE);
      if (barcode != '-1') {
        setState(() {
          scanid = barcode;
          print('Scanned barcode: $scanid');
        });
      }
    } catch (e) {
      print(e);
    }
  }
}

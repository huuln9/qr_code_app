import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wifi_connector/wifi_connector.dart';

void main() => runApp(const MaterialApp(home: MyHome()));

class MyHome extends StatelessWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: const Icon(Icons.arrow_back),
          title: const Text('Quét mã QR')),
      body: const QRViewExample(),
    );
  }
}

class QRViewExample extends StatefulWidget {
  const QRViewExample({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Expanded(flex: 1, child: _buildQrView(context)),
          Expanded(
              child: Column(
            children: [
              const Padding(padding: EdgeInsets.all(18)),
              const SizedBox(
                  width: 220,
                  child: Text('Di chuyển Camera đến vùng chứa mã QR để quét',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: TextStyle(fontSize: 18))),
              const Padding(padding: EdgeInsets.all(18)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () async {
                      await controller?.pauseCamera();
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text('QUÉT ẢNH CÓ SẴN',
                          style: TextStyle(fontSize: 20)),
                    ),
                  ),
                ],
              ),
            ],
          ))
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 250.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          cutOutBottomOffset: -30,
          overlayColor: Colors.white,
          borderColor: Colors.blue,
          // borderRadius: 10,
          borderLength: 30,
          borderWidth: 5,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
      this.controller!.pauseCamera();

      String resultCode = result!.code ?? '';

      final splitted = resultCode.split(':');
      final splitted1 = resultCode.split(';');
      final splitted2 = splitted1[0].split(':');

      if (checkURL(resultCode)) {
        _showWebDialog();
      } else if (checkMessage(resultCode)) {
        _showMessageDialog(splitted);
      } else if (checkEmail(resultCode)) {
        _showEmailDialog(splitted1, splitted2);
      } else if (checkWifi(resultCode)) {
        _showWifiDialog(splitted1);
      } else {
        _showTextDialog();
      }
    });
  }

  bool checkURL(resultCode) {
    return Uri.tryParse(resultCode)?.hasAbsolutePath ?? false;
  }

  bool checkMessage(resultCode) {
    final splitted = resultCode.split(':');
    if (splitted.length == 3 &&
        splitted[0] == 'smsto' &&
        double.tryParse(splitted[1]) != null) {
      return true;
    }
    return false;
  }

  bool checkEmail(resultCode) {
    final splitted1 = resultCode.split(';');
    final splitted2 = splitted1[0].split(':');

    if (splitted2[0] == 'MATMSG' && regexEmail(splitted2[2])) {
      return true;
    }
    return false;
  }

  bool checkWifi(resultCode) {
    final splitted = resultCode.split(':');

    if (splitted[0] == 'WIFI') {
      return true;
    }
    return false;
  }

  Future<void> _showTextDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Văn bản'),
          content: Text('${result!.code}'),
          actions: <Widget>[
            TextButton(
              child: const Text('ĐÓNG'),
              onPressed: () {
                Navigator.of(context).pop();
                controller!.resumeCamera();
              },
            ),
            TextButton(
              child: const Text('SAO CHÉP'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: result!.code));
                Navigator.of(context).pop();
                controller!.resumeCamera();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showWebDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Trang web'),
          content: Text('${result!.code}'),
          actions: <Widget>[
            TextButton(
              child: const Text('ĐÓNG'),
              onPressed: () {
                Navigator.of(context).pop();
                controller!.resumeCamera();
              },
            ),
            TextButton(
              child: const Text('MỞ'),
              onPressed: () {
                _launchURL(result!.code);
                Navigator.of(context).pop();
                controller!.resumeCamera();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showMessageDialog(splitted) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tin nhắn'),
          content: Text('Nhắn tin cho ${splitted[1]}'),
          actions: <Widget>[
            TextButton(
              child: const Text('ĐÓNG'),
              onPressed: () {
                Navigator.of(context).pop();
                controller!.resumeCamera();
              },
            ),
            TextButton(
              child: const Text('ĐỒNG Ý'),
              onPressed: () {
                String message = splitted[2];
                List<String> recipents = [splitted[1]];

                _sendSMS(message, recipents);

                Navigator.of(context).pop();
                controller!.resumeCamera();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEmailDialog(splittede1, splittede2) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Email'),
          content: Text('Gửi mail tới ${splittede2[2]}'),
          actions: <Widget>[
            TextButton(
              child: const Text('ĐÓNG'),
              onPressed: () {
                Navigator.of(context).pop();
                controller!.resumeCamera();
              },
            ),
            TextButton(
              child: const Text('ĐỒNG Ý'),
              onPressed: () async {
                await _sendEmail(splittede1, splittede2);
                Navigator.of(context).pop();
                controller!.resumeCamera();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showWifiDialog(splitted1) async {
    final splitted2 = splitted1[1].split(':');
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Wifi'),
          content: Text('Kết nối tới wifi ${splitted2[1]}'),
          actions: <Widget>[
            TextButton(
              child: const Text('ĐÓNG'),
              onPressed: () {
                Navigator.of(context).pop();
                controller!.resumeCamera();
              },
            ),
            TextButton(
              child: const Text('ĐỒNG Ý'),
              onPressed: () async {
                await _connectWifi(splitted1);

                Navigator.of(context).pop();
                controller!.resumeCamera();
              },
            ),
          ],
        );
      },
    );
  }

  void _launchURL(url) async {
    if (!await launch(url)) throw 'Could not launch $url';
  }

  void _sendSMS(String message, List<String> recipents) async {
    String _result = await sendSMS(message: message, recipients: recipents)
        .catchError((onError) {
      // print(onError);
    });
    // print(_result);
  }

  Future<void> _sendEmail(splittede1, splittede2) async {
    final eBody = splittede1[2].split(':');
    final eSubject = splittede1[1].split(':');
    final Email email = Email(
      body: eBody[1],
      subject: eSubject[1],
      recipients: [splittede2[2]],
      attachmentPaths: [],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
    } catch (error) {
      // print("object");
    }
  }

  Future<void> _connectWifi(splitted1) async {
    final ssid = splitted1[1].split(':');
    final password = splitted1[2].split(':');
    await WifiConnector.connectToWifi(ssid: ssid[1], password: password[1]);
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  bool regexEmail(String em) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = RegExp(p);
    return regExp.hasMatch(em);
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

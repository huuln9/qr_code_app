import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_code_tools/qr_code_tools.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:rxdart/rxdart.dart';

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
  String? strResult;
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
                    onPressed: () {
                      controller?.pauseCamera();
                      _getQrByGallery();
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
      _exeQrCode(resultCode);
    });
  }

  void _getQrByGallery() {
    Stream.fromFuture(ImagePicker().pickImage(source: ImageSource.gallery))
        .flatMap((file) {
      // setState(() {
      // _qrcodeFile = file.path;
      // });
      return Stream.fromFuture(QrCodeToolsPlugin.decodeFrom(file?.path));
    }).listen((data) {
      setState(() {
        strResult = data;
      });
      _exeQrCode(strResult!);
    }).onError((error, stackTrace) {
      setState(() {
        strResult = '';
      });
      // print('${error.toString()}');
      _showNullDialog();
    });
  }

  void _exeQrCode(String resultCode) {
    final splitted = resultCode.split(':');

    if (_checkURL(resultCode)) {
      _showWebDialog(resultCode);
    } else if (_checkMessage(resultCode)) {
      _showMessageDialog(splitted);
    } else if (_checkPhone(resultCode)) {
      _showPhoneDialog(splitted);
    } else if (_checkEmail(resultCode)) {
      // split code
      final splitted1 = resultCode.split(';');
      var splitted = [];
      for (var e in splitted1) {
        final splitted2 = e.split(':');
        splitted = splitted..addAll(splitted2);
      }
      _showEmailDialog(splitted);
    } else if (_checkWifi(resultCode)) {
      // split code
      final splitted1 = resultCode.split(';');
      var splitted = [];
      for (var e in splitted1) {
        final splitted2 = e.split(':');
        splitted = splitted..addAll(splitted2);
      }
      _showWifiDialog(splitted);
    } else {
      _showTextDialog(resultCode);
    }
  }

  bool _checkURL(resultCode) {
    return Uri.tryParse(resultCode)?.hasAbsolutePath ?? false;
  }

  bool _checkMessage(resultCode) {
    final splitted = resultCode.split(':');
    if (splitted[0].toLowerCase() == 'smsto' &&
        double.tryParse(splitted[1]) != null) {
      return true;
    }
    return false;
  }

  bool _checkPhone(resultCode) {
    final splitted = resultCode.split(':');
    if (splitted[0].toLowerCase() == 'tel' &&
        double.tryParse(splitted[1]) != null) {
      return true;
    }
    return false;
  }

  bool _checkEmail(resultCode) {
    // split code
    final splitted1 = resultCode.split(';');
    var splitted = [];
    for (var e in splitted1) {
      final splitted2 = e.split(':');
      splitted = splitted..addAll(splitted2);
    }

    // find email index
    int emailIndex = 0;
    for (var i = 0; i < splitted.length; i++) {
      if (splitted[i].toLowerCase() == 'to') {
        emailIndex = i + 1;
      }
    }

    if (splitted[0].toLowerCase() == 'matmsg' &&
        regexEmail(splitted[emailIndex])) {
      return true;
    }
    return false;
  }

  bool _checkWifi(resultCode) {
    // split code
    final splitted1 = resultCode.split(';');
    var splitted = [];
    for (var e in splitted1) {
      final splitted2 = e.split(':');
      splitted = splitted..addAll(splitted2);
    }

    if (splitted[0].toLowerCase() == 'wifi') {
      return true;
    }
    return false;
  }

  Future<void> _showTextDialog(resultCode) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Văn bản'),
          content: Text('$resultCode'),
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
                Clipboard.setData(ClipboardData(text: resultCode));
                Navigator.of(context).pop();
                controller!.resumeCamera();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showWebDialog(resultCode) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Trang web'),
          content: Text('$resultCode'),
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
                _launchURL(resultCode);
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
    String message = splitted[2];
    List<String> recipents = [splitted[1]];
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tin nhắn'),
          content: Text('Nhắn tin cho ${recipents[0]}'),
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
                Navigator.of(context).pop();
                controller!.resumeCamera();
                _sendSMS(message, recipents);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPhoneDialog(splitted) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Điện thoại'),
          content: Text('Gọi đến số ${splitted[1]}'),
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
                _makeCall(splitted);
                Navigator.of(context).pop();
                controller!.resumeCamera();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEmailDialog(splitted) async {
    // find email index
    int emailIndex = 0;
    for (var i = 0; i < splitted.length; i++) {
      if (splitted[i].toLowerCase() == 'to') {
        emailIndex = i + 1;
      }
    }
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Email'),
          content: Text('Gửi mail tới ${splitted[emailIndex]}'),
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
                await _sendEmail(splitted, emailIndex);
                Navigator.of(context).pop();
                controller!.resumeCamera();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showWifiDialog(splitted) async {
    // find email index
    int ssidIndex = 0;
    for (var i = 0; i < splitted.length; i++) {
      if (splitted[i].toLowerCase() == 's') {
        ssidIndex = i + 1;
      }
    }
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Wifi'),
          content: Text('Kết nối tới wifi ${splitted[ssidIndex]}'),
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
                await _connectWifi(splitted, ssidIndex);
                Navigator.of(context).pop();
                controller!.resumeCamera();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showNullDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thông báo'),
          content: const Text('Không tìm thấy mã QR'),
          actions: <Widget>[
            TextButton(
              child: const Text('ĐÓNG'),
              onPressed: () {
                Navigator.of(context).pop();
                controller!.resumeCamera();
              },
            )
          ],
        );
      },
    );
  }

  void _launchURL(url) async {
    if (!await launch(url, forceWebView: true)) throw 'Could not launch $url';
  }

  void _sendSMS(String message, List<String> recipents) async {
    await sendSMS(message: message, recipients: recipents)
        .catchError((onError) {
      // print(onError);
    });
    // print(_result);
  }

  Future<void> _makeCall(splitted) async {
    final url = 'tel:${splitted[1]}';
    if (!await launch(url)) throw 'Could not launch $url';
  }

  Future<void> _sendEmail(splitted, emailIndex) async {
    // find subject & body index
    int subjectIndex = 0;
    int bodyIndex = 0;
    for (var i = 0; i < splitted.length; i++) {
      if (splitted[i].toLowerCase() == 'sub') {
        subjectIndex = i + 1;
      } else if (splitted[i].toLowerCase() == 'body') {
        bodyIndex = i + 1;
      }
    }
    final url =
        'mailto:${splitted[emailIndex]}?subject=${splitted[subjectIndex]}&body=${splitted[bodyIndex]}';
    if (!await launch(url)) throw 'Could not launch $url';
  }

  Future<void> _connectWifi(splitted, ssidIndex) async {
    // find password & security index
    int passwordIndex = 0;
    int securityIndex = 0;
    for (var i = 0; i < splitted.length; i++) {
      if (splitted[i].toLowerCase() == 'p') {
        passwordIndex = i + 1;
      } else if (splitted[i].toLowerCase() == 't') {
        securityIndex = i + 1;
      }
    }
    NetworkSecurity networkSecurity;
    switch (splitted[securityIndex]) {
      case 'WPA':
        networkSecurity = NetworkSecurity.WPA;
        break;
      case 'WEP':
        networkSecurity = NetworkSecurity.WEP;
        break;
      default:
        networkSecurity = NetworkSecurity.NONE;
        break;
    }
    WiFiForIoTPlugin.connect(
      splitted[ssidIndex],
      password: splitted[passwordIndex],
      joinOnce: true,
      security: networkSecurity,
      withInternet: true,
    );
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

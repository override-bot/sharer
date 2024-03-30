import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:sharer/core/data/models/host_model.dart';
import 'package:sharer/ui/shared/popup.dart';
import 'package:sharer/utils/router.dart';

import '../../core/services/device_info.dart';
import '../../core/viewmodels/server_viewmodel.dart';

class JoinConnection extends StatefulWidget {
  const JoinConnection({super.key});

  @override
  State<JoinConnection> createState() => _JoinConnectionState();
}

class _JoinConnectionState extends State<JoinConnection> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    final serverVm = Provider.of<ServerVm>(context);
    void _onQRViewCreated(QRViewController controller) async {
      this.controller = controller;
      String deviceName = await DeviceData().getDeviceName(context);
      controller.scannedDataStream.listen((scanData) {
        try {
          String data = scanData.code ?? "";
          HostModel _mod = HostModel.fromString(data);

          serverVm.setHostModel(_mod);
          print(_mod.port);
          serverVm.joinNetwork(_mod.ipAddress, _mod.port, deviceName, context);
          controller.dispose();
          RouteController().pop(context);
        } catch (e) {
          PopUp().showError(
              "Something went wrong. ensure you are both connected to the same network",
              context);
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Scan qr code",
          style: TextStyle(color: Colors.blue),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height / 3,
            width: MediaQuery.of(context).size.width,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

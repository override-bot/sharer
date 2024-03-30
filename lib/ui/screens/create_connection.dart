import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sharer/core/viewmodels/server_viewmodel.dart';

class CreateConnection extends StatefulWidget {
  const CreateConnection({super.key});

  @override
  State<CreateConnection> createState() => _CreateConnectionState();
}

class _CreateConnectionState extends State<CreateConnection> {
  @override
  Widget build(BuildContext context) {
    final serverVm = Provider.of<ServerVm>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Scan qr code",
          style: TextStyle(color: Colors.blue),
        ),
      ),
      body: Center(
        child: QrImageView(
          data: serverVm.hostModel!.encode(),
          version: QrVersions.auto,
          size: 200.0,
        ),
      ),
    );
  }
}

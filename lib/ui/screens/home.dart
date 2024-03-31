// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sharer/core/services/device_info.dart';
import 'package:sharer/ui/screens/create_connection.dart';
import 'package:sharer/ui/screens/file_view.dart';
import 'package:sharer/ui/screens/join_connection.dart';
import 'package:sharer/ui/shared/popup.dart';

import 'package:sharer/utils/router.dart';

import '../../core/viewmodels/file_viewmodel.dart';
import '../../core/viewmodels/server_viewmodel.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    final serverVm = Provider.of<ServerVm>(context);
    FileViewmodel _mediaViewmodel = Provider.of<FileViewmodel>(context);
    pickFiles() async {
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(type: FileType.any);

      if (result != null) {
        List<File> files = result.paths.map((path) => File(path!)).toList();
        files.forEach((element) {
          _mediaViewmodel.setSelectedItems(element);
        });
      } else {
        // User canceled the picker
      }
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Connection application",
            style: TextStyle(color: Colors.blue),
          ),
          actions: [
            serverVm.isClient == true || serverVm.isServing == true
                ? IconButton(
                    onPressed: () {
                      serverVm.closeSocket(serverVm.hostModel?.port);
                      _mediaViewmodel.clearItems();
                    },
                    icon: Icon(
                      Icons.phonelink_off,
                      color: Colors.blue,
                    ))
                : Container(),
            IconButton(
                onPressed: () {
                  pickFiles();
                },
                icon: Icon(Icons.file_open)),
            _mediaViewmodel.selectedItems.isNotEmpty &&
                    (serverVm.isClient == true || serverVm.isServing == true)
                ? IconButton(
                    onPressed: () {
                      serverVm.sendFile(_mediaViewmodel.selectedItems,
                          serverVm.hostModel!.port);
                    },
                    icon: Icon(Icons.send))
                : Container()
          ],
        ),
        body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(bottom: 30),
            child: serverVm.isClient == false && serverVm.isServing == false
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      FloatingActionButton(
                        heroTag: "join",
                        tooltip: "Join connection",
                        onPressed: () {
                          RouteController().push(context, JoinConnection());
                        },
                        backgroundColor: Colors.blue,
                        child: Icon(
                          Icons.qr_code_scanner,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                          width: 16), // Add some spacing between the buttons
                      FloatingActionButton(
                        heroTag: "create",
                        tooltip: "Create connection",
                        onPressed: () async {
                          try {
                            String deviceName =
                                await DeviceData().getDeviceName(context);
                            await serverVm.startServer(deviceName, context);

                            RouteController().push(context, CreateConnection());
                          } catch (e) {
                            PopUp().showError(e.toString(), context);
                          }
                        },
                        backgroundColor: Colors.blue,
                        child: Icon(
                          Icons.connect_without_contact,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                : DocumentList()
            // : Center(
            //     child: Text(serverVm.isServing
            //         ? 'Serving on ${serverVm.hostModel?.ipAddress}:${serverVm.hostModel?.port}'
            //         : serverVm.isClient
            //             ? 'Connected to ${serverVm.hostModel?.deviceName} on ${serverVm.hostModel?.ipAddress}:${serverVm.hostModel?.port}'
            //             : "")),
            ));
  }
}

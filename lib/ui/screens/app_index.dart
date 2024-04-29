// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sharer/ui/screens/connection_info.dart';
import 'package:sharer/ui/screens/enter_regNumber.dart';
import 'package:sharer/ui/screens/file_view.dart';
import 'package:sharer/ui/shared/popup.dart';

import '../../core/services/device_info.dart';
import '../../core/viewmodels/file_viewmodel.dart';
import '../../core/viewmodels/server_viewmodel.dart';
import '../../utils/colors.dart';
import '../../utils/router.dart';
import '../../utils/text_size.dart';
import 'create_connection.dart';
import 'join_connection.dart';
import 'progress_view.dart';

class AppIndex extends StatefulWidget {
  const AppIndex({super.key});

  @override
  AppIndexState createState() => AppIndexState();
}

class AppIndexState extends State<AppIndex> with WidgetsBindingObserver {
  int currentIndex = 0;
  int previousIndex = 0;
  final List<Widget> children = [
    DocumentList(),
    Container(),
    Container(),
    Container()
  ];
  @override
  void initState() {
    super.initState();
    requestStoragePermission();
  }

  Future<void> requestStoragePermission() async {
    // Request storage permission
    PermissionStatus status = await Permission.storage.request();
    if (status == PermissionStatus.granted) {
      // Permission granted
      print('Storage permission granted');
    } else {
      // Permission denied
      print('Storage permission denied');
    }
  }

  @override
  Widget build(BuildContext context) {
    FileViewmodel mediaViewmodel = Provider.of<FileViewmodel>(context);
    final ServerVm serverVm = Provider.of<ServerVm>(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: ceoPurple,
        onPressed: () {
          if (serverVm.isClient == false && serverVm.isServing == false) {
            RouteController().push(context, EnterRegNumber());
          } else {
            PopUp().showError("Connection already active", context);
          }
        },
        child: Icon(
          Icons.qr_code_scanner,
          color: ceoWhite,
        ),
      ),
      appBar: AppBar(
        backgroundColor: ceoPurple,
        elevation: 0.0,
        centerTitle: true,
        actions: [
          mediaViewmodel.selectedItems.isNotEmpty
              ? IconButton(
                  onPressed: () async {
                    if (mediaViewmodel.selectedItems.isNotEmpty &&
                        (serverVm.isClient == true ||
                            serverVm.isServing == true)) {
                      PopUp().showSuccess("Sending files", context);
                      await serverVm.sendFile(mediaViewmodel.selectedItems,
                          serverVm.hostModel!.port);
                      mediaViewmodel.clearItems();
                    } else {
                      PopUp().showError("No connection group yet", context);
                    }
                  },
                  icon: Icon(
                    Icons.send,
                    color: ceoWhite,
                  ))
              : Container(),
          Stack(
            children: [
              IconButton(
                icon: Icon(
                  Icons.offline_share_outlined,
                  color: ceoWhite,
                ),
                onPressed: () {
                  RouteController().push(context, SharingProgress());
                },
              ),
              if ((serverVm.downloads + serverVm.uploads).length > 0)
                Positioned(
                  right: 2,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      (serverVm.downloads + serverVm.uploads).length.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          )
        ],
        title: Column(
          children: [
            Text(
              'Fileshare',
              style:
                  TextStyle(fontSize: TextSize().h3(context), color: ceoWhite),
            ),
            serverVm.isServing == true
                ? GestureDetector(
                    onTap: () {
                      RouteController().push(context, ConnectionInfo());
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width / 2,
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: ceoWhite,
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 3,
                            backgroundColor: serverVm.participants == 0
                                ? Colors.grey
                                : Colors.green,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          serverVm.participants == 0
                              ? Text(
                                  'No members connected',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: TextSize().small(context),
                                      color: ceoBlack),
                                )
                              : Text(
                                  '${serverVm.participants} members connected',
                                  style: TextStyle(
                                      fontSize: TextSize().small(context),
                                      color: ceoBlack),
                                )
                        ],
                      ),
                    ))
                : serverVm.isClient == true
                    ? Container(
                        width: MediaQuery.of(context).size.width / 2,
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: ceoWhite,
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 3,
                              backgroundColor: Colors.green,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Connected to ${serverVm.hostModel?.deviceName}',
                              style: TextStyle(
                                  fontSize: TextSize().small(context),
                                  color: ceoBlack),
                            )
                          ],
                        ),
                      )
                    : Container()
          ],
        ),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: ceoWhite,
        ),
        child: Stack(
          children: [
            BottomNavigationBar(
              currentIndex: currentIndex,
              backgroundColor: ceoWhite,
              selectedItemColor: ceoPurple,
              unselectedItemColor: ceoPurple,
              showSelectedLabels: true,
              iconSize: TextSize().h2(context),
              selectedFontSize: TextSize().h3(context),
              unselectedFontSize: TextSize().h3(context),
              showUnselectedLabels: true,
              elevation: 5.0,
              type: BottomNavigationBarType.fixed,
              items: [
                _buildBottomNavigationBarItem(
                    Icons.file_copy_outlined, "File Manager"),
                _buildBottomNavigationBarItem(
                    serverVm.isServing == true || serverVm.isClient
                        ? Icons.cancel
                        : Icons.add_circle,
                    serverVm.isServing == true || serverVm.isClient
                        ? "Leave group"
                        : "Create group"),
                //   _buildBottomNavigationBarItem(Icons.downloa, "Join group"),
                _buildBottomNavigationBarItem(Icons.person_outline, "Profile"),
                _buildBottomNavigationBarItem(
                    Icons.settings_outlined, "Settings"),
              ],
              onTap: (val) async {
                if (val == 1) {
                  if (serverVm.isClient == true || serverVm.isServing == true) {
                    serverVm.clearProgress();
                    serverVm.closeSocket(serverVm.hostModel!.port);
                  } else {
                    try {
                      String deviceName =
                          await DeviceData().getDeviceName(context);
                      await serverVm.startServer(deviceName, context);

                      RouteController().push(context, CreateConnection());
                    } catch (e) {
                      PopUp().showError(
                          "Failed. Ensure you are connected to a network",
                          context);
                    }
                  }

                  //groupViewModel.removeGroup();
                } else {
                  onTabTapped(val);
                }
              },
            ),
            Positioned(
              left: currentIndex * (MediaQuery.of(context).size.width / 4),
              bottom: 0,
              child: Container(
                width: MediaQuery.of(context).size.width / 4,
                height: 3,
                color: ceoPurple, // Color of the line under active icon
              ),
            ),
          ],
        ),
      ),
      body: Container(
          color: greyOne,
          padding: EdgeInsets.all(10),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: children[currentIndex]),
    );
  }

  BottomNavigationBarItem _buildBottomNavigationBarItem(
    IconData icon,
    String label,
  ) {
    return BottomNavigationBarItem(
      label: label,
      icon: Icon(
        icon,
        size: 20,
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      previousIndex = currentIndex;
      currentIndex = index;
    });
  }
}

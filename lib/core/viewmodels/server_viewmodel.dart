import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sharer/core/data/models/attendance_model.dart';
import 'package:sharer/core/data/models/host_model.dart';
import 'package:sharer/core/services/device_info.dart';
import 'package:sharer/core/services/server.dart';
import 'package:sharer/ui/shared/popup.dart';
import 'package:sharer/utils/calculate_download_speed.dart';
import 'package:sharer/utils/format_bytes.dart';
import 'package:sharer/utils/router.dart';
import '../../utils/port_generator.dart';
import '../data/models/transfer_update.dart';

class ServerVm extends ChangeNotifier {
  final LocalNetworkServer _borrowedSocket = LocalNetworkServer();
  int _paricipant = 0;
  int get participants => _paricipant;
  upPart() {
    _paricipant++;
    notifyListeners();
  }

  redpart() {
    _paricipant--;
    notifyListeners();
  }

  Future<String> retrieveHotspotAddress() async {
    for (var interface in await NetworkInterface.list()) {
      for (var address in interface.addresses) {
        if (address.type == InternetAddressType.IPv4 &&
            !address.address.startsWith('127.')) {
          return address.address;
        }
      }
    }
    throw Exception('Address not found');
  }

  List<Attendance> _students = [];
  List<Attendance> get students => _students;
  void addStudent(Attendance current) {
    var index = _students.indexWhere((element) {
      return element.deviceId == current.deviceId;
    });
    if (index == -1) {
      _students.add(current);
    }
    notifyListeners();
  }

  Future startServer(deviceName, context) async {
    final wifiIP = await retrieveHotspotAddress();
    String? path = await DeviceData().getStorageDirectory();
    print(wifiIP);
    int port = generateRandomNumbers();
    try {
      bool soc = await _borrowedSocket.startSocket(
          onCloseSocket: () {
            PopUp().showError("A device disconnected from network", context);

            redpart();
          },
          maxConcurrentDownloads: 10,
          serverAddress: wifiIP,
          downloadPath: path,
          port: port,
          onConnect: (name, address, deviceId, regNumber) {
            addStudent(Attendance(deviceId: deviceId, regNumber: regNumber));
            upPart();
            print(_paricipant);
            PopUp().showSuccess("$regNumber has joined the network", context);
          },
          deleteOnError: false,
          transferUpdate: (transfer) {
            int speed = updateDownloadSpeed(transfer.count, transfer.startTime);
            TransferUpdate newUpdate = transfer;
            print(speed);
            newUpdate.updateSpeed(speed);
            updateDownloads(newUpdate);
            updateUploads(newUpdate);
            print('${formatBytes(speed)}/ ${formatBytes(transfer.total)}');
          },
          receiveString: (val) {});

      print(soc);
      HostModel _mod =
          HostModel(deviceName: deviceName, ipAddress: wifiIP, port: port);
      setHostModel(_mod);
      _isServing = true;
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  HostModel? _hostModel;
  HostModel? get hostModel => _hostModel;
  setHostModel(model) {
    _hostModel = model;
  }

  String? _regNo;
  String? get regNo => _regNo;
  setRegNo(number) {
    _regNo = number;
  }

  joinNetwork(String address, int port, deviceName, context, regNumber,
      deviceId) async {
    String path = await DeviceData().getStorageDirectory();

    try {
      bool soc = await _borrowedSocket.connectToSocket(
          regNumber: regNumber,
          deviceId: deviceId,
          onCloseSocket: () {
            PopUp().showError("Connection closed", context);
            closeSocket(port);
            _isClient = false;
            notifyListeners();
          },
          deviceName: deviceName,
          serverAddress: address,
          maxConcurrentDownloads: 10,
          port: port,
          deleteOnError: true,
          downloadPath: path,
          onConnect: (address) {
            PopUp().showSuccess("Connected to $address", context);
          },
          transferUpdate: (transfer) {
            int speed = updateDownloadSpeed(transfer.count, transfer.startTime);
            TransferUpdate newUpdate = transfer;
            print(speed);
            newUpdate.updateSpeed(speed);
            updateDownloads(newUpdate);
            updateUploads(newUpdate);
            print('${formatBytes(speed)}/ ${formatBytes(transfer.total)}');
          },
          receiveString: (req) {});
      if (soc == true) {
        _isClient = true;
        notifyListeners();
        return soc;
      } else {
        throw "Failed";
      }
    } catch (e) {
      throw e;
    }
  }

  closeSocket(port) {
    _borrowedSocket.closeSocket(port: port);
    _isClient = false;
    _isServing = false;
    notifyListeners();
  }

  Future sendFile(List<String> paths, int port) async {
    var update = await _borrowedSocket.sendFiletoSocket(paths, port);
    setUploads(update ?? []);

    return update;
  }

  bool _isServing = false;
  bool get isServing => _isServing;
  bool _isClient = false;
  bool get isClient => _isClient;

  //Listeners
  TransferUpdate? _transferUpdate;
  TransferUpdate? get transferUpdate => _transferUpdate;

  setTransferUpdate(update) {
    _transferUpdate = update;
    notifyListeners();
  }

  List<TransferUpdate> _canceled = [];
  List<TransferUpdate> get canceled => _canceled;
  addCanceled(TransferUpdate update) {
    _canceled.add(update);
    _uploads.remove(update);
    _downloads.remove(update);
    notifyListeners();
  }

  List<TransferUpdate> _uploads = [];
  List<TransferUpdate> get uploads {
    _uploads.sort((a, b) {
      if (a.completed == b.completed) {
        return 0;
      } else if (a.completed == true) {
        return -1;
      } else {
        return 1;
      }
    });
    return _uploads;
  }

  setUploads(List<TransferUpdate> upload) {
    _uploads.addAll(upload);
    notifyListeners();
  }

  clearProgress() {
    _uploads.clear();
    _downloads.clear();
    notifyListeners();
  }

  updateUploads(TransferUpdate updatedUpload) {
    if (updatedUpload.receiving == false) {
      final transferIndex =
          _uploads.indexWhere((transfer) => transfer.id == updatedUpload.id);
      if (transferIndex != -1) {
        uploads[transferIndex] = updatedUpload;
      } else {
        _uploads.add(updatedUpload);
      }
      if (transferUpdate?.completed == true &&
          transferUpdate?.failed == false) {}
      notifyListeners();
    }
  }

  List<TransferUpdate> _downloads = [];
  List<TransferUpdate> get downloads {
    _downloads.sort((a, b) {
      if (a.completed == b.completed) {
        return 0;
      } else if (a.completed == true) {
        return -1;
      } else {
        return 1;
      }
    });
    return _downloads;
  }

  updateDownloads(TransferUpdate updatedUpload) {
    if (updatedUpload.receiving == true) {
      final transferIndex =
          _downloads.indexWhere((transfer) => transfer.id == updatedUpload.id);
      if (transferIndex != -1) {
        downloads[transferIndex] = updatedUpload;
      } else {
        _downloads.add(updatedUpload);
      }
      if (transferUpdate?.completed == true &&
          transferUpdate?.failed == false) {}
      notifyListeners();
    }
  }
}

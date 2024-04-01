import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

import 'package:mime_type/mime_type.dart';
import 'package:sharer/utils/url_operations.dart';

import '../../utils/constants.dart';
import '../data/models/transfer_update.dart';

class LocalNetworkServer {
  int _maxDownloads = 2;

  final List<WebSocket?> _sockets = [];
  final List<DownloadQueueItem> _downloadQueueItems = [];
  final Dio _dio = Dio();
  bool _deleteOnError = false;
  String _ipAddress = '';
  HttpServer? _server;
  static void _doNothing() {}
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

  Future<bool> startSocket({
    required String serverAddress,
    required String downloadPath,
    required int port,
    int maxConcurrentDownloads = 2,
    bool deleteOnError = true,
    required void Function(String name, String address) onConnect,
    required void Function(TransferUpdate transfer) transferUpdate,
    required void Function(dynamic req) receiveString,
    void Function() onCloseSocket = _doNothing,
  }) async {
    if (serverAddress.isEmpty) return false;
    try {
      closeSocket();
      _maxDownloads = maxConcurrentDownloads;
      _deleteOnError = deleteOnError;
      serverAddress = serverAddress.replaceFirst("/", "");
      _ipAddress = serverAddress;
      HttpServer httpServer = await HttpServer.bind(
        serverAddress,
        port,
        shared: true,
      );
      httpServer.listen(
        (req) async {
          if (req.uri.path == '/ws') {
            WebSocket socketServer = await WebSocketTransformer.upgrade(req);
            _sockets.add(socketServer);
            socketServer.listen(
              (event) async {
                for (WebSocket? socket in _sockets) {
                  if (socket != null) {
                    socket.add(event);
                  }
                }
                if (event.toString().startsWith(fileTransferCode)) {
                  for (String msg in event.toString().split(groupSeparation)) {
                    UrlOperations urlOperations = UrlOperations(msg: msg);
                    String url = urlOperations.getUrl();
                    int size = urlOperations.getFileSize();
                    int id = urlOperations.getId();
                    String filename = await _setPathToSave(
                        urlOperations.getFileName(), downloadPath);
                    String path = "$downloadPath$filename";
                    CancelToken token = CancelToken();

                    transferUpdate(
                      TransferUpdate(
                        filename: filename,
                        path: path,
                        count: 0,
                        total: size,
                        completed: false,
                        failed: false,
                        receiving: true,
                        id: id,
                        cancelToken: token,
                      ),
                    );

                    _downloadQueueItems.add(
                      DownloadQueueItem(
                        url: url,
                        downloading: false,
                        id: id,
                        filename: filename,
                        path: path,
                        cancelToken: token,
                      ),
                    );
                  }
                } else {
                  receiveString(event
                      .toString()
                      .substring(event.toString().indexOf('@') + 1));
                }
              },
              cancelOnError: true,
              onDone: () {
                onCloseSocket();
                socketServer.close(port);

                _sockets
                    .removeWhere((e) => e == null ? true : e.closeCode == port);
              },
            );
            onConnect("${req.uri.queryParameters['deviceName']}",
                "${req.uri.queryParameters['ip']}:$port");
          } else if (req.uri.path == '/file' && req.uri.hasQuery) {
            handleFileRequest(req, transferUpdate);
          }
        },
        cancelOnError: true,
        onError: (error, stack) {},
        onDone: () {
          closeSocket();
        },
      );
      _server = httpServer;
      handlePendingDownloads(transferUpdate, downloadPath, port);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> connectToSocket({
    required String deviceName,
    required String serverAddress,
    required int port,
    int maxConcurrentDownloads = 2,
    bool deleteOnError = true,
    required String downloadPath,
    required void Function(String address) onConnect,
    required void Function(TransferUpdate transfer) transferUpdate,
    required void Function(dynamic req) receiveString,
    void Function() onCloseSocket = _doNothing,
  }) async {
    if (serverAddress.isEmpty) return false;
    try {
      closeSocket();
      _maxDownloads = maxConcurrentDownloads;
      _deleteOnError = deleteOnError;
      _ipAddress = (await retrieveHotspotAddress());

      if (serverAddress.isNotEmpty) {
        serverAddress = serverAddress.replaceFirst("/", "");
        HttpServer httpServer = await HttpServer.bind(
          _ipAddress,
          port,
          shared: true,
        );
        httpServer.listen(
          (req) async {
            if (req.uri.path == '/file' && req.uri.hasQuery) {
              handleFileRequest(req, transferUpdate);
            }
          },
          cancelOnError: true,
          onError: (error, stack) {},
          onDone: () {
            closeSocket();
          },
        );
        _server = httpServer;
        WebSocket socket = await WebSocket.connect(
            'ws://$serverAddress:$port/ws?&deviceName=$deviceName&ip=$_ipAddress');
        _sockets.add(socket);
        socket.listen(
          (event) async {
            if (event.toString().startsWith(fileTransferCode)) {
              for (String msg in event.toString().split(groupSeparation)) {
                UrlOperations urlOperations = UrlOperations(msg: msg);
                String url = urlOperations.getUrl();
                int size = urlOperations.getFileSize();
                if (!(url.startsWith("http://$_ipAddress:$port/"))) {
                  int id = urlOperations.getId();
                  String filename = await _setPathToSave(
                      urlOperations.getFileName(), downloadPath);
                  String path = "$downloadPath$filename";
                  CancelToken token = CancelToken();

                  transferUpdate(
                    TransferUpdate(
                      filename: filename,
                      path: path,
                      count: 0,
                      total: size,
                      completed: false,
                      failed: false,
                      receiving: true,
                      id: id,
                      cancelToken: token,
                    ),
                  );

                  _downloadQueueItems.add(
                    DownloadQueueItem(
                      url: url,
                      downloading: false,
                      id: id,
                      filename: filename,
                      path: path,
                      cancelToken: token,
                    ),
                  );
                }
              }
            } else if (event.toString().split("@").first !=
                _ipAddress.split(".").last) {
              receiveString(event
                  .toString()
                  .substring(event.toString().indexOf('@') + 1));
            }
          },
          cancelOnError: true,
          onDone: () {
            closeSocket();
            onCloseSocket();
          },
        );
        onConnect("$serverAddress:$port");
        handlePendingDownloads(transferUpdate, downloadPath, port);
        return true;
      } else {
        return false;
      }
    } catch (_) {
      return false;
    }
  }

  void handlePendingDownloads(void Function(TransferUpdate) transferUpdate,
      String downloadPath, int port) async {
    while (_server != null) {
      await Future.delayed(const Duration(seconds: 1));
      if (_downloadQueueItems.isNotEmpty) {
        if (_downloadQueueItems.where((i) => i.downloading == true).isEmpty) {
          if (_downloadQueueItems.length <= _maxDownloads) {
            List<Future> futures = [];

            for (int i = 0; i < _downloadQueueItems.length; i++) {
              _downloadQueueItems[i].downloading = true;
              futures.add(
                Future(
                  () async {
                    DownloadQueueItem download = _downloadQueueItems[i];
                    await downloadFile(
                      port: port,
                      url: download.url,
                      transferUpdate: transferUpdate,
                      downloadPath: downloadPath,
                      done: () {
                        _downloadQueueItems
                            .removeWhere((i) => i.id == download.id);
                      },
                      filename: download.filename,
                      id: download.id,
                      path: download.path,
                      token: download.cancelToken,
                    );
                    return true;
                  },
                ),
              );
            }

            await Future.wait(futures);
          } else {
            List<Future> futures = [];

            for (int i = 0; i < _maxDownloads; i++) {
              _downloadQueueItems[i].downloading = true;
              futures.add(
                Future(
                  () async {
                    DownloadQueueItem download = _downloadQueueItems[i];
                    await downloadFile(
                      port: port,
                      url: download.url,
                      transferUpdate: transferUpdate,
                      downloadPath: downloadPath,
                      done: () {
                        _downloadQueueItems
                            .removeWhere((i) => i.id == download.id);
                      },
                      filename: download.filename,
                      id: download.id,
                      path: download.path,
                      token: download.cancelToken,
                    );
                    return true;
                  },
                ),
              );
            }
            await Future.wait(futures);
          }
        }
      }
    }
  }

  Future handleFileRequest(
    HttpRequest req,
    void Function(TransferUpdate) transferUpdate,
  ) async {
    String cancel = req.uri.queryParameters['cancel'] ?? "";
    String path = (req.uri.queryParameters['path'] ?? "")
        .replaceAll(andSymbol, "&")
        .replaceAll(equalsSymbol, "=")
        .replaceAll(questionSymbol, "?");
    int id = int.tryParse(req.uri.queryParameters['id'] ?? "0") ?? 0;
    File? file;
    List m = (mime(path.split("/").last) ?? "text/plain").split("/");
    String filename = path.split("/").last;
    int count = 0;
    try {
      file = File(path);
      if (cancel == "true") {
        req.response
          ..write("cancelled")
          ..close();
        transferUpdate(
          TransferUpdate(
            filename: filename,
            path: path,
            count: count,
            total: await file.length(),
            completed: true,
            failed: true,
            receiving: false,
            id: id,
            cancelToken: null,
          ),
        );
        return;
      }
      if (path.isEmpty) {
        req.response
          ..addError(const HttpException("not found"))
          ..close();
        transferUpdate(
          TransferUpdate(
            filename: filename,
            path: path,
            count: count,
            total: await file.length(),
            completed: true,
            failed: true,
            receiving: false,
            id: id,
            cancelToken: null,
          ),
        );
      } else {
        req.response
          ..headers.contentType = ContentType(m.first, m.last)
          ..headers.contentLength = await file.length()
          ..addStream(
            trackFileStream(
              file: file,
              filename: filename,
              id: id,
              transferUpdate: transferUpdate,
              updateCount: (c) => count = c,
            ),
          ).whenComplete(() async {
            req.response.close();
            transferUpdate(
              TransferUpdate(
                filename: filename,
                path: path,
                count: count,
                total: file == null ? 0 : await file.length(),
                completed: true,
                failed: count == (file == null ? 0 : await file.length())
                    ? false
                    : true,
                receiving: false,
                id: id,
                cancelToken: null,
              ),
            );
          });
      }
    } catch (_) {
      req.response
        ..addError(const HttpException("not found"))
        ..close();
      transferUpdate(
        TransferUpdate(
          filename: filename,
          path: path,
          count: count,
          total: file == null ? 0 : await file.length(),
          completed: true,
          failed: true,
          receiving: false,
          id: id,
          cancelToken: null,
        ),
      );
    }
  }

  Stream<List<int>> trackFileStream({
    required File file,
    required String filename,
    required int id,
    required void Function(TransferUpdate) transferUpdate,
    required void Function(int) updateCount,
  }) async* {
    int total = await file.length();
    DateTime startTime = DateTime.now();
    int count = 0;
    await for (List<int> chip in file.openRead()) {
      count += (chip as Uint8List).lengthInBytes;
      updateCount(count);

      transferUpdate(
        TransferUpdate(
          filename: filename,
          path: file.path,
          count: count,
          total: total,
          completed: false,
          failed: false,
          startTime: startTime,
          receiving: false,
          id: id,
          cancelToken: null,
        ),
      );
      yield chip;
      if (count == total) break;
    }
  }

  Future downloadFile({
    required String url,
    required void Function(TransferUpdate) transferUpdate,
    required String downloadPath,
    required void Function() done,
    required String filename,
    required String path,
    required int id,
    required int port,
    required CancelToken token,
  }) async {
    if (url.startsWith("http://$_ipAddress:$port/")) {
      done();
      return;
    }
    if (token.isCancelled == true) {
      transferUpdate(
        TransferUpdate(
          filename: filename,
          path: path,
          count: 0,
          total: 0,
          completed: true,
          failed: true,
          receiving: true,
          id: id,
          cancelToken: token,
        ),
      );

      await _dio.getUri(Uri.parse("$url&cancel=true"));
      done();
      return;
    }
    int count = 0;
    int total = 0;
    DateTime startTime = DateTime.now();
    bool failed = false;
    try {
      _dio.download(
        "$url&cancel=false",
        path,
        deleteOnError: _deleteOnError,
        cancelToken: token,
        onReceiveProgress: (c, t) {
          count = c;
          total = t;
          transferUpdate(
            TransferUpdate(
              filename: filename,
              path: path,
              count: count,
              total: total,
              completed: false,
              failed: false,
              receiving: true,
              startTime: startTime,
              id: id,
              cancelToken: token,
            ),
          );
        },
      )
        ..onError((err, stack) async {
          failed = true;
          Future.delayed(
            const Duration(milliseconds: 500),
            () async {
              if (_deleteOnError == true) {
                if (await File(path).exists()) File(path).delete();
              }
            },
          );
          return Future.value(
              Response(requestOptions: RequestOptions(path: url)));
        })
        ..whenComplete(
          () {
            transferUpdate(
              TransferUpdate(
                filename: filename,
                path: path,
                count: count,
                total: total,
                completed: true,
                failed: failed,
                receiving: true,
                id: id,
                cancelToken: token,
              ),
            );
            done();
          },
        );
    } catch (_) {
      transferUpdate(
        TransferUpdate(
          filename: filename,
          path: path,
          count: count,
          total: total,
          completed: true,
          failed: true,
          receiving: true,
          id: id,
          cancelToken: token,
        ),
      );
      done();
    }
  }

  Future<String> _setPathToSave(String name, String path) async {
    try {
      if (!(await File(path + name).exists())) return name;
      int number = 1;
      int index = name.lastIndexOf(".");
      String ext = name.substring(index.isNegative ? name.length : index);
      while (true) {
        String newName = name.replaceFirst(ext, "($number)$ext");
        if (!(await File(path + newName).exists())) {
          await File(path + newName).create();
          return newName;
        }
        number++;
      }
    } catch (_) {
      return name;
    }
  }

  bool sendStringToSocket(String string) {
    try {
      for (WebSocket? socket in _sockets) {
        if (socket != null) {
          socket.add("${_ipAddress.split(".").last}@$string");
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<TransferUpdate>?> sendFiletoSocket(
      List<String> paths, int port) async {
    try {
      if (_ipAddress.isEmpty) return null;
      paths = paths.where((path) => (File(path).existsSync()) == true).toList();

      List<int> ids = [];
      for (var _ in paths) {
        ids.add(Random().nextInt(1000000000));
      }

      for (WebSocket? socket in _sockets) {
        if (socket != null) {
          String msg = '';
          for (int i = 0; i < paths.length; i++) {
            var size = await File(paths[i]).length();
            msg +=
                "$fileTransferCode$size${fileSizeSeperation}http://$_ipAddress:$port/file?path=${paths[i].replaceAll("&", andSymbol).replaceAll("=", equalsSymbol).replaceAll("?", questionSymbol)}&id=${ids[i]}";
            if (i < paths.length - 1) {
              msg += groupSeparation;
            }
          }
          socket.add(msg);
        }
      }

      List<TransferUpdate> updates = [];
      for (int i = 0; i < paths.length; i++) {
        String filename = paths[i].split("/").last;
        updates.add(
          TransferUpdate(
            filename: filename,
            path: paths[i],
            count: 0,
            total: await File(paths[i]).length(),
            completed: false,
            failed: false,
            receiving: false,
            id: ids[i],
            cancelToken: null,
          ),
        );
      }
      return updates;
    } catch (e) {
      return null;
    }
  }

  bool closeSocket({port}) {
    try {
      if (_server != null) _server?.close();
      for (WebSocket? socket in _sockets) {
        if (socket != null) {
          socket.close(port);
        }
      }
      _server = null;
      _sockets.clear();
      _downloadQueueItems.clear();
      _ipAddress = '';

      return true;
    } catch (_) {
      return false;
    }
  }
}

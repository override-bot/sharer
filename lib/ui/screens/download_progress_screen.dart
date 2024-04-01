// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:provider/provider.dart';
import 'package:sharer/core/viewmodels/file_viewmodel.dart';
import 'package:sharer/core/viewmodels/server_viewmodel.dart';

import '../../utils/colors.dart';
import '../../utils/format_bytes.dart';
import '../../utils/text_size.dart';

class DownloadsView extends StatefulWidget {
  const DownloadsView({super.key});

  @override
  State<DownloadsView> createState() => _DownloadsViewState();
}

class _DownloadsViewState extends State<DownloadsView> {
  @override
  Widget build(BuildContext context) {
    FileViewmodel mediaViewmodel = Provider.of<FileViewmodel>(context);
    final ServerVm socketViewmodel = Provider.of<ServerVm>(context);
    if (socketViewmodel.downloads.isNotEmpty) {
      return ListView.builder(
        itemCount: socketViewmodel.downloads.length,
        itemBuilder: (context, index) {
          if (socketViewmodel.downloads[index].completed == true) {
            return Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10), color: ceoWhite),
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(5),
              margin: EdgeInsets.all(10),
              child: Column(
                children: [
                  ListTile(
                    title: Container(
                        width: MediaQuery.of(context).size.width / 2,
                        child: Text(
                          socketViewmodel.downloads[index].filename,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: TextSize().p(context),
                              color: ceoBlack,
                              fontWeight: FontWeight.w500),
                        )),
                    subtitle: Text(
                      formatBytes(socketViewmodel.downloads[index].total),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: TextSize().h3(context),
                          color: ceoPurple,
                          fontWeight: FontWeight.w300),
                    ),
                    trailing: MaterialButton(
                      onPressed: () {
                        OpenFile.open(socketViewmodel.downloads[index].path);
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width / 6,
                        height: 40,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: ceoPurple),
                        ),
                        child: Text(
                          "open",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: TextSize().small(context),
                            color: ceoPurple,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            );
          } else if (socketViewmodel.downloads[index].failed == true) {
            return Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10), color: ceoWhite),
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(5),
              margin: EdgeInsets.all(10),
              child: Column(
                children: [
                  ListTile(
                    title: Container(
                        width: MediaQuery.of(context).size.width / 2,
                        child: Text(
                          socketViewmodel.downloads[index].filename,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: TextSize().h1(context),
                              color: ceoBlack,
                              fontWeight: FontWeight.w500),
                        )),
                    subtitle: Text(
                      "failed",
                      // overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: TextSize().h3(context),
                          color: ceoRed,
                          fontWeight: FontWeight.w300),
                    ),
                  )
                ],
              ),
            );
          } else if (socketViewmodel
                  .downloads[index].cancelToken?.isCancelled ==
              true) {
            return Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10), color: ceoWhite),
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(5),
              margin: EdgeInsets.all(10),
              child: Column(
                children: [
                  ListTile(
                    title: Container(
                        width: MediaQuery.of(context).size.width / 2,
                        child: Text(
                          socketViewmodel.downloads[index].filename,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: TextSize().h1(context),
                              color: ceoBlack,
                              fontWeight: FontWeight.w500),
                        )),
                    subtitle: Text(
                      "Canceled",
                      // overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: TextSize().h3(context),
                          color: ceoRed,
                          fontWeight: FontWeight.w300),
                    ),
                  )
                ],
              ),
            );
          } else {
            return Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10), color: ceoWhite),
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(5),
              margin: EdgeInsets.all(10),
              child: Column(
                children: [
                  ListTile(
                      title: Row(
                        children: [
                          Container(
                              width: MediaQuery.of(context).size.width / 3,
                              child: Text(
                                socketViewmodel.downloads[index].filename,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: TextSize().p(context),
                                    color: ceoBlack,
                                    fontWeight: FontWeight.w500),
                              )),
                          Expanded(child: Container()),
                          Text(
                            "${formatBytes(socketViewmodel.downloads[index].count)}/${formatBytes(socketViewmodel.downloads[index].total)}",
                            style: TextStyle(
                                fontSize: TextSize().small(context),
                                color: ceoPurple,
                                fontWeight: FontWeight.w300),
                          ),
                        ],
                      ),
                      subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LinearProgressIndicator(
                              color: ceoPurple,
                              value: socketViewmodel.downloads[index].count /
                                  socketViewmodel.downloads[index].total,
                            ),
                            Text(
                              "${formatBytes(socketViewmodel.downloads[index].speed)}/s",
                              style: TextStyle(
                                  fontSize: TextSize().small(context),
                                  color: ceoPurple,
                                  fontWeight: FontWeight.w300),
                            ),
                          ]),
                      trailing: IconButton(
                        onPressed: () {
                          socketViewmodel
                              .addCanceled(socketViewmodel.downloads[index]);
                        },
                        icon: Icon(
                          Icons.cancel_outlined,
                          color: ceoRed,
                        ),
                      ))
                ],
              ),
            );
          }
        },
      );
    } else {
      return Center(
          child: Text(
        "No downloads yet",
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontSize: TextSize().h1(context),
            color: ceoBlack,
            fontWeight: FontWeight.w500),
      ));
    }
  }
}

import 'package:flutter/material.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:provider/provider.dart';
import 'package:sharer/core/viewmodels/file_viewmodel.dart';
import 'package:sharer/core/viewmodels/server_viewmodel.dart';

import '../../utils/colors.dart';
import '../../utils/format_bytes.dart';
import '../../utils/text_size.dart';

class UploadsView extends StatefulWidget {
  const UploadsView({super.key});

  @override
  State<UploadsView> createState() => _UploadsViewState();
}

class _UploadsViewState extends State<UploadsView> {
  @override
  Widget build(BuildContext context) {
    FileViewmodel mediaViewmodel = Provider.of<FileViewmodel>(context);
    final ServerVm socketViewmodel = Provider.of<ServerVm>(context);
    if (socketViewmodel.uploads.isNotEmpty) {
      return ListView.builder(
        itemCount: socketViewmodel.uploads.length,
        itemBuilder: (context, index) {
          if (socketViewmodel.uploads[index].completed == true) {
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
                          socketViewmodel.uploads[index].filename,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: TextSize().h3(context),
                              color: ceoBlack,
                              fontWeight: FontWeight.w500),
                        )),
                    subtitle: Text(
                      formatBytes(socketViewmodel.uploads[index].total),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: TextSize().p(context),
                          color: ceoPurple,
                          fontWeight: FontWeight.w300),
                    ),
                    trailing: MaterialButton(
                      onPressed: () {
                        OpenFile.open(socketViewmodel.uploads[index].path);
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
          } else if (socketViewmodel.uploads[index].failed == true) {
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
                          socketViewmodel.uploads[index].filename,
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
          } else if (socketViewmodel.uploads[index].cancelToken?.isCancelled ==
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
                          socketViewmodel.uploads[index].filename,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: TextSize().h3(context),
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
                                socketViewmodel.uploads[index].filename,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: TextSize().p(context),
                                    color: ceoBlack,
                                    fontWeight: FontWeight.w500),
                              )),
                          Expanded(child: Container()),
                          Text(
                            "${formatBytes(socketViewmodel.uploads[index].count)}/${formatBytes(socketViewmodel.uploads[index].total)}",
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
                              value: socketViewmodel.uploads[index].count /
                                  socketViewmodel.uploads[index].total,
                            ),
                            Text(
                              "${formatBytes(socketViewmodel.uploads[index].speed)}/s",
                              style: TextStyle(
                                  fontSize: TextSize().small(context),
                                  color: ceoPurple,
                                  fontWeight: FontWeight.w300),
                            ),
                          ]),
                      trailing: IconButton(
                        onPressed: () {
                          socketViewmodel
                              .addCanceled(socketViewmodel.uploads[index]);
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
        "No uploads yet",
        // overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontSize: TextSize().h1(context),
            color: ceoBlack,
            fontWeight: FontWeight.w500),
      ));
    }
  }
}

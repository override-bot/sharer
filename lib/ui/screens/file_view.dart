// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sharer/core/viewmodels/file_viewmodel.dart';
import 'package:sharer/utils/colors.dart';
import 'package:sharer/utils/text_size.dart';

class DocumentList extends StatefulWidget {
  @override
  State<DocumentList> createState() => _DocumentListState();
}

class _DocumentListState extends State<DocumentList>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    FileViewmodel _mediaViewmodel = Provider.of<FileViewmodel>(context);
    pickFiles() async {
      FilePickerResult? result = await FilePicker.platform
          .pickFiles(type: FileType.any, allowMultiple: true);

      if (result != null) {
        List<File> files = result.paths.map((path) => File(path!)).toList();
        files.forEach((element) {
          _mediaViewmodel.setSelectedItems(element);
        });
      } else {
        // User canceled the picker
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Selected Files",
              style:
                  TextStyle(color: ceoPurple, fontSize: TextSize().h3(context)),
            ),
            Expanded(child: Container()),
            IconButton(
                onPressed: () {
                  pickFiles();
                },
                icon: Icon(
                  Icons.add,
                  color: ceoPurple,
                ))
          ],
        ),
        _mediaViewmodel.selectedItems.isNotEmpty
            ? Expanded(
                child: ListView.builder(
                itemCount: _mediaViewmodel.selectedItems.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                      color: ceoWhite,
                      padding: EdgeInsets.all(5),
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        trailing: GestureDetector(
                            onTap: () {
                              _mediaViewmodel.setSelectedItems(
                                  File(_mediaViewmodel.selectedItems[index]));
                            },
                            child: Icon(
                              Icons.remove,
                              color: ceoPurple,
                            )),
                        leading: Icon(Icons.insert_drive_file),
                        title: Text(_mediaViewmodel.selectedItems[index]
                            .split('/')
                            .last),
                      ));
                },
              ))
            : Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 2,
                child: Text(
                  "No File Selected",
                  style: TextStyle(
                      color: ceoPurple, fontSize: TextSize().p(context)),
                ),
              )
      ],
    );
  }
}

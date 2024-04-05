import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sharer/utils/text_size.dart';

import '../../core/viewmodels/server_viewmodel.dart';
import '../../utils/colors.dart';
import '../../utils/router.dart';
import 'create_connection.dart';

class ConnectionInfo extends StatefulWidget {
  const ConnectionInfo({super.key});

  @override
  State<ConnectionInfo> createState() => _ConnectionInfoState();
}

class _ConnectionInfoState extends State<ConnectionInfo> {
  @override
  Widget build(BuildContext context) {
    final serverVm = Provider.of<ServerVm>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Attendance",
          style: TextStyle(color: ceoPurple),
        ),
        actions: [
          IconButton(
              onPressed: () {
                if (serverVm.isServing == true) {
                  RouteController().push(context, CreateConnection());
                }
              },
              icon: Icon(
                Icons.qr_code,
                color: ceoPurple,
              ))
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: serverVm.students.isNotEmpty
            ? ListView.builder(
                itemCount: serverVm.students.length,
                itemBuilder: (context, index) {
                  return Text(
                    '${index + 1}. ${serverVm.students[index].regNumber}',
                    style: TextStyle(
                        color: ceoPurple, fontSize: TextSize().p(context)),
                  );
                })
            : Center(
                child: Text(
                  "No student has joined yet",
                  style: TextStyle(
                      color: ceoPurple, fontSize: TextSize().p(context)),
                ),
              ),
      ),
    );
  }
}

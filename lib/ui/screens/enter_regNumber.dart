// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sharer/ui/screens/join_connection.dart';
import 'package:sharer/ui/shared/button.dart';
import 'package:sharer/ui/shared/custom_textfield.dart';
import 'package:sharer/utils/reg_number_validator.dart';
import 'package:sharer/utils/router.dart';
import 'package:sharer/utils/text_size.dart';

import '../../core/viewmodels/server_viewmodel.dart';
import '../../utils/colors.dart';

class EnterRegNumber extends StatefulWidget {
  const EnterRegNumber({super.key});

  @override
  State<EnterRegNumber> createState() => _EnterRegNumberState();
}

class _EnterRegNumberState extends State<EnterRegNumber> {
  bool? isReg;
  TextEditingController regField = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final serverVm = Provider.of<ServerVm>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Attendance",
          style: TextStyle(color: ceoPurple),
        ),
      ),
      body: Container(
          width: MediaQuery.of(context).size.width / 1,
          height: MediaQuery.of(context).size.height / 1,
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width / 1.5,
              height: MediaQuery.of(context).size.height / 1.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Container()),
                  CustomTextField(
                    hintText: 'eg 2018/242772',
                    controller: regField,
                    labelText: "Enter reg number",
                    onChanged: (String val) {
                      if (regex.hasMatch(val) && val.length == 11) {
                        setState(() {
                          isReg = true;
                        });
                      } else {
                        setState(() {
                          isReg = false;
                        });
                      }
                    },
                    errorText:
                        isReg == true ? null : "enter correct reg number",
                    maxChar: 11,
                  ),
                  Expanded(child: Container()),
                  Text(
                    "Note",
                    style: TextStyle(
                        color: ceoPurple, fontSize: TextSize().h3(context)),
                  ),
                  Text(
                    "Ensure you are connected to the same network as the lecturer",
                    style: TextStyle(
                        color: ceoPurpleGrey, fontSize: TextSize().p(context)),
                  ),
                  Text(
                    "By joining this connection you have completed your attendance for this class",
                    style: TextStyle(
                        color: ceoPurpleGrey, fontSize: TextSize().p(context)),
                  ),
                  Text(
                    "Only the first reg number to join with this device will be recorded as valid attendance",
                    style: TextStyle(
                        color: ceoPurpleGrey, fontSize: TextSize().p(context)),
                  ),
                  Expanded(child: Container()),
                  LoadingButton(
                      label: "Join network",
                      isLoading: false,
                      onPressed: isReg == true
                          ? () {
                              serverVm.setRegNo(regField.text);
                              RouteController().push(context, JoinConnection());
                            }
                          : null)
                ],
              ),
            ),
          )),
    );
  }
}

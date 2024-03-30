import 'package:flutter/material.dart';

hideToast(BuildContext context) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
}

class PopUp {
  showError(message, context) {
    if (!context.mounted) return;
    hideToast(context);
    TextStyle? textStyle = const TextStyle(color: Colors.white);
    Color? backgroundColor;
    backgroundColor = Colors.red;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        showCloseIcon: true,
        backgroundColor: backgroundColor,
        content: Text(
          message,
          style: textStyle,
        ),
      ),
    );
  }

  showSuccess(message, context) async {
    if (!context.mounted) return;
    hideToast(context);
    TextStyle? textStyle = const TextStyle(color: Colors.white);
    Color? backgroundColor;
    backgroundColor = Colors.green;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        showCloseIcon: true,
        backgroundColor: backgroundColor,
        content: Text(
          message,
          style: textStyle,
        ),
      ),
    );
  }

  Future popLoad(context) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Container(
              margin: EdgeInsets.fromLTRB(30, 20, 30, 20),
              width: MediaQuery.of(context).size.width / 1.2,
              height: 100,
              child: Center(
                  child: CircularProgressIndicator(
                color: Color.fromARGB(255, 14, 140, 172),
              )),
            ),
          );
        });
  }
}

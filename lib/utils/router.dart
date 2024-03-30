import 'package:flutter/material.dart';

class RouteController {
  pushAndRemoveUntil(context, view) {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => view),
        (Route<dynamic> route) => false);
  }

  push(context, view) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => view));
  }

  void popUntil(BuildContext context, Widget view) {
    Navigator.of(context)
        .popUntil((route) => route.settings.name == view.toString());
  }

  pop(context) {
    Navigator.of(context).pop();
  }
}

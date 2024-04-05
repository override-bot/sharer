import 'package:flutter/material.dart';
import 'package:sharer/utils/colors.dart';

class LoadingButton extends StatefulWidget {
  final String? label;
  final bool? isLoading;
  final Function()? onPressed;
  const LoadingButton(
      {@required this.label,
      @required this.isLoading,
      @required this.onPressed});

  @override
  LoadingButtonState createState() => LoadingButtonState();
}

class LoadingButtonState extends State<LoadingButton> {
  @override
  Widget build(BuildContext context) {
    Color paint = Colors.white;
    return Container(
      width: MediaQuery.of(context).size.width / 2,
      height: 50,
      decoration: BoxDecoration(
          color: ceoPurple, borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 10, left: 20, right: 20),
      child: MaterialButton(
          onPressed: widget.onPressed,
          child: widget.isLoading == true
              ? const Center(
                  child: CircularProgressIndicator(
                  color: Colors.white,
                ))
              : Text(
                  widget.label ?? "",
                  style: TextStyle(
                      color: paint,
                      fontSize: 20.0,
                      fontWeight: FontWeight.w500),
                )),
    );
  }
}

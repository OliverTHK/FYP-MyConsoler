import 'package:flutter/material.dart';

class RoundedTextFieldContainer extends StatelessWidget {
  final Widget child;

  const RoundedTextFieldContainer({
    Key key,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        elevation: 10.0,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          width: size.width * 0.8,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
          ),
          child: child,
        ),
      ),
    );
  }
}

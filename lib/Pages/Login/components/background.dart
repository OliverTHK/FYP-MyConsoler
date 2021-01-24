import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Background extends StatelessWidget {
  final Widget child;
  const Background({
    Key key,
    @required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: size.height,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: SvgPicture.asset('assets/images/Login_C1.svg'),
            width: size.width * 1,
          ),
          Positioned(
            bottom: -170,
            right: 0,
            child: SvgPicture.asset('assets/images/Login_C2.svg'),
            width: size.width * 0.5,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: SvgPicture.asset('assets/images/Login_C3.svg'),
            width: size.width * 0.3,
          ),
          child,
        ],
      ),
    );
  }
}

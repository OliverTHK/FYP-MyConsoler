import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
      // Can add or customize the background in the future.
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 0,
            right: -200,
            child: SvgPicture.asset('assets/images/Signup_C1.svg'),
            width: size.width * 1,
          ),
          Positioned(
            top: -130,
            left: -100,
            child: SvgPicture.asset('assets/images/Signup_C2.svg'),
            width: size.width * 0.5,
          ),
          Positioned(
            bottom: -100,
            left: -200,
            child: SvgPicture.asset('assets/images/Login_C1.svg'),
            width: size.width * 1,
          ),
          child,
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:my_consoler/themes.dart';

class SignUpLink extends StatelessWidget {
  final Function press;

  const SignUpLink({
    Key key,
    this.press,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Don\'t have an account? ',
            style: TextStyle(color: kPrimaryColor),
          ),
          Text(
            'Sign Up',
            style: TextStyle(
              color: kPrimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

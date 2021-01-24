import 'dart:io';
import 'package:email_validator/email_validator.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_consoler/Pages/Login/components/background.dart';
import 'package:my_consoler/Services/auth.dart';
import 'package:my_consoler/components/animations/my_fade_in.dart';
import 'package:my_consoler/components/rounded_button.dart';
import 'package:my_consoler/Pages/Login/components/sign_up_link.dart';
import 'package:my_consoler/components/text_field_container.dart';
import 'package:my_consoler/themes.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final AuthService _auth = AuthService();

  String email, password;

  String error = '';

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /* --- For Password Use --- */
  bool _isHidden = true;

  void _toggleVisibility() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }
  /* --- For Password Use --- */

  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: FadingEdgeScrollView.fromSingleChildScrollView(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'MyConsoler',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  MyFadeIn(
                    child: Text(
                      '\"Covid-19 is tough.\nLet\'s get by together.\"',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.05,
                  ),
                  Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextFieldContainer(
                          child: TextFormField(
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              icon: Icon(
                                Icons.mail,
                                color: kPrimaryColor,
                              ),
                              hintText: 'Email',
                              hintStyle: TextStyle(color: Colors.black54),
                              border: InputBorder.none,
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (String value) {
                              if (value.isEmpty) {
                                return 'Email is required.';
                              }
                              if (!EmailValidator.validate(value)) {
                                return 'Email address is invalid.';
                              }
                              return null;
                            },
                            onSaved: (String value) {
                              email = value;
                            },
                          ),
                        ),
                        TextFieldContainer(
                          child: TextFormField(
                            style: TextStyle(color: Colors.black),
                            onChanged: (value) {},
                            autocorrect: false,
                            obscureText: _isHidden,
                            decoration: InputDecoration(
                              icon: Icon(
                                Icons.lock,
                                color: kPrimaryColor,
                              ),
                              suffixIcon: Material(
                                type: MaterialType.transparency,
                                child: IconButton(
                                  onPressed: _toggleVisibility,
                                  icon: _isHidden
                                      ? Icon(Icons.visibility_off)
                                      : Icon(Icons.visibility),
                                  color: kPrimaryColor,
                                  highlightColor: kPrimaryLightColor,
                                  splashColor: kPrimaryLightColor,
                                  tooltip: _isHidden
                                      ? 'Reveal password'
                                      : 'Hide password',
                                ),
                              ),
                              hintText: 'Password',
                              hintStyle: TextStyle(color: Colors.black54),
                              border: InputBorder.none,
                            ),
                            validator: (String value) {
                              if (value.isEmpty) {
                                return 'Password is required.';
                              } else if (value.length < 6) {
                                return 'Password characters < 6.';
                              }
                              return null;
                            },
                            onSaved: (String value) {
                              password = value;
                            },
                          ),
                        ),
                        RoundedButton(
                          text: 'Log In',
                          press: () async {
                            // if validation is unsuccessful
                            if (!formKey.currentState.validate()) {
                              return;
                            }
                            formKey.currentState.save();
                            // Remove this after testing
                            print(email);
                            print(password);
                            dynamic result =
                                await _auth.logInWithEmailAndPassword(
                              email,
                              password,
                            );
                            if (result is String) {
                              setState(() {
                                error = result;
                              });
                              showDialog(
                                context: context,
                                builder: (context) {
                                  if (Platform.isIOS) {
                                    return CupertinoAlertDialog(
                                      title: Text('Login failed.'),
                                      content: Text(error),
                                      actions: [
                                        CupertinoDialogAction(
                                          child: Text('Dismiss'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  } else {
                                    return AlertDialog(
                                      title: Text('Login failed.'),
                                      content: Text(error),
                                      actions: [
                                        TextButton(
                                          child: Text('Dismiss'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  }
                                },
                                barrierDismissible: false,
                              );
                              print(error);
                            } else {
                              Navigator.of(context)
                                  .pushReplacementNamed('/thought');
                            }
                          },
                        ),
                        SignUpLink(
                          press: () {
                            Navigator.of(context).pushNamed('/signup');
                          },
                        ),
                        SizedBox(
                          height: 15,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_consoler/Pages/SignUp/components/background.dart';
import 'package:my_consoler/Services/auth.dart';
import 'package:my_consoler/Services/database.dart';
import 'package:my_consoler/components/rounded_button.dart';
import 'package:my_consoler/components/text_field_container.dart';
import 'package:my_consoler/themes.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final AuthService _auth = AuthService();
  final disabledItems = [
    'Gender',
    'I\'m a Covid-19 patient',
    'I\'m ...',
    'My financial status is ...'
  ];

  String name,
      age,
      email,
      password,
      gender,
      occupation,
      financialStatus,
      isPatient;

  String error = '';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: BackButton(),
              ),
            ),
            Align(
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
                        SizedBox(
                          height: size.height * 0.02,
                        ),
                        Text(
                          'Sign up now.',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(
                          height: size.height * 0.05,
                        ),
                        Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextFieldContainer(
                                child: TextFormField(
                                  style: TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                    icon: Icon(
                                      Icons.person,
                                      color: kPrimaryColor,
                                    ),
                                    counterText: '',
                                    hintText: 'Name',
                                    hintStyle: TextStyle(color: Colors.black54),
                                    border: InputBorder.none,
                                  ),
                                  maxLength: 40,
                                  validator: (String value) {
                                    if (value.isEmpty) {
                                      return 'Name is required.';
                                    }
                                    if (value.length > 30) {
                                      return 'Up to 30 characters only.';
                                    }
                                    if (!RegExp(
                                            '^[a-zA-Z]+(([ ])?[a-zA-Z]*)*\$')
                                        .hasMatch(value)) {
                                      return 'Only alphabets allowed.';
                                    }
                                    return null;
                                  },
                                  onSaved: (String value) {
                                    name = value;
                                  },
                                ),
                              ),
                              TextFieldContainer(
                                child: TextFormField(
                                  style: TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                    icon: Icon(
                                      Icons.cake,
                                      color: kPrimaryColor,
                                    ),
                                    hintText: 'Age',
                                    hintStyle: TextStyle(color: Colors.black54),
                                    border: InputBorder.none,
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (String value) {
                                    if (value.isEmpty) {
                                      return 'Age is required.';
                                    }
                                    if (!RegExp('^(1[89]|[2-9]\\d)\$')
                                        .hasMatch(value)) {
                                      return 'Only numbers from 18 - 99.';
                                    }
                                    return null;
                                  },
                                  onSaved: (String value) {
                                    age = value;
                                  },
                                ),
                              ),
                              TextFieldContainer(
                                child: DropdownButtonFormField(
                                  decoration:
                                      InputDecoration(border: InputBorder.none),
                                  dropdownColor: kPrimaryLightColor,
                                  isExpanded: true,
                                  hint: Text(
                                    'Gender',
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                  value: gender,
                                  items: <String>[
                                    'Gender',
                                    'Male',
                                    'Female',
                                    'Prefer not to say'
                                  ].map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: TextStyle(
                                          color: disabledItems.contains(value)
                                              ? Colors.black54
                                              : Colors.black,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  validator: (value) {
                                    if (value == null ||
                                        disabledItems.contains(value)) {
                                      return 'Option is required.';
                                    }
                                    return null;
                                  },
                                  onTap: () {
                                    FocusScopeNode currentFocus =
                                        FocusScope.of(context);
                                    if (!currentFocus.hasPrimaryFocus) {
                                      currentFocus.unfocus();
                                    }
                                  },
                                  onChanged: (String newValue) {
                                    setState(() {
                                      gender = newValue;
                                    });
                                  },
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: kPrimaryColor,
                                  ),
                                ),
                              ),
                              TextFieldContainer(
                                child: DropdownButtonFormField(
                                  decoration:
                                      InputDecoration(border: InputBorder.none),
                                  dropdownColor: kPrimaryLightColor,
                                  isExpanded: true,
                                  hint: Text(
                                    'I\'m a Covid-19 patient',
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                  value: isPatient,
                                  items: <String>[
                                    'I\'m a Covid-19 patient',
                                    'Yes',
                                    'No'
                                  ].map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: TextStyle(
                                          color: disabledItems.contains(value)
                                              ? Colors.black54
                                              : Colors.black,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  validator: (value) {
                                    if (value == null ||
                                        disabledItems.contains(value)) {
                                      return 'Option is required.';
                                    }
                                    return null;
                                  },
                                  onTap: () {
                                    FocusScopeNode currentFocus =
                                        FocusScope.of(context);
                                    if (!currentFocus.hasPrimaryFocus) {
                                      currentFocus.unfocus();
                                    }
                                  },
                                  onChanged: (String newValue) {
                                    setState(() {
                                      isPatient = newValue;
                                    });
                                  },
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: kPrimaryColor,
                                  ),
                                ),
                              ),
                              TextFieldContainer(
                                child: DropdownButtonFormField(
                                  decoration:
                                      InputDecoration(border: InputBorder.none),
                                  dropdownColor: kPrimaryLightColor,
                                  isExpanded: true,
                                  hint: Text(
                                    'I\'m ...',
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                  value: occupation,
                                  items: <String>[
                                    'I\'m ...',
                                    'a frontliner',
                                    'a student',
                                    'a worker',
                                    'retired',
                                    'self-employed',
                                    'unemployed'
                                  ].map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: TextStyle(
                                          color: disabledItems.contains(value)
                                              ? Colors.black54
                                              : Colors.black,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  validator: (value) {
                                    if (value == null ||
                                        disabledItems.contains(value)) {
                                      return 'Option is required.';
                                    }
                                    return null;
                                  },
                                  onTap: () {
                                    FocusScopeNode currentFocus =
                                        FocusScope.of(context);
                                    if (!currentFocus.hasPrimaryFocus) {
                                      currentFocus.unfocus();
                                    }
                                  },
                                  onChanged: (String newValue) {
                                    setState(() {
                                      occupation = newValue;
                                    });
                                  },
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: kPrimaryColor,
                                  ),
                                ),
                              ),
                              TextFieldContainer(
                                child: DropdownButtonFormField(
                                  decoration:
                                      InputDecoration(border: InputBorder.none),
                                  dropdownColor: kPrimaryLightColor,
                                  isExpanded: true,
                                  hint: Text(
                                    'My financial status is ...',
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                  value: financialStatus,
                                  items: <String>[
                                    'My financial status is ...',
                                    'Good',
                                    'Fair',
                                    'Poor'
                                  ].map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: TextStyle(
                                          color: disabledItems.contains(value)
                                              ? Colors.black54
                                              : Colors.black,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  validator: (value) {
                                    if (value == null ||
                                        disabledItems.contains(value)) {
                                      return 'Option is required.';
                                    }
                                    return null;
                                  },
                                  onTap: () {
                                    FocusScopeNode currentFocus =
                                        FocusScope.of(context);
                                    if (!currentFocus.hasPrimaryFocus) {
                                      currentFocus.unfocus();
                                    }
                                  },
                                  onChanged: (String newValue) {
                                    setState(() {
                                      financialStatus = newValue;
                                    });
                                  },
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: kPrimaryColor,
                                  ),
                                ),
                              ),
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
                                text: 'Sign Up',
                                press: () async {
                                  // if validation is unsuccessful
                                  if (!_formKey.currentState.validate()) {
                                    return;
                                  }
                                  _formKey.currentState.save();
                                  // Remove this after testing
                                  print(name);
                                  print(age);
                                  print(gender);
                                  print(isPatient);
                                  print(occupation);
                                  print(financialStatus);
                                  print(email);
                                  print(password);
                                  dynamic result =
                                      await _auth.signUpWithEmailAndPassword(
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
                                            title: Text('Sign up failed.'),
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
                                            title: Text('Sign up failed.'),
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
                                    await DatabaseService(uid: result.uid)
                                        .addUserData(
                                      name,
                                      int.parse(age),
                                      gender,
                                      isPatient,
                                      occupation,
                                      financialStatus,
                                    );
                                    Navigator.of(context)
                                        .pushReplacementNamed('/thought');
                                  }
                                },
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
          ],
        ),
      ),
    );
  }
}

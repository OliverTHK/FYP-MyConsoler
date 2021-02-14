import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:my_consoler/Models/custom_user.dart';
import 'package:my_consoler/Pages/Profile/components/background.dart';
import 'package:my_consoler/Pages/Profile/components/rounded_text_field_container.dart';
import 'package:my_consoler/Services/database.dart';
import 'package:my_consoler/components/loading_widget.dart';
import 'package:my_consoler/components/rounded_button.dart';
import 'package:provider/provider.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final disabledItems = [
    'Gender',
    'I\'m a Covid-19 patient',
    'I\'m ...',
    'My financial status is ...'
  ];
  String name, age, gender, occupation, financialStatus, isPatient;

  @override
  Widget build(BuildContext context) {
    final myUsers = Provider.of<DocumentSnapshot>(context);
    final user = Provider.of<CustomUser>(context);

    Size size = MediaQuery.of(context).size;
    return myUsers != null
        ? Background(
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
                                'Edit Profile',
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
                                    RoundedTextFieldContainer(
                                      child: TextFormField(
                                        decoration: InputDecoration(
                                          icon: Icon(
                                            Icons.person,
                                          ),
                                          counterText: '',
                                          hintText: 'Name',
                                          border: InputBorder.none,
                                        ),
                                        initialValue: myUsers.data()['name'],
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
                                    RoundedTextFieldContainer(
                                      child: TextFormField(
                                        decoration: InputDecoration(
                                          icon: Icon(
                                            Icons.cake,
                                          ),
                                          hintText: 'Age',
                                          border: InputBorder.none,
                                        ),
                                        initialValue:
                                            myUsers.data()['age'].toString(),
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
                                    RoundedTextFieldContainer(
                                      child: DropdownButtonFormField(
                                        decoration: InputDecoration(
                                            border: InputBorder.none),
                                        isExpanded: true,
                                        value:
                                            gender ?? myUsers.data()['gender'],
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
                                                fontWeight: disabledItems
                                                        .contains(value)
                                                    ? FontWeight.bold
                                                    : null,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        validator: (value) {
                                          if (disabledItems.contains(value)) {
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
                                        onChanged: (newValue) {
                                          setState(() {
                                            gender = newValue;
                                          });
                                        },
                                        onSaved: (value) {
                                          if (value.isEmpty)
                                            gender = myUsers.data()['gender'];
                                          else
                                            gender = value;
                                        },
                                        icon: Icon(
                                          Icons.arrow_drop_down,
                                        ),
                                      ),
                                    ),
                                    RoundedTextFieldContainer(
                                      child: DropdownButtonFormField(
                                        decoration: InputDecoration(
                                            border: InputBorder.none),
                                        isExpanded: true,
                                        value: isPatient ??
                                            myUsers.data()['isPatient'],
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
                                                fontWeight: disabledItems
                                                        .contains(value)
                                                    ? FontWeight.bold
                                                    : null,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        validator: (value) {
                                          if (disabledItems.contains(value)) {
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
                                        onChanged: (newValue) {
                                          setState(() {
                                            isPatient = newValue;
                                          });
                                        },
                                        onSaved: (value) {
                                          if (value.isEmpty)
                                            isPatient =
                                                myUsers.data()['isPatient'];
                                          else
                                            isPatient = value;
                                        },
                                        icon: Icon(
                                          Icons.arrow_drop_down,
                                        ),
                                      ),
                                    ),
                                    RoundedTextFieldContainer(
                                      child: DropdownButtonFormField(
                                        decoration: InputDecoration(
                                            border: InputBorder.none),
                                        isExpanded: true,
                                        value: occupation ??
                                            myUsers.data()['occupation'],
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
                                                fontWeight: disabledItems
                                                        .contains(value)
                                                    ? FontWeight.bold
                                                    : null,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        validator: (value) {
                                          if (disabledItems.contains(value)) {
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
                                        onChanged: (newValue) {
                                          setState(() {
                                            occupation = newValue;
                                          });
                                        },
                                        onSaved: (value) {
                                          if (value.isEmpty)
                                            occupation =
                                                myUsers.data()['occupation'];
                                          else
                                            occupation = value;
                                        },
                                        icon: Icon(
                                          Icons.arrow_drop_down,
                                        ),
                                      ),
                                    ),
                                    RoundedTextFieldContainer(
                                      child: DropdownButtonFormField(
                                        decoration: InputDecoration(
                                            border: InputBorder.none),
                                        isExpanded: true,
                                        value: financialStatus ??
                                            myUsers.data()['financialStatus'],
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
                                                fontWeight: disabledItems
                                                        .contains(value)
                                                    ? FontWeight.bold
                                                    : null,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        validator: (value) {
                                          if (disabledItems.contains(value)) {
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
                                        onChanged: (newValue) {
                                          setState(() {
                                            financialStatus = newValue;
                                          });
                                        },
                                        onSaved: (value) {
                                          if (value.isEmpty)
                                            financialStatus = myUsers
                                                .data()['financialStatus'];
                                          else
                                            financialStatus = value;
                                        },
                                        icon: Icon(
                                          Icons.arrow_drop_down,
                                        ),
                                      ),
                                    ),
                                    RoundedButton(
                                      text: 'Save',
                                      press: () async {
                                        // if validation is unsuccessful
                                        if (!_formKey.currentState.validate()) {
                                          return;
                                        }
                                        _formKey.currentState.save();
                                        await DatabaseService(uid: user.uid)
                                            .updateUserData(
                                          name,
                                          int.parse(age),
                                          gender,
                                          isPatient,
                                          occupation,
                                          financialStatus,
                                        );
                                        Navigator.of(context).pop();
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
          )
        : LoadingWidget();
  }
}

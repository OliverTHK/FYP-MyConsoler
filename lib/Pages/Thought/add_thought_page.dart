import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_consoler/Models/custom_user.dart';
import 'package:my_consoler/Pages/Thought/components/background.dart';
import 'package:my_consoler/Services/database.dart';
import 'package:my_consoler/components/animations/my_fade_in.dart';
import 'package:my_consoler/components/modified_text_input_formatter.dart';
import 'package:my_consoler/components/rounded_button.dart';
import 'package:my_consoler/themes.dart';
import 'package:provider/provider.dart';

class AddThoughtPage extends StatefulWidget {
  @override
  _AddThoughtPageState createState() => _AddThoughtPageState();
}

class _AddThoughtPageState extends State<AddThoughtPage> {
  String thought;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context);
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          child: Stack(
            children: [
              Background(),
              SafeArea(
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: FlatButton(
                        onPressed: () {
                          thought = '';
                          Navigator.pushReplacementNamed(context, '/main');
                        },
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MyFadeIn(
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                'How are you feeling today?',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                ),
                              ),
                            ),
                          ),
                          Form(
                            key: _formKey,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15.0, horizontal: 30.0),
                              child: Container(
                                child: TextFormField(
                                  inputFormatters: [
                                    new ModifiedLengthLimitingTextInputFormatter(
                                        50)
                                  ],
                                  decoration: InputDecoration(
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        width: 2.0,
                                        color: kPrimaryLightColor,
                                      ),
                                    ),
                                    hintText: 'Input your thought here',
                                  ),
                                  autofocus: true,
                                  maxLength: 50,
                                  keyboardType: TextInputType.text,
                                  validator: (String value) {
                                    if (!RegExp(
                                            '^[a-zA-Z]+(([ ])?[a-zA-Z,.]*)*\$')
                                        .hasMatch(value)) {
                                      return 'Only alphabets, \",\" and \".\" allowed.';
                                    }
                                    return null;
                                  },
                                  onSaved: (String value) {
                                    thought = value;
                                  },
                                ),
                              ),
                            ),
                          ),
                          RoundedButton(
                            text: 'Confirm',
                            press: () async {
                              if (!_formKey.currentState.validate()) {
                                return;
                              }
                              _formKey.currentState.save();
                              await DatabaseService(uid: user.uid)
                                  .updateThoughtData(thought)
                                  .then((value) {
                                Navigator.pushReplacementNamed(
                                    context, '/main');
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

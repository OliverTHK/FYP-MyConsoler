import 'dart:io';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:my_consoler/Pages/Settings/components/temp_storage.dart';
import 'package:my_consoler/Services/auth.dart';
import 'package:my_consoler/themes.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Body extends StatefulWidget {
  final TempStorage tempStorage;

  const Body({Key key, @required this.tempStorage}) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final AuthService _auth = AuthService();
  final _scrollController = ScrollController();
  Future<Directory> _docDir;
  File _docFile;
  String docDirStr = '';
  String version = '';
  String buildNumber = '';
  String username = 'myconsoler.bot@gmail.com';
  String password = 'myConsoler@google';
  List<String> dataList = new List<String>();
  List<String> splittedName = new List<String>();
  int selectedRadio;

  Future<Null> getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    selectedRadio = prefs.getInt('selectedRadio') ?? 1;
  }

  @override
  void initState() {
    super.initState();
    getAppInfo();
    getSharedPrefs();
  }

  void getAppInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    });
  }

  setSelectedRadio(int val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedRadio = val;
      prefs.setInt('selectedRadio', selectedRadio);
    });
  }

  @override
  Widget build(BuildContext context) {
    var firebaseUser = FirebaseAuth.instance.currentUser;

    return Stack(
      fit: StackFit.expand,
      children: [
        FadingEdgeScrollView.fromSingleChildScrollView(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Theme',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                RadioListTile(
                  value: 1,
                  groupValue: selectedRadio,
                  title: Text('Light'),
                  activeColor: kPrimaryColor,
                  onChanged: (val) {
                    print('Radio button ${val} is pressed.');
                    setSelectedRadio(val);
                    AdaptiveTheme.of(context).setLight();
                  },
                  selected: selectedRadio == 1,
                ),
                RadioListTile(
                  value: 2,
                  groupValue: selectedRadio,
                  title: Text('Dark'),
                  activeColor: kPrimaryColor,
                  onChanged: (val) {
                    print('Radio button ${val} is pressed.');
                    setSelectedRadio(val);
                    AdaptiveTheme.of(context).setDark();
                  },
                  selected: selectedRadio == 2,
                ),
                RadioListTile(
                  value: 3,
                  groupValue: selectedRadio,
                  title: Text('System Default'),
                  activeColor: kPrimaryColor,
                  onChanged: (val) {
                    print('Radio button ${val} is pressed.');
                    setSelectedRadio(val);
                    AdaptiveTheme.of(context).setSystem();
                  },
                  selected: selectedRadio == 3,
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  'Chat',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.send_to_mobile),
                  title: Text('Export chat queries to email'),
                  onTap: () async {
                    setState(() {
                      _docDir = getApplicationDocumentsDirectory();
                    });
                    if (dataList.isNotEmpty) dataList.clear();
                    var querySnapshot = await FirebaseFirestore.instance
                        .collection('myusers')
                        .doc(firebaseUser.uid)
                        .collection('mychats')
                        .orderBy('timeStamp')
                        .get();
                    if (querySnapshot.docs.isEmpty) {
                      print("No chat data found in the database.");
                      showDialog(
                        context: context,
                        builder: (context) {
                          if (Platform.isIOS) {
                            return CupertinoAlertDialog(
                              title: Text('Export data failed.'),
                              content: Text(
                                  'Oops! You have yet to chat with MyConsoler Bot and thus, there\'s no chat data found in the database for now.\n\nYou can return to the Main page and tap on the Chat button in the bottom-right corner to start your first chat.'),
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
                              title: Text('Export data failed.'),
                              content: Text(
                                  'Oops! You have yet to chat with MyConsoler Bot and thus, there\'s no chat data found in the database for now.\n\nYou can return to the Main page and tap on the Chat button in the bottom-right corner to start your first chat.'),
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
                    } else {
                      dataList.add('user_message,timestamp');
                      querySnapshot.docs.forEach((res) async {
                        Timestamp timeStamp = res.data()['timeStamp'];
                        var dateTimeOffset = timeStamp
                            .toDate()
                            .toUtc()
                            .add(new Duration(hours: 8));
                        var dateTime = DateFormat('yyyy-MM-dd')
                            .add_jms()
                            .format(dateTimeOffset);
                        dataList.add(
                            '"${res.data()['message'].toString().replaceAll('"', '""')}","${dateTime.toString()}"');
                      });
                      if (dataList.isNotEmpty)
                        widget.tempStorage.writeLinesData(dataList);
                      var documentSnapshot = await FirebaseFirestore.instance
                          .collection('myusers')
                          .doc(firebaseUser.uid)
                          .get();
                      print('Recipient email: ${firebaseUser.email}');
                      splittedName = documentSnapshot.data()['name'].split(' ');
                      // ignore: deprecated_member_use
                      final smtpServer = gmail(username, password);
                      final emailMessage = Message()
                        ..from = Address(username, 'MyConsoler')
                        ..recipients.add('${firebaseUser.email}')
                        ..subject = 'MyConsoler: Requested Query Data'
                        ..text =
                            'Hi ${splittedName.first},\n\nAttached below is your requested query data for MyConsoler chat.\n\nThank you for using MyConsoler.\n\n— MyConsoler Bot'
                        ..attachments.add(FileAttachment(_docFile));
                      showDialog(
                        context: context,
                        builder: (context) {
                          if (Platform.isIOS) {
                            return CupertinoAlertDialog(
                              title: Text('Are you sure?'),
                              content: Text(
                                  'Chat data will be sent to "${firebaseUser.email}". \n\nPlease tap "Yes" to continue.'),
                              actions: [
                                CupertinoDialogAction(
                                  child: Text('Yes'),
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    try {
                                      Fluttertoast.showToast(
                                        msg: 'Sending email... Please wait.',
                                        toastLength: Toast.LENGTH_SHORT,
                                        timeInSecForIosWeb: 1,
                                      );
                                      final sendReport =
                                          await send(emailMessage, smtpServer);
                                      print(sendReport.toString());
                                      Fluttertoast.showToast(
                                        msg:
                                            'Email sent. Please check your inbox.',
                                        toastLength: Toast.LENGTH_SHORT,
                                        timeInSecForIosWeb: 1,
                                      );
                                    } on MailerException catch (e) {
                                      print('Message not sent.');
                                      Fluttertoast.showToast(
                                        msg:
                                            'Email not sent. The email address doesn\'t exist or might be invalid.',
                                        toastLength: Toast.LENGTH_LONG,
                                        timeInSecForIosWeb: 3,
                                      );
                                      for (var p in e.problems) {
                                        print('Problem: ${p.code}: ${p.msg}');
                                      }
                                    }
                                  },
                                ),
                                CupertinoDialogAction(
                                  child: Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          } else {
                            return AlertDialog(
                              title: Text('Are you sure?'),
                              content: Text(
                                  'Chat data will be sent to "${firebaseUser.email}". \n\nPlease tap "Yes" to continue.'),
                              actions: [
                                TextButton(
                                  child: Text('Yes'),
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    try {
                                      Fluttertoast.showToast(
                                        msg: 'Sending email... Please wait.',
                                        toastLength: Toast.LENGTH_SHORT,
                                        timeInSecForIosWeb: 1,
                                      );
                                      final sendReport =
                                          await send(emailMessage, smtpServer);
                                      print(sendReport.toString());
                                      Fluttertoast.showToast(
                                        msg:
                                            'Email sent. Please check your inbox.',
                                        toastLength: Toast.LENGTH_SHORT,
                                        timeInSecForIosWeb: 1,
                                      );
                                    } on MailerException catch (e) {
                                      print('Message not sent.');
                                      Fluttertoast.showToast(
                                        msg:
                                            'Email not sent. The email address doesn\'t exist or might be invalid.',
                                        toastLength: Toast.LENGTH_LONG,
                                        timeInSecForIosWeb: 3,
                                      );
                                      for (var p in e.problems) {
                                        print('Problem: ${p.code}: ${p.msg}');
                                      }
                                    }
                                  },
                                ),
                                TextButton(
                                  child: Text('Cancel'),
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
                    }
                  },
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.exit_to_app),
                  title: Text('Log Out'),
                  onTap: () async {
                    await _auth.signOut().then((value) => Navigator.of(context)
                        .pushNamedAndRemoveUntil(
                            '/login', (Route<dynamic> route) => false));
                  },
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  'MyConsoler',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('About'),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationIcon: Image.asset(
                        'assets/icons/MyConsoler_icon.png',
                        width: 50,
                        height: 50,
                      ),
                      applicationVersion: version + '+' + buildNumber,
                      applicationLegalese: '© 2020 oliverthk.dev',
                      children: [
                        SizedBox(
                          height: 30,
                        ),
                        Text(
                            'An app to console the Covid-19 victims.\n\nDeveloped by Oliver Tan.'),
                      ],
                    );
                  },
                ),
                FutureBuilder<Directory>(
                  future: _docDir,
                  builder: (BuildContext context,
                      AsyncSnapshot<Directory> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasError) {
                        print('Error: ${snapshot.error}');
                      } else if (snapshot.hasData) {
                        docDirStr = snapshot.data.path;
                        _docFile = File('$docDirStr/user_query.csv');
                        print('Directory: ${_docFile.toString()}');
                      } else {
                        print('Directory unavailable.');
                      }
                    }
                    return Text('');
                  },
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

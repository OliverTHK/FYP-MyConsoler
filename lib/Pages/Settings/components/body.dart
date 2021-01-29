import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:my_consoler/Pages/Settings/components/temp_storage.dart';
import 'package:my_consoler/Services/auth.dart';
import 'package:my_consoler/theme_changer.dart';
import 'package:my_consoler/themes.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

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

  @override
  void initState() {
    super.initState();
    getAppInfo();
  }

  void getAppInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeChanger themeChanger = Provider.of<ThemeChanger>(context);
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
                SwitchListTile(
                  activeColor: kPrimaryLightColor,
                  value: themeChanger.darkMode,
                  title: Text('Dark mode'),
                  secondary: Icon(FontAwesome.moon),
                  onChanged: (bool value) {
                    setState(() {
                      themeChanger.darkMode = value;
                      themeChanger.darkMode
                          ? themeChanger.setTheme(
                              ThemeData(
                                brightness: Brightness.dark,
                                primaryColor: kAppBarColor,
                                textSelectionColor: kPrimaryColor,
                                accentColor: kPrimaryLightColor,
                                floatingActionButtonTheme:
                                    FloatingActionButtonThemeData(
                                  foregroundColor: Colors.black,
                                ),
                              ),
                            )
                          : themeChanger.setTheme(
                              ThemeData(
                                brightness: Brightness.light,
                                primaryColor: kAppBarColor,
                                floatingActionButtonTheme:
                                    FloatingActionButtonThemeData(
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            );
                    });
                  },
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
                          'Message: ${res.data()['message'].toString()}\t\tTimestamp: ${dateTime.toString()}');
                    });
                    if (dataList.isNotEmpty)
                      widget.tempStorage.writeLinesData(dataList);
                    else
                      widget.tempStorage.writeLinesData([
                        '-- No chat queries yet. Start chatting with MyConsoler bot to get some data. --'
                      ]);
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
                    try {
                      final sendReport = await send(emailMessage, smtpServer);
                      print(sendReport.toString());
                      Fluttertoast.showToast(
                        msg: 'Email sent. Please check your inbox.',
                        toastLength: Toast.LENGTH_SHORT,
                        timeInSecForIosWeb: 1,
                      );
                    } on MailerException catch (e) {
                      print('Message not sent.');
                      Fluttertoast.showToast(
                        msg:
                            'Email not sent. The email address doesn\'t exist or might be invalid.',
                        toastLength: Toast.LENGTH_SHORT,
                        timeInSecForIosWeb: 1,
                      );
                      for (var p in e.problems) {
                        print('Problem: ${p.code}: ${p.msg}');
                      }
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
                        _docFile = File('$docDirStr/user_query.txt');
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

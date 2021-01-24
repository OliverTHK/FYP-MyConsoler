import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_consoler/Models/custom_user.dart';
import 'package:my_consoler/Pages/Main/components/body.dart';
import 'package:my_consoler/Pages/Main/components/chat_floating_button.dart';
import 'package:my_consoler/Services/database.dart';
import 'package:my_consoler/components/loading_widget.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  DateTime currentBackPressTime;

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(
        msg: 'Press \"Back\" button again to exit the app.',
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 1,
      );
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context);
    return user != null
        ? StreamProvider<DocumentSnapshot>.value(
            value: DatabaseService(uid: user.uid).myUsers,
            child: WillPopScope(
              onWillPop: onWillPop,
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                body: Body(),
                floatingActionButton: ChatFloatingButton(),
              ),
            ),
          )
        : LoadingWidget();
  }
}

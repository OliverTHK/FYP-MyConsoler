import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_consoler/Models/custom_user.dart';
import 'package:my_consoler/Pages/Profile/components/body.dart';
import 'package:my_consoler/Services/database.dart';
import 'package:my_consoler/components/loading_widget.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context);
    return user != null
        ? StreamProvider<DocumentSnapshot>.value(
            value: DatabaseService(uid: user.uid).myUsers,
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              body: Body(),
            ),
          )
        : LoadingWidget();
  }
}

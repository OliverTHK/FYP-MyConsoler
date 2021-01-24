import 'package:flutter/material.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'package:my_consoler/components/animations/my_elastic_scale.dart';
import 'package:my_consoler/themes.dart';

class ChatFloatingButton extends StatefulWidget {
  @override
  _ChatFloatingButtonState createState() => _ChatFloatingButtonState();
}

class _ChatFloatingButtonState extends State<ChatFloatingButton> {
  @override
  Widget build(BuildContext context) {
    return MyElasticScale(
      child: FloatingActionButton(
        backgroundColor: kPrimaryColor,
        onPressed: () {
          Navigator.pushNamed(context, '/chat');
        },
        tooltip: 'Chat with MyConsoler',
        child: Icon(Entypo.chat),
      ),
    );
  }
}

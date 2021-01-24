import 'package:flutter/material.dart';
import 'package:my_consoler/Pages/Chat/components/body.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MyConsoler\'s Chat',
          textAlign: TextAlign.center,
        ),
        elevation: 0,
      ),
      body: Body(),
    );
  }
}

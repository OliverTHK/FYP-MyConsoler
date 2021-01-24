import 'package:flutter/material.dart';
import 'package:my_consoler/Pages/Chat/components/temp_storage.dart';
import 'package:my_consoler/Pages/Settings/components/body.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          textAlign: TextAlign.center,
        ),
        elevation: 0,
      ),
      body: Body(
        tempStorage: TempStorage(),
      ),
    );
  }
}

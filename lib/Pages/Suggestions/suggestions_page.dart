import 'package:flutter/material.dart';
import 'package:my_consoler/Pages/Suggestions/components/body.dart';

class SuggestionsPage extends StatefulWidget {
  @override
  _SuggestionsPageState createState() => _SuggestionsPageState();
}

class _SuggestionsPageState extends State<SuggestionsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Discover All',
          textAlign: TextAlign.center,
        ),
        elevation: 0,
      ),
      body: Body(),
    );
  }
}

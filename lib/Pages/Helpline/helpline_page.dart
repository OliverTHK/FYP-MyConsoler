import 'package:flutter/material.dart';
import 'package:my_consoler/Pages/Helpline/components/body.dart';

class HelplinePage extends StatelessWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text(
          'Helplines',
          textAlign: TextAlign.center,
        ),
        actions: [
          IconButton(
            tooltip: 'Show Tips',
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              _scaffoldKey.currentState.showSnackBar(
                const SnackBar(
                  content:
                      Text('Swipe RIGHT on any tile to reveal more actions.'),
                ),
              );
            },
          ),
        ],
        elevation: 0,
      ),
      body: Body(),
    );
  }
}

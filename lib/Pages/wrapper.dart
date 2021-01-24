import 'package:flutter/material.dart';
import 'package:my_consoler/Models/custom_user.dart';
import 'package:my_consoler/Pages/Login/login_page.dart';
import 'package:my_consoler/Pages/Thought/add_thought_page.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context);
    print(user);
    // Return either Login/Add Thought page as initial page based on 'user' object instance from Provider
    return user == null ? LoginPage() : AddThoughtPage();
  }
}

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_consoler/Models/custom_user.dart';
import 'package:my_consoler/Pages/Chat/chat_page.dart';
import 'package:my_consoler/Pages/Helpline/helpline_page.dart';
import 'package:my_consoler/Pages/Login/login_page.dart';
import 'package:my_consoler/Pages/Main/main_page.dart';
import 'package:my_consoler/Pages/Settings/settings_page.dart';
import 'package:my_consoler/Pages/SignUp/sign_up_page.dart';
import 'package:my_consoler/Pages/Suggestions/suggestions_page.dart';
import 'package:my_consoler/Pages/Thought/add_thought_page.dart';
import 'package:my_consoler/Pages/wrapper.dart';
import 'package:my_consoler/Services/auth.dart';
import 'package:my_consoler/theme_changer.dart';
import 'package:my_consoler/themes.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeChanger>(
      create: (_) => ThemeChanger(
        ThemeData(
          primaryColor: kAppBarColor,
          scaffoldBackgroundColor: Colors.white,
        ),
      ),
      child: new MaterialAppWithTheme(),
    );
  }
}

class MaterialAppWithTheme extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);
    return StreamProvider<CustomUser>.value(
      value: AuthService().user,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MyConsoler',
        theme: theme.getTheme(),
        routes: {
          '/thought': (context) => AddThoughtPage(),
          '/main': (context) => MainPage(),
          '/helpline': (context) => HelplinePage(),
          '/settings': (context) => SettingsPage(),
          '/suggestions': (context) => SuggestionsPage(),
          '/chat': (context) => ChatPage(),
          '/login': (context) => LoginPage(),
          '/signup': (context) => SignUpPage(),
        },
        home: Wrapper(),
      ),
    );
  }
}

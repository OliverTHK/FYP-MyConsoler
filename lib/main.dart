import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_consoler/Models/custom_user.dart';
import 'package:my_consoler/Pages/Chat/chat_page.dart';
import 'package:my_consoler/Pages/Helpline/helpline_page.dart';
import 'package:my_consoler/Pages/Login/login_page.dart';
import 'package:my_consoler/Pages/Main/main_page.dart';
import 'package:my_consoler/Pages/Profile/edit_profile_page.dart';
import 'package:my_consoler/Pages/Settings/settings_page.dart';
import 'package:my_consoler/Pages/SignUp/sign_up_page.dart';
import 'package:my_consoler/Pages/Suggestions/suggestions_page.dart';
import 'package:my_consoler/Pages/Thought/add_thought_page.dart';
import 'package:my_consoler/Pages/wrapper.dart';
import 'package:my_consoler/Services/auth.dart';
import 'package:my_consoler/themes.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  runApp(MyApp(savedThemeMode: savedThemeMode));
}

class MyApp extends StatelessWidget {
  final AdaptiveThemeMode savedThemeMode;

  const MyApp({Key key, this.savedThemeMode}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialAppWithTheme(
      savedThemeMode: savedThemeMode,
    );
  }
}

class MaterialAppWithTheme extends StatelessWidget {
  final AdaptiveThemeMode savedThemeMode;

  const MaterialAppWithTheme({Key key, this.savedThemeMode}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return StreamProvider<CustomUser>.value(
      value: AuthService().user,
      child: AdaptiveTheme(
        light: ThemeData(
          brightness: Brightness.light,
          primaryColor: kAppBarColor,
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            foregroundColor: Colors.white,
          ),
        ),
        dark: ThemeData(
          brightness: Brightness.dark,
          primaryColor: kAppBarColor,
          textSelectionColor: kPrimaryColor,
          accentColor: kPrimaryLightColor,
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            foregroundColor: Colors.black,
          ),
        ),
        initial: savedThemeMode ?? AdaptiveThemeMode.light,
        builder: (theme, darkTheme) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MyConsoler',
          theme: theme,
          darkTheme: darkTheme,
          routes: {
            '/thought': (context) => AddThoughtPage(),
            '/main': (context) => MainPage(),
            '/helpline': (context) => HelplinePage(),
            '/settings': (context) => SettingsPage(),
            '/suggestions': (context) => SuggestionsPage(),
            '/profile': (context) => EditProfilePage(),
            '/chat': (context) => ChatPage(),
            '/login': (context) => LoginPage(),
            '/signup': (context) => SignUpPage(),
          },
          home: Wrapper(),
        ),
      ),
    );
  }
}

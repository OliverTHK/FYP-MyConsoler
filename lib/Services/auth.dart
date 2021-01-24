import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_consoler/Models/custom_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create user object based on Firebase user (User)
  CustomUser _getUserFromFirebaseUser(User user) {
    return user != null ? CustomUser(uid: user.uid) : null;
  }

  // Change user stream based on authentication
  Stream<CustomUser> get user {
    return _auth.authStateChanges().map(_getUserFromFirebaseUser);
  }

  // Log in with email & password
  Future logInWithEmailAndPassword(String _email, String _password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: _email,
        password: _password,
      );
      User user = result.user;
      return _getUserFromFirebaseUser(user);
    } catch (error) {
      switch (error.code) {
        case 'user-not-found':
          return 'The email entered is not found in the database. Please click on the link below the "Log In" button to sign up or retry with the correct login credentials.';
          break;
        case 'wrong-password':
          return 'The password entered is incorrect. Please try again.';
          break;
        default:
          return '';
      }
    }
  }

  // Sign up with email & password
  Future signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User user = result.user;
      return _getUserFromFirebaseUser(user);
    } catch (error) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'The email entered is already in use. Please return to "Log In" page and re-login with the existing credentials.';
          break;
        default:
          return '';
      }
    }
  }

  // Sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (error) {
      print(error.toString());
      return null;
    }
  }
}

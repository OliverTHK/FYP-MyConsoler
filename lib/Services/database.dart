import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;
  DatabaseService({this.uid});

  // Collection reference
  final CollectionReference myUserCollection =
      FirebaseFirestore.instance.collection('myusers');
  final CollectionReference mySuggestionCollection =
      FirebaseFirestore.instance.collection('mysuggestions');

  Future addUserData(String name, int age, String gender, String isPatient,
      String occupation, String financialStatus) async {
    return await myUserCollection.doc(uid).set({
      'name': name,
      'age': age,
      'gender': gender,
      'isPatient': isPatient,
      'occupation': occupation,
      'financialStatus': financialStatus,
    });
  }

  Future updateThoughtData(String thought) async {
    return await myUserCollection.doc(uid).set(
      {'thought': thought},
      SetOptions(merge: true),
    );
  }

  Future addChatData(String message, DateTime currentTime) async {
    return await myUserCollection
        .doc(uid)
        .collection('mychats')
        .add({'message': message, 'timeStamp': currentTime});
  }

  // Get myusers stream so that we can notify other widgets through the help of Provider whenever changes made to database
  Stream<DocumentSnapshot> get myUsers {
    return myUserCollection.doc(uid).snapshots();
  }

  // Get mysuggestions stream
  Stream<QuerySnapshot> get mySuggestions {
    return mySuggestionCollection.snapshots();
  }
}

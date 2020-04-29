import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:home_cooked/model/user.dart';

class UserService {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<User> getCurrentUser() {
    return auth.currentUser().then(_mapUser);
  }

  Future<User> signIn(String email, String password) {
    return auth.signInWithEmailAndPassword(
      email: email,
      password: password)
    .then(_mapUser);
  }

  Future<void> signOut() {
    return auth.signOut();
  }

  Future<User> _mapUser(FirebaseUser user) async {
    if (user == null) {
      return null;
    }
    var docSnapshot = await Firestore.instance
        .collection("users")
        .document(user.uid)
        .get();
    return User.from(docSnapshot);
  }

//  Future<User> getUser(String id) async {
//    return auth.currentUser().then((user) async {
//      var docSnapshot = await Firestore.instance
//          .collection("users")
//          .document(user.uid)
//          .get();
//      _cachedUser = User.from(docSnapshot);
//      return _cachedUser;
//    });
//  }
}

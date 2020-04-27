import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;

  User({this.uid, this.email, this.firstName, this.lastName});

  User.from(DocumentSnapshot snapshot) : this(
    uid: snapshot.documentID,
    email: snapshot.data['email'],
    firstName: snapshot.data['firstName'],
    lastName: snapshot.data['lastName'],
  );
}

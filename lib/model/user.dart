import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String fullName;
  final String initials;

  User({this.uid, this.email, this.firstName, this.lastName, this.fullName, this.initials});

  User.from(DocumentSnapshot snapshot) : this(
    uid: snapshot.documentID,
    email: snapshot.data['email'],
    firstName: snapshot.data['firstName'],
    lastName: snapshot.data['lastName'],
    fullName: "${snapshot.data['firstName']} ${snapshot.data['lastName']}",
    initials: "${snapshot.data['firstName'][0]}${snapshot.data['lastName'][0]}"
  );
}

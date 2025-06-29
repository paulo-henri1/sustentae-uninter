import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String email;
  final String uid;
  final String photoUrl;
  final String username;
  final List followers;
  final List following;

  User({
    required this.email,
    required this.uid,
    required this.photoUrl,
    required this.username,
    required this.followers,
    required this.following,
  });

  Map<String, dynamic> toJson() => {
    "username": username,
    "uid": uid,
    "email": email,
    "photoUrl": photoUrl,
    "followers": followers,
    "following": following
  };

  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>?;

    return User (
      username: snapshot?['username'] as String? ?? 'Nome de usuário desconhecido',
      uid: snapshot?['uid'] as String? ?? '',
      email: snapshot?['email'] as String? ?? '',
      photoUrl: snapshot?['photoUrl'] as String? ?? '',
      followers: snapshot?['followers'] as List? ?? [],
      following: snapshot?['following'] as List? ?? [],
    );
  }
}

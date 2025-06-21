import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String description;
  final String uid;
  final String username;
  final String postId;
  final String profImage;
  final String postUrl;
  final datePublished;
  final likes;

  Post({
    required this.description,
    required this.uid,
    required this.postId,
    required this.username,
    required this.profImage,
    required this.postUrl,
    required this.datePublished,
    required this.likes,
  });

  Map<String, dynamic> toJson() => {
    "description": description,
    "uid": uid,
    "username": username,
    "postId": postId,
    "profImage": profImage,
    "postUrl": postUrl,
    "datePublished": datePublished,
    "likes": likes
  };

  static Post fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Post (
      username: snapshot['username'],
      uid: snapshot['uid'],
      postId: snapshot['postId'],
      description: snapshot['description'],
      profImage: snapshot['profImage'],
      postUrl: snapshot['postUrl'],
      datePublished: snapshot['datePublished'],
      likes: snapshot['likes'],
    );
  }
}

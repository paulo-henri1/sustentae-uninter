import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sustentae_uninter/resources/auth_methods.dart';
import 'package:sustentae_uninter/resources/firestore_methods.dart';
import 'package:sustentae_uninter/screens/login_screen.dart';
import 'package:sustentae_uninter/utils/utils.dart';

import '../utils/global_variables.dart';
import '../widgets/post_dart.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({super.key, required this.uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userData = {};
  int postLen = 0;
  int followers = 0;
  int following = 0;
  bool isFollowing = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });

    try {
      var userSnap =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.uid)
              .get();

      var postSnap =
          await FirebaseFirestore.instance
              .collection('posts')
              .where('uid', isEqualTo: widget.uid)
              .get();

      if (mounted) {
        setState(() {
          userData = userSnap.data()!;
          postLen = postSnap.docs.length;
          followers = userSnap.data()!['followers'].length;
          following = userSnap.data()!['following'].length;
          isFollowing = userSnap.data()!['followers'].contains(
            FirebaseAuth.instance.currentUser!.uid,
          );
        });
      }
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    userData['username'],
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.grey,
                          backgroundImage: NetworkImage(userData['photoUrl']),
                          radius: 64,
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 21.0,
                        top: 16,
                        bottom: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          buildStatColumn(postLen, 'Posts'),
                          buildStatColumn(followers, 'Seguidores'),
                          buildStatColumn(following, 'Seguindo'),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FirebaseAuth.instance.currentUser!.uid == widget.uid
                            ? FilledButton.tonal(
                              onPressed: () async {
                                await FirebaseAuth.instance.signOut();
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => LoginScreen(),
                                  ),
                                );
                              },
                              child: Text('Sair'),
                            )
                            : isFollowing
                            ? OutlinedButton(
                              onPressed: () async {
                                await FirestoreMethods().followUser(
                                  FirebaseAuth.instance.currentUser!.uid,
                                  userData['uid'],
                                );
                                setState(() {
                                  isFollowing = false;
                                  followers--;
                                });
                              },
                              child: Text('Deixar de seguir'),
                            )
                            : FilledButton(
                              onPressed: () async {
                                await FirestoreMethods().followUser(
                                  FirebaseAuth.instance.currentUser!.uid,
                                  userData['uid'],
                                );
                                setState(() {
                                  isFollowing = true;
                                  followers++;
                                });
                              },
                              child: Text('Seguir'),
                            ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Divider(),
                    SizedBox(height: 8),
                    StreamBuilder(
                      stream:
                          FirebaseFirestore.instance
                              .collection('posts')
                              .where('uid', isEqualTo: widget.uid)
                              .snapshots(),
                      builder: (
                        context,
                        AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                        snapshot,
                      ) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Erro ao carregar posts: ${snapshot.error}',
                            ),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Text('Nenhum post encontrado :('),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder:
                              (context, index) => Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width >
                                              webScreenSize
                                          ? MediaQuery.of(context).size.width *
                                              0.3
                                          : 0,
                                  vertical:
                                      MediaQuery.of(context).size.width >
                                              webScreenSize
                                          ? 15
                                          : 0,
                                ),
                                child: PostCard(
                                  snap: snapshot.data!.docs[index].data(),
                                ),
                              ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
  }

  Column buildStatColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          num.toString(),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

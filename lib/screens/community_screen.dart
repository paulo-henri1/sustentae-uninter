import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sustentae_uninter/widgets/post_dart.dart';

import '../utils/global_variables.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            MediaQuery.of(context).size.width > webScreenSize
                ? null
                : const Text('Sustentaê'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder(
        stream:
            FirebaseFirestore.instance
                .collection('posts')
                .orderBy('datePublished', descending: true)
                .snapshots(),
        builder: (
          context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder:
                (context, index) => Container(
                  margin: EdgeInsets.symmetric(
                    horizontal:
                        MediaQuery.of(context).size.width > webScreenSize
                            ? MediaQuery.of(context).size.width * 0.3
                            : 0,
                    vertical:
                        MediaQuery.of(context).size.width > webScreenSize
                            ? 15
                            : 0,
                  ),
                  child: PostCard(snap: snapshot.data!.docs[index].data()),
                ),
          );
        },
      ),
    );
  }
}

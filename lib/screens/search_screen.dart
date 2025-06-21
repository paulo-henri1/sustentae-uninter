import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sustentae_uninter/screens/profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final SearchController _searchController = SearchController();
  late String _currentProfileUid;

  @override
  void initState() {
    super.initState();
    _currentProfileUid = FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          // mainAxisSize: MainAxisSize.min,
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SearchAnchor(
                searchController: _searchController,
                builder: (BuildContext context, SearchController controller) {
                  return SearchBar(
                    controller: controller,
                    hintText: 'Procurar por um usuário',
                    padding: const WidgetStatePropertyAll<EdgeInsets>(
                      EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                    onTap: () {
                      controller.openView();
                    },
                    onChanged: (_) {
                      controller.openView();
                      print(_searchController.text);
                    },
                    leading: const Icon(Icons.search),
                    trailing: <Widget>[],
                  );
                },
                suggestionsBuilder: (
                  BuildContext context,
                  SearchController controller,
                ) async {
                  if (controller.text.isEmpty) {
                    if (_currentProfileUid !=
                        FirebaseAuth.instance.currentUser?.uid) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() {
                          _currentProfileUid =
                              FirebaseAuth.instance.currentUser?.uid ?? '';
                        });
                      });
                    }
                    return <Widget>[];
                  }

                  final QuerySnapshot snapshot =
                      await FirebaseFirestore.instance
                          .collection('users')
                          .where(
                            'username',
                            isGreaterThanOrEqualTo: controller.text,
                          )
                          .where(
                            'username',
                            isLessThanOrEqualTo: '${controller.text}\uf8ff',
                          )
                          .limit(10)
                          .get();

                  if (snapshot.docs.isEmpty) {
                    return <Widget>[
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(18.0),
                          child: Text('Nenhum usuário encontrado.'),
                        ),
                      ),
                    ];
                  }

                  return List<Widget>.generate(snapshot.docs.length, (
                    int index,
                  ) {
                    final Map<String, dynamic> doc =
                        snapshot.docs[index].data()! as Map<String, dynamic>;
                    final String username = doc['username'] as String;
                    final String photoUrl = doc['photoUrl'] as String? ?? '';
                    final String uid = doc['uid'] as String;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                        child:
                            photoUrl.isEmpty ? const Icon(Icons.person) : null,
                      ),
                      title: Text(username),
                      onTap: () {
                        setState(() {
                          controller.closeView(username);
                          _currentProfileUid = uid;
                          FocusManager.instance.primaryFocus?.unfocus();
                        });
                      },
                    );
                  });
                },
              ),
            ),
            Expanded(
              child: ProfileScreen(
                key: ValueKey(_currentProfileUid),
                uid: _currentProfileUid,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:sustentae_uninter/resources/firestore_methods.dart';
import 'package:sustentae_uninter/widgets/comment_card.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';

class PostCard extends StatefulWidget {
  final snap;
  const PostCard({super.key, required this.snap});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pt_BR', null);
  }

  @override
  void dispose() {
    super.dispose();
    _commentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<UserProvider>(context).getUser;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(widget.snap['profImage']),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(child: Text(widget.snap['username'])),
                    Text(
                      DateFormat.yMMMd(
                        'pt_BR',
                      ).format(widget.snap['datePublished'].toDate()),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                subtitle: Text(widget.snap['description']),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.snap['postUrl'],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  IconButton(
                    icon:
                        widget.snap['likes'].contains(user.uid)
                            ? const Icon(Icons.favorite)
                            : const Icon(Icons.favorite_outline),
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: () async {
                      await FirestoreMethods().likePost(
                        widget.snap['postId'],
                        user.uid,
                        widget.snap['likes'],
                      );
                    },
                  ),
                  Text(
                    '${widget.snap['likes'].length}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(width: 24),
                  TextButton(
                    child: const Icon(Icons.comment_outlined),
                    onPressed: () {
                      showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        useSafeArea: true,
                        showDragHandle: true,
                        builder: (BuildContext context) {
                          return SizedBox(
                            height: MediaQuery.of(context).size.height * 0.85,
                            child: Column(
                              children: <Widget>[
                                Text('Comentários'),
                                Expanded(
                                  child: StreamBuilder(
                                    stream:
                                        FirebaseFirestore.instance
                                            .collection('posts')
                                            .doc(widget.snap['postId'])
                                            .collection('comments')
                                            .orderBy(
                                              'datePublished',
                                              descending: true,
                                            )
                                            .snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }

                                      return ListView.builder(
                                        itemCount:
                                            (snapshot.data! as dynamic)
                                                .docs
                                                .length,
                                        itemBuilder:
                                            (context, index) => CommentCard(
                                              snap:
                                                  (snapshot.data! as dynamic)
                                                      .docs[index]
                                                      .data(),
                                            ),
                                      );
                                    },
                                  ),
                                ),
                                SafeArea(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: CircleAvatar(
                                          backgroundImage: NetworkImage(
                                            user.photoUrl,
                                          ),
                                          radius: 18,
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0,
                                          ),
                                          child: TextField(
                                            controller: _commentController,
                                            decoration: InputDecoration(
                                              hintText:
                                                  'Adicionar um comentário...',
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: IconButton(
                                          icon: Icon(Icons.send),
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                          onPressed: () async {
                                            await FirestoreMethods()
                                                .postComment(
                                                  widget.snap['postId'],
                                                  _commentController.text,
                                                  user.uid,
                                                  user.username,
                                                  user.photoUrl,
                                                );
                                            setState(() {
                                              _commentController.text = '';
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  //TextButton(child: const Icon(Icons.share), onPressed: () {}),
                  user.uid == widget.snap['uid']
                      ? Row(
                        children: [
                          const SizedBox(width: 8),
                          TextButton(
                            child: const Icon(Icons.delete),
                            onPressed: () {
                              showDeletePostDialog(context).then((value) {
                                if (value) {
                                  FirestoreMethods().deletePost(
                                    widget.snap['postId'],
                                  );
                                }
                              });
                            },
                          ),
                        ],
                      )
                      : SizedBox(),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Future<bool> showDeletePostDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Apagar post!'),
        content: const Text(
          'Você tem certeza que quer deletar esse post permanentemente?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Apagar'),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}

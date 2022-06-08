import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DetailPostPage extends StatelessWidget {
  final User user;
  final DocumentSnapshot document;

  DetailPostPage(this.user, this.document);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('둘러보기'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    print(user.email);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  backgroundImage: NetworkImage(document['userPhotoUrl']),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: [
                          Text(
                            document['email'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          StreamBuilder<DocumentSnapshot>(
                            stream: _followingStream(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Text('로딩중');
                              }

                              var data = snapshot.data!.data();
                              print(data);

                              if (data == null ||
                                  (data as Map)[document['email']] == null ||
                                  data[document['email']] == false) {
                                return GestureDetector(
                                  onTap: _follow,
                                  child: const Text(
                                    '팔로우',
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold),
                                  ),
                                );
                              }
                              return GestureDetector(
                                onTap: _unfollow,
                                child: const Text(
                                  '팔로우 취소',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      Text(document['displayName'])
                    ],
                  ),
                ),
              ],
            ),
          ),
          Hero(tag: document.id, child: Image.network(document['photoUrl'])),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(document['contents']),
          )
        ],
      ),
    );
  }

  void _follow() {
    print('동작?');
    FirebaseFirestore.instance.collection('following').doc(user.email).set(
      {document['email']: true},
      SetOptions(merge: true),
    );

    FirebaseFirestore.instance
        .collection('follower')
        .doc(document['email'])
        .set(
      {user.email.toString(): true},
      SetOptions(merge: true),
    );
  }

  void _unfollow() {
    FirebaseFirestore.instance.collection('following').doc(user.email).set(
      {document['email']: false},
      SetOptions(merge: true),
    );

    FirebaseFirestore.instance
        .collection('follower')
        .doc(document['email'])
        .set(
      {user.email.toString(): false},
      SetOptions(merge: true),
    );
  }

  Stream<DocumentSnapshot> _followingStream() {
    return FirebaseFirestore.instance
        .collection('following')
        .doc(user.email)
        .snapshots();
  }
}

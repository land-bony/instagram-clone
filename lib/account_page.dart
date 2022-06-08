import 'package:firebase_storage/firebase_storage.dart';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountPage extends StatelessWidget {
  final User user;

  AccountPage(this.user);

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppbar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppbar() {
    return AppBar(
      actions: <Widget>[
        IconButton(
          onPressed: () {
            FirebaseAuth.instance.signOut();
            _googleSignIn.signOut();
          },
          icon: const Icon(
            Icons.exit_to_app,
            color: Colors.black,
          ),
        )
      ],
    );
  }

  Widget _buildBody() {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    SizedBox(
                      width: 80.0,
                      height: 80.0,
                      child: GestureDetector(
                        onTap: () => print('이미지 클릭'),
                        child: CircleAvatar(
                          backgroundImage:
                              NetworkImage(user.photoURL.toString()),
                        ),
                      ),
                    ),
                    Container(
                      width: 80.0,
                      height: 80.0,
                      alignment: Alignment.bottomRight,
                      child: Stack(
                        alignment: Alignment.center,
                        children: const <Widget>[
                          SizedBox(
                            width: 28.0,
                            height: 28.0,
                            child: FloatingActionButton(
                              onPressed: null,
                              backgroundColor: Colors.white,
                            ),
                          ),
                          SizedBox(
                            width: 25.0,
                            height: 25.0,
                            child: FloatingActionButton(
                              onPressed: null,
                              backgroundColor: Colors.blue,
                              child: Icon(
                                Icons.add,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Padding(padding: EdgeInsets.all(8.0)),
                Text(
                  user.displayName.toString(),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14.0),
                ),
              ],
            ),
            Container(
              height: 80.0,
              padding: const EdgeInsets.only(top: 10.0),
              child: StreamBuilder<QuerySnapshot>(
                  stream: _postStream(),
                  builder: (context, snapshot) {
                    var post = 0;

                    if (snapshot.hasData) {
                      post = snapshot.data!.docs.length;
                    }

                    return Text(
                      '$post\n게시물',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14.0),
                    );
                  }),
            ),
            Container(
              height: 80.0,
              padding: const EdgeInsets.only(top: 10.0),
              child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: _followerStream(),
                  builder: (context, snapshot) {
                    var follower = 0;

                    if (snapshot.hasData) {
                      Map<String, dynamic>? filterMap;
                      if (snapshot.data!.data() == null) {
                        filterMap = [] as Map<String, dynamic>?;
                      } else {
                        filterMap = snapshot.data!.data();
                        filterMap!.removeWhere((key, value) => value == false);
                        print(filterMap);
                      }
                      follower = filterMap!.length;
                    }

                    return Text(
                      '$follower\n팔로워',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14.0),
                    );
                  }),
            ),
            Container(
              height: 80.0,
              padding: EdgeInsets.only(top: 10.0, right: 10.0),
              child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: _followingStream(),
                  builder: (context, snapshot) {
                    var following = 0;

                    if (snapshot.hasData) {
                      Map<String, dynamic>? filterMap;
                      if (snapshot.data!.data() == null) {
                        filterMap = [] as Map<String, dynamic>?;
                      } else {
                        filterMap = snapshot.data!.data();
                        filterMap!.removeWhere((key, value) => value == false);
                        print(filterMap);
                      }
                      following = filterMap!.length;
                    }

                    return Text(
                      '$following\n팔로잉',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14.0),
                    );
                  }),
            ),
          ],
        ));
  }

  Stream<QuerySnapshot> _postStream() {
    return FirebaseFirestore.instance
        .collection('post')
        .where('email', isEqualTo: user.email)
        .snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> _followingStream() {
    return FirebaseFirestore.instance
        .collection('following')
        .doc(user.email)
        .snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> _followerStream() {
    return FirebaseFirestore.instance
        .collection('follower')
        .doc(user.email)
        .snapshots();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'feed_widget.dart';

class HomePage extends StatelessWidget {
  final User user;

  const HomePage(this.user);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Instagram Cron',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: _buildBody(),
    );
  }
  
  Widget _buildBody() {
    return SafeArea(child: StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('post').snapshots(),
      builder: (context, snapshot) {
        if(!snapshot.hasData){
          return CupertinoActivityIndicator();
        }

        return _buildHasPostBody(snapshot.data!.docs);
      }
    ));
  }

  Widget _buildNoPostBody() {
    return Padding(
        padding: EdgeInsets.all(8.0),
        child: SafeArea(
            child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: <Widget>[
                const Text(
                  'Instagram 오신 것을 환영합니다. ',
                  style: TextStyle(fontSize: 20.0),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                ),
                const Text('사진과 동영상을 보려면 팔로우하세요.'),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                ),
                SizedBox(
                  width: 260.0,
                  child: Card(
                    elevation: 4.0,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            width: 80.0,
                            height: 80.0,
                            child: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(user.photoURL.toString()),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                          ),
                          Text(
                            user.email.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(1.0),
                          ),
                          Text(user.displayName.toString()),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                width: 70.0,
                                height: 70.0,
                                child: Image.network(
                                    'https://dimg.donga.com/wps/NEWS/IMAGE/2019/10/12/97841479.2.jpg',
                                    fit: BoxFit.cover),
                              ),
                              const Padding(
                                padding: EdgeInsets.all(1.0),
                              ),
                              SizedBox(
                                width: 70.0,
                                height: 70.0,
                                child: Image.network(
                                    'https://dimg.donga.com/wps/NEWS/IMAGE/2019/10/12/97841479.2.jpg',
                                    fit: BoxFit.cover),
                              ),
                              const Padding(
                                padding: EdgeInsets.all(1.0),
                              ),
                              SizedBox(
                                width: 70.0,
                                height: 70.0,
                                child: Image.network(
                                    'https://dimg.donga.com/wps/NEWS/IMAGE/2019/10/12/97841479.2.jpg',
                                    fit: BoxFit.cover),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.all(4.0),
                          ),
                          const Text('Facebook 친구'),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                          ),
                          RaisedButton(
                            onPressed: () {},
                            color: Colors.blueAccent,
                            textColor: Colors.white,
                            child: Text('팔로우'),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        )));
  }

  Widget _buildHasPostBody(List<DocumentSnapshot> documents) {
    // 내 게시물 5개
    final myPosts =
        documents.where((doc) => doc['email'] == user.email).take(5).toList();

    // 다른 사람 게시물 10개
    final otherPosts =
        documents.where((doc) => doc['email'] != user.email).take(10).toList();

    // 합치기
    myPosts.addAll(otherPosts);

    return ListView(
      children: myPosts.map((doc) => FeedWidget(doc, user)).toList(),
    );
  }
}

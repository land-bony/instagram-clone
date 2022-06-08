import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'comment_page.dart';

class FeedWidget extends StatefulWidget {
  final DocumentSnapshot document;
  final User user;

  FeedWidget(this.document, this.user);

  @override
  _FeedWidgetState createState() => _FeedWidgetState();
}

class FirebaseUser {}

class _FeedWidgetState extends State<FeedWidget> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var commentCount =
        widget.document.data().toString().contains('commentCount')
            ? widget.document['commentCount']
            : 0;
    return Column(
      children: <Widget>[
        ListTile(
          leading: CircleAvatar(
            backgroundImage:
                NetworkImage(widget.document['userPhotoUrl'].toString()),
          ),
          title: Text(
            widget.document['email'].toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: const Icon(Icons.more_vert),
        ),
        Image.network(
          widget.document['photoUrl'].toString(),
          height: 300,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        ListTile(
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              (widget.document.data().toString().contains('likedUsers')
                              ? widget.document.get('likedUsers')
                              : "")
                          .contains(widget.user.email) ??
                      false
                  ? GestureDetector(
                      onTap: _unlike,
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.red,
                      ),
                    )
                  : GestureDetector(
                      onTap: _like,
                      child: const Icon(Icons.favorite_border),
                    ),
              const SizedBox(
                width: 8.0,
              ),
              const SizedBox(
                width: 8.0,
              ),
              const Icon(Icons.comment),
              const Icon(Icons.send),
            ],
          ),
          trailing: const Icon(Icons.bookmark_border),
        ),
        Row(
          children: <Widget>[
            const SizedBox(
              width: 16.0,
            ),
            Text(
              '좋아요 ${widget.document.data().toString().contains('likedUsers') ? widget.document['likedUsers']?.length : 0}개',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
            ),
          ],
        ),
        const SizedBox(
          height: 8.0,
        ),
        Row(
          children: <Widget>[
            const SizedBox(
              width: 16.0,
            ),
            Text(
              widget.document['email'].toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              width: 8.0,
            ),
            Text(widget.document['contents'].toString()),
          ],
        ),
        const SizedBox(
          height: 8.0,
        ),
        if (commentCount > 0)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CommentPage(widget.document),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        '댓글 $commentCount개 모두 보기',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                  Text(widget.document.data().toString().contains('lastComment')
                      ? widget.document['lastComment']
                      : ''),
                ],
              ),
            ),
          ),
        Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: TextField(
                  controller: _commentController,
                  onSubmitted: (text) {
                    _writeComment(text);
                    _commentController.text = '';
                  },
                  decoration: const InputDecoration(
                    hintText: '댓글 달기',
                  ),
                ),
              ),
            ),
          ],
        ),
        const Divider(),
      ],
    );
  }

  // 좋아요
  void _like() {
    // 기존 좋아요 리스트를 복사
    final List likedUsers = List<String>.from(
        widget.document.data().toString().contains('likedUsers')
            ? widget.document['likedUsers']
            : []);
    likedUsers.add(widget.user.email);

    final updateData = {
      'likedUsers': likedUsers,
    };

    FirebaseFirestore.instance
        .collection('post')
        .doc(widget.document.id)
        .update(updateData);
  }

  // 좋아요 취소
  void _unlike() {
    // 기존 좋아요 리스트를 복사
    final List likedUsers = List<String>.from(
        widget.document.data().toString().contains('likedUsers')
            ? widget.document['likedUsers']
            : []);
    likedUsers.remove(widget.user.email);

    final updateData = {
      'likedUsers': likedUsers,
    };

    FirebaseFirestore.instance
        .collection('post')
        .doc(widget.document.id)
        .update(updateData);
  }

  // 댓글 작성
  void _writeComment(String text) {
    final data = {
      'writer': widget.user.email,
      'comment': text,
    };

    // 댓글 추가
    FirebaseFirestore.instance
        .collection('post')
        .doc(widget.document.id)
        .collection('comment')
        .add(data);

    // 댓글 갯 수
    final updateData = {
      'lastComment': text,
      'commentCount':
          (widget.document.data().toString().contains('commentCount')
                  ? widget.document['commentCount']
                  : 0) +
              1,
    };

    FirebaseFirestore.instance
        .collection('post')
        .doc(widget.document.id)
        .update(updateData);
  }
}

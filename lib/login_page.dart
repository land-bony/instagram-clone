import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatelessWidget {
  // 구글 로그인을 위한 객체
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // 파이어베이스 인증 정보를 가지는 객체
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Instagram Clone',
              style: GoogleFonts.pacifico(fontSize: 40.0),
            ),
            Container(
              margin: const EdgeInsets.all(50.0),
            ),
            SignInButton(Buttons.Google, onPressed: () {
              _handleSignIn();
            })
          ],
        ),
      ),
    );
  }

  // 구글 로그인을 수행하고 FirebaseUser 를 반환
  Future<User?> _handleSignIn() async {
    GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // 구글 로그인으로 인증된 정보를 기반으로 FirebaseUser 객체를 구성
    User? user = (await _auth.signInWithCredential(GoogleAuthProvider.credential(
            idToken: googleAuth?.idToken, accessToken: googleAuth?.accessToken)))
        .user;

    return user;
  }
}

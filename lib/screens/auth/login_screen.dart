import 'package:flutter/material.dart';
import 'login_form.dart';
import 'signup_screen.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("운동 관리 앱", style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LoginForm()),
                );
              },
              child: Text("로그인"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SignupScreen()),
                );
              },
              child: Text("회원가입"),
            ),
          ],
        ),
      ),
    );
  }
}
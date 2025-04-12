import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../workouts/common/workout_selection_screen.dart';

class LoginForm extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void login(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(), 
        password: passwordController.text.trim(),
      );

      // ✅ 로그인 성공하면 LoginForm 화면 닫기 (뒤로가기처럼)
      Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("로그인 실패: ${e.toString()}")),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("로그인")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(controller: emailController, decoration: InputDecoration(labelText: "이메일")),
            TextField(controller: passwordController,decoration: InputDecoration(labelText: "비밀번호"), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => login(context),
              child: Text("로그인"),
            )
          ],
        )
      )
    );
  }
}
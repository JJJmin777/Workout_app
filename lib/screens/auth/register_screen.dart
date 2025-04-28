import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:workout_app/screens/auth/register_success_screen.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  void _register() async {
    try {
      await _authService.signUp(
        email: _emailController.text.trim(), 
        password: _passwordController.text.trim(),
      );

      // 여기서 바로 로그아웃 시킨다!
      await FirebaseAuth.instance.signOut();

      // 그리고 축하 메시지 띄우기
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('🎉 회원가입 완료! 이메일 인증 후 로그인해주세요.')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => RegisterSuccessScreen()),
      ); // 가입 완료 화면으로 이동
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("회원가입 실패: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("회원가입")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: InputDecoration(labelText: "이메일")),
            TextField(controller: _passwordController,decoration: InputDecoration(labelText: "비밀번호"), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: Text("회원가입"),
            )
          ],
        )
      )
    );
  }
}
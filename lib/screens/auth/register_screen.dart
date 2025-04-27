import 'package:flutter/material.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("가입 완료! 이메일 인증 후 로그인해주세요.")),
        );
        Navigator.pop(context); // 로그인 화면으로 이동
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
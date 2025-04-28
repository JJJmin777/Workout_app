import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class RegisterSuccessScreen extends StatelessWidget{
  const RegisterSuccessScreen({super.key});

  void resendEmail(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('인증 이메일을 다시 보냈습니다. 📩'))
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이메일 재발송 실패: $e'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('회원가입 완료')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🎉 회원가입이 완료되었습니다!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text('이메일 인증을 완료한 후 로그인해주세요.', textAlign: TextAlign.center),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => resendEmail(context),
              child: Text('이메일 인증 메일 다시 보내기'),
            ),
            SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              },
              child: Text('로그인 화면으로 가기'),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class RegisterSuccessScreen extends StatelessWidget{
  final String userEmail;
  // const RegisterSuccessScreen({super.key});

  RegisterSuccessScreen({required this.userEmail});

  // void resendEmail(BuildContext context) async {
  //   try {
  //     final user = FirebaseAuth.instance.currentUser;
  //     if (user != null && !user.emailVerified) {
  //       await user.sendEmailVerification();
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('인증 이메일을 다시 보냈습니다. 📩'))
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('이메일 재발송 실패: $e'))
  //     );
  //   }
  // }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text('회원가입 완료')),
    body: Center( // ✅ 화면 전체 중앙 정렬
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center, // ✅ 세로축 중앙
          crossAxisAlignment: CrossAxisAlignment.center, // ✅ 가로축 중앙
          children: [
            Icon(Icons.mark_email_read_rounded, size: 80, color: Colors.deepPurple),
            SizedBox(height: 20),
            Text(
              '$userEmail\n🎉 회원가입이 완료되었습니다!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center, // ✅ 텍스트 중앙 정렬
            ),
            SizedBox(height: 16),
            Text(
              '이메일 인증을 완료한 후 로그인해주세요.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 32),
            ElevatedButton(
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
      ),
    );
  }
}
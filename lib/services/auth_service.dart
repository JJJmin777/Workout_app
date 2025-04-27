import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 회원가입
  Future<void> signUp({required String email, required String password}) async {
    final UserCredential = await _auth.createUserWithEmailAndPassword(
      email: email, 
      password: password,
    );
    await UserCredential.user?.sendEmailVerification(); // 인증 메일 보내기
  }

  // 로그인
  Future<void> login({required String email, required String password}) async {
    final UserCredential = await _auth.signInWithEmailAndPassword(
      email: email, 
      password: password,
    );
    if (!UserCredential.user!.emailVerified) {
      await _auth.signOut();
      throw Exception('이메일 인증이 완료되지 않았습니다.');
    }
  }

  // 인증 메일 다시 보내기
  Future<void> resendVerificationEmail() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  // 로그아웃
  Future<void> logout() async {
    await _auth.signOut();
  }
}


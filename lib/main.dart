import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'screens/login_screen.dart';
import 'screens/workout_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 시스템 준비
  await Firebase.initializeApp(); // Firebase 준비
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '운동 관리 앱',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(), // 로그인 상태 실시간 감지 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // 로딩중
          } else if (snapshot.hasData) {
            return WorkoutSelectionScreen(); // 로그인된 상태
          } else {
            return LoginScreen(); // 로그인 안 됨
          }
        },
      )
    );
  }
}



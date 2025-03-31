import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workout_app/screens/home_screen.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/workout_selection_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 시스템 준비
  await Firebase.initializeApp(); // Firebase 준비
  runApp(MyApp());
}

Future<bool> hasWorkoutProfile() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return false;

  final doc = await FirebaseFirestore.instance
      .collection('workout_profiles')
      .doc(user.uid)
      .get();
  
  return doc.exists;
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
            return Center(child: CircularProgressIndicator()); // 로딩중
          } 
          if (snapshot.hasData) { 
            return FutureBuilder<bool>(
              future: hasWorkoutProfile(), 
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting){
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasData && snapshot.data == true) {
                  return HomeScreen();
                } else {
                  return WorkoutSelectionScreen();
                }
              },
            );
          } else {
            return LoginScreen(); // 로그인 안 됨
          }
        },
      )
    );
  }
}



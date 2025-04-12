import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workout_app/screens/home_screen.dart';

import 'screens/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/workouts/common/workout_selection_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 시스템 준비
  await Firebase.initializeApp(); // Firebase 준비
  runApp(MyApp());
}

Future<bool> hasWorkoutProfile(User user) async {
  final doc = await FirebaseFirestore.instance
      .collection('workout_profiles')
      .doc(user.uid)
      .get();

  print('[DEBUG] 불러온 문서 ID: ${user.uid}');
  print('[DEBUG] 문서 존재 여부: ${doc.exists}');
  print('[DEBUG] 문서 내용: ${doc.data()}');
  
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
        builder: (context, outerSnapshot) {
          if (outerSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // 로딩중
          } 
          if (outerSnapshot.hasData) {
            final user = outerSnapshot.data!; // 로그인된 사용자

            return FutureBuilder<bool>(
              future: hasWorkoutProfile(user),
              builder: (context, profileSnapshot) {
                print('[DEBUG] profileSnapshot.connectionState: ${profileSnapshot.connectionState}');
                print('[DEBUG] profileSnapshot.hasData: ${profileSnapshot.hasData}');
                print('[DEBUG] profileSnapshot.data: ${profileSnapshot.data}');

                // 로딩 중일 땐 아무 것도 렌더하지 않기!
                if (profileSnapshot.connectionState != ConnectionState.done){
                  return Center(child: CircularProgressIndicator());
                }

                if (!profileSnapshot.hasData) {
                  return Center(child: Text("데이터를 불러오지 못했습니다."));
                }

                if (profileSnapshot.data == true) {
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



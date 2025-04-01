import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'workout_selection_screen.dart';
import 'workout_history_screen.dart';

class HomeScreen extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("환영합니다, ${user?.email ?? '사용자'}님"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("오늘 운동을 시작하시겠습니까?", style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 운동 시작 로직 또는 타이머 연결
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => WorkoutSelectionScreen()),
                );
              }, 
              child: Text("운동 시작하기"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // ✅ 수정된 부분: 운동 초기화 후 다시 설문 화면으로 이동
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await FirebaseFirestore.instance
                      .collection('workout_profiles')
                      .doc(user.uid)
                      .delete();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => WorkoutSelectionScreen()),
                  );
                }
              },
              child: Text("운동 다시 설정하기"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => WorkoutHistoryScreen()),
                );
              }, 
              child: Text("운동 기록 보기")
            )
          ],
        ),
      ),
    );
  }
}
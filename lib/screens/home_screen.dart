import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'workout_selection_screen.dart';
import 'workout_history_screen.dart';
import 'workout_timer_screen.dart';

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
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                print("[LOG] 운동 시작 버튼 클릭됨. 사용자: \${user?.email}");
                if (user != null){
                  final doc = await FirebaseFirestore.instance
                      .collection('workout_profiles')
                      .doc(user.uid)
                      .get();
                  if (doc.exists) {
                    final data = doc.data() as Map<String, dynamic>;
                    print("[LOG] 사용자 운동 데이터 로드됨: \${data.toString()}");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WorkoutTimerScreen(
                          workout: data['workout'],
                          durationSeconds: data['level_seconds'],
                        ),
                      ),
                    );
                  } else {
                    print("[LOG] workout_profiles 문서가 존재하지 않음");
                  }
                }
              },
              child: Text("운동 시작하기"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
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
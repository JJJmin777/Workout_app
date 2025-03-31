import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'workout_selection_screen.dart';

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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => WorkoutSelectionScreen()),
                );
              }, 
              child: Text("운동 시작하기"),
            ),
          ],
        ),
      ),
    );
  }
}
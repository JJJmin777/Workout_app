import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:workout_app/main.dart';

class WorkoutSelectionScreen extends StatelessWidget {
  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("로그아웃 되었습니다.")),
    );
    
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => MyApp()), 
      (Route<dynamic> route) => false,
    );
    //  자동으로 로그인 화면으로 이동됨 (main.dart에서 처리)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("운동을 선택하세요"),
        actions: [
          IconButton(
            onPressed: () => logout(context),
            icon: Icon(Icons.logout),
            tooltip: "로그아웃",
          )
        ],
      ),
      body: Center( // <- 화면 중앙 정렬
        child: Column(
          mainAxisSize: MainAxisSize.min, // 중앙 정렬 효과
          children: [
            ElevatedButton(onPressed: () {}, child: Text("런닝")),
            SizedBox(height: 10),
            ElevatedButton(onPressed: () {}, child: Text("계단 오르기")),
            SizedBox(height: 10),
            ElevatedButton(onPressed: () {}, child: Text("플랭크")),
          ],
        ),
      )
    );
  }
}
import 'package:flutter/material.dart';

class WorkoutSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center( // <- 화면 중앙 정렬
        child: Column(
          mainAxisSize: MainAxisSize.min, // 중앙 정렬 효과
          children: [
            Text(
              "운동을 선택하세요",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            ElevatedButton(onPressed: () {}, child: Text("런닝")),
            SizedBox(height: 10),
            ElevatedButton(onPressed: () {}, child: Text("계단 오르기")),
            SizedBox(height: 10),
            ElevatedButton(onPressed: () {}, child: Text("플랭크")),
            SizedBox(height: 10),
          ],
        ),
      )
    );
  }
}
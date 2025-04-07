import 'package:flutter/material.dart';
import 'package:workout_app/screens/plank_questionnaire.dart';
import 'package:workout_app/screens/running_questionnaire.dart';

class WorkoutSelectionScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("운동을 선택하세요")),
      body: Center( // <- 화면 중앙 정렬
        child: Column(
          mainAxisSize: MainAxisSize.min, // 중앙 정렬 효과
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RunningQuestionnaire()),
                );
            }, child: Text("런닝")),
            SizedBox(height: 10),
            ElevatedButton(onPressed: () {}, child: Text("계단 오르기")),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PlankQuestionnaire()),
                );
              }, 
              child: Text("플랭크"),
            ),
          ],
        ),
      )
    );
  }
}
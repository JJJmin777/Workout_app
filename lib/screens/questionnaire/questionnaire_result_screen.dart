import 'package:flutter/material.dart';
import '../home_screen.dart';

class QuestionnaireResultScreen extends StatelessWidget {
  final String workout;
  final String resultText;
  final int levelSeconds;

  QuestionnaireResultScreen({
    required this.workout,
    required this.resultText,
    required this.levelSeconds,
    });

  String formatExerciseAmount(String name, int value){
    switch (name) {
      case "running":
        return "${value}m";
      case "stairs":
        return "${value}층";
      case "plank":
        return '${value}초';
      default:
        return "$value"; // 반드시 String을 return 해야 해서 이 case도 넣엊줘야함
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("추천 결과")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "추천 운동: $workout (${formatExerciseAmount(workout, levelSeconds)})", 
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              resultText,
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => HomeScreen()),
                  (route) => false,
                );
              },
              child: Text("홈으로 가기"),
            )
          ],
        ),
      ),
    );
  }
}
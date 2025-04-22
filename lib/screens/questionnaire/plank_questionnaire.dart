import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'questionnaire_result_screen.dart';
import '../../utils/firestore_helper.dart';

class PlankQuestionnaire extends StatefulWidget{
  @override
  _PlankQuestionnaireState createState() => _PlankQuestionnaireState();
}

class _PlankQuestionnaireState extends State<PlankQuestionnaire> {
  int step = 0;
  String resultText = ""; // 결과 문구를 저장할 변수

  void nextStep(int answer) async {
      if (step == 0) {
        setState(() {
          if (answer == 1) step = 1; // 해봤다
          else step = 2;             // 안 해봤다
        });
      } else if (step == 1) {
        int levelSeconds;
        if (answer == 1 || answer == 2) {
          levelSeconds = 7;
          resultText = "당신의 경험에 따라 7초 플랭크부터 시작해보세요.";
        } else {
          levelSeconds = 60; 
          resultText = "좋아요! 바로 60초 플랭크에 도전해보세요.";
        }

        await saveResultToFirebase(
          workout: "plank",
          levelSeconds: levelSeconds,
        );

        if (!mounted) return; // 페이지가 살아있을 때만 이동
        goToResultScreen(levelSeconds);

      } else if (step == 2) {
        int levelSeconds;
        if (answer == 1 || answer == 2) {
          levelSeconds = 7; 
          resultText = "운동 습관이 적으시군요. 7초부터 천천히 시작해봐요.";
        } else {
          levelSeconds = 15;
          resultText = "운동을 자주 하시네요! 15초 플랭크로 시작해봐요.";
        }

        await saveResultToFirebase(
        workout: "plank",
        levelSeconds: levelSeconds,
        );

        if (!mounted) return;
        goToResultScreen(levelSeconds);
      }
    }
    
  void goToResultScreen(int levelSeconds) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => QuestionnaireResultScreen(
          workout: "plank", 
          resultText: resultText, 
          levelSeconds: levelSeconds,
        ),
      ),
    );
  }
  

  @override
  Widget build(BuildContext context) {
    if (step == 0) {
      return Scaffold(
        appBar: AppBar(title: Text("플랭크")),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("플랭크를 해보셨나요?"),
              ElevatedButton(onPressed: () => nextStep(1), child: Text("네")),
              ElevatedButton(onPressed: () => nextStep(2), child: Text("아니요")),
            ],
          )
        )
      );
    } else if (step == 1) {
      return Scaffold(
        appBar: AppBar(title: Text("플랭크")),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("얼마나 할 수 있나요?"),
              ElevatedButton(onPressed: () => nextStep(1), child: Text("15초")),
              ElevatedButton(onPressed: () => nextStep(2), child: Text("30초")),
              ElevatedButton(onPressed: () => nextStep(3), child: Text("60초")),
            ],
          )
        )
      );
    } else if (step == 2) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("평소 운동을 얼마나 하세요?"),
              ElevatedButton(onPressed: () => nextStep(1), child: Text("주 1회")),
              ElevatedButton(onPressed: () => nextStep(2), child: Text("주 2회")),
              ElevatedButton(onPressed: () => nextStep(3), child: Text("주 3회 이상")),
            ],
          ),
        ),
      );
    } else {
      return SizedBox.shrink(); // 아무것도 안 보이게
    }
  }
}
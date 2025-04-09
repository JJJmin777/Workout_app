import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'questionnaire_result_screen.dart';

class StairsQuestionnaire extends StatefulWidget{
  @override
  _StairsQuestionnaireState createState() => _StairsQuestionnaireState();
}

class _StairsQuestionnaireState extends State<StairsQuestionnaire> {
  int step = 0;

  void nextStep(int answer) {
    setState(() {
      if (step == 0) {
        if (answer == 1) step = 1; // 해봤다
        else step = 2; // 안 해봤다

      } else if (step == 1) {
        if (answer == 1) {
          saveResultToFirebase("stairs", 3, "가볍게 몸을 푸는 계단 루틴");
        } else if (answer == 2) {
          saveResultToFirebase("stairs", 5, "적당한 난이도의 계단 운동");
        } else if (answer == 3) {
          saveResultToFirebase("stairs", 7, "중급자를 위한 계단 오르기 도전");
        }
        step = 3;

      } else if (step == 2) {
        if (answer == 1) {
          saveResultToFirebase("stairs", 3, "처음 시작하는 가벼운 계단 운동");
        } else if (answer == 2) {
          saveResultToFirebase("stairs", 5, "초보자를 위한 계단 오르기 도전");
        } else if (answer == 3) {
          saveResultToFirebase("stairs", 7, "약간 도전적인 초보자 계단 오르기");
        }
        step = 3;
      }
    });
  }

  void saveResultToFirebase(String workout, int levelSeconds, String resultText) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('workout_profiles')
          .doc(user.uid)
          .set({
        'email': user.email,
        'workout': workout,
        'level_seconds': levelSeconds, // 숫자 형식으로 저장 ✅
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 저장 후 홈으로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => QuestionnaireResultScreen(
            workout: workout, 
            levelSeconds:levelSeconds,
            resultText: resultText,
          )
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (step == 0) {
      return Scaffold(
        appBar: AppBar(title: Text("계단 오르기")),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("평소에 계단 오르기를 운동으로 하신 적 있으세요?"),
              ElevatedButton(onPressed: () => nextStep(1), child: Text("네")),
              ElevatedButton(onPressed: () => nextStep(2), child: Text("아니요")),
            ],
          )
        )
      );
    } else if (step == 1) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("쉬지 않고 몇 층을 올라가실 수 있나요?"),
              ElevatedButton(onPressed: () => nextStep(1), child: Text("4층 이하")),
              ElevatedButton(onPressed: () => nextStep(2), child: Text("7층 이하")),
              ElevatedButton(onPressed: () => nextStep(3), child: Text("그 이상")),
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
      return SizedBox.shrink();
    }
  }
}
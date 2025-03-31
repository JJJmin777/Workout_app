import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home_screen.dart';

class PlankQuestionnaire extends StatefulWidget{
  @override
  _PlankQuestionnaireState createState() => _PlankQuestionnaireState();
}

class _PlankQuestionnaireState extends State<PlankQuestionnaire> {
  int step = 0;
  String result = "";

  void nextStep(int answer) {
    setState(() {
      if (step == 0) {
        if (answer == 1) step = 1; // 해봤다
        else step = 2; // 안 해봤다

      } else if (step == 1) {
        if (answer == 1 || answer == 2) {
          result = "오늘은 7초 플랭크를 해보세요!";
          saveResultToFirebase("plank", "7초 추천");
        } else {
          result = "60초 플랭크 도전해보세요!";
          saveResultToFirebase("plank", "60초 추천");
        }
        step = 3;

      } else if (step == 2) {
        if (answer == 1 || answer == 2) {
          result = "오늘은 7초 플랭크를 해보세요!";
          saveResultToFirebase("plank", "7초 추천");
        } else {
          result = "15초 플랭크 도전해보세요!";
          saveResultToFirebase("plank", "15초 추천");
        }
        step = 3;
      }
    });
  }

  void saveResultToFirebase(String workout, String level) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('workout_results')
          .doc(user.uid)
          .set({
        'email': user.email,
        'workout': workout,
        'level': level,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 저장 후 홈으로 이동
      Navigator.pushAndRemoveUntil(
        context, 
        MaterialPageRoute(builder: (_) => HomeScreen()),
        (route) => false,  
      );
    }
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
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(result, style: TextStyle(fontSize: 24)),
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
            ]
          )
        ),
      );
    }
  }
}
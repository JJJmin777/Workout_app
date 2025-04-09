import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'questionnaire_result_screen.dart';

class RunningQuestionnaire extends StatefulWidget{
  @override
  _RunningQuestionnaireState createState() => _RunningQuestionnaireState();
}

class _RunningQuestionnaireState extends State<RunningQuestionnaire> {
  int step = 0;

  void nextStep(int answer) {
    setState(() {
      if (step == 0) {
        if (answer == 1) step = 1; // 해봤다
        else step = 2; // 안 해봤다

      } else if (step == 1) {
        if (answer == 1) {
          saveResultToFirebase("running", 300, "한 트랙정도로 천천히 시작해봐요!");
        } else if (answer == 2) {
          saveResultToFirebase("running", 600, "좋아요! 10분 러닝에 도전해보세요.");
        } else if (answer == 3) {
          saveResultToFirebase("running", 1200, "대단해요! 20분 러닝이 당신에게 딱이에요.");
        }
        step = 3;

      } else if (step == 2) {
        if (answer == 1) {
          saveResultToFirebase("running", 150, "가벼운 러닝부터 시작해보는 건 어때요?");
        } else if (answer == 2) {
          saveResultToFirebase("running", 300, "좋아요! 5분 러닝부터 천천히 도전해봐요.");
        } else if (answer == 3) {
          saveResultToFirebase("running", 400, "운동을 자주 하시는군요! 7분 러닝 도전해보세요.");
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
        appBar: AppBar(title: Text("런닝")),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("런닝을 주로 하세요?"),
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
              Text("쉬지 않고 얼마나 달릴수 있나요?"),
              ElevatedButton(onPressed: () => nextStep(1), child: Text("500m이하")),
              ElevatedButton(onPressed: () => nextStep(2), child: Text("1km이하")),
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
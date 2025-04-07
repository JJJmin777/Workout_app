import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'running_result_screen.dart';

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
        if (answer == 1 || answer == 2) {
          saveResultToFirebase("running", 7, "당신의 경험에 따라 7초 플랭크부터 시작해보세요.");
        } else {
          saveResultToFirebase("running", 60, "좋아요! 바로 60초 플랭크에 도전해보세요.");
        }
        step = 3;

      } else if (step == 2) {
        if (answer == 1 || answer == 2) {
          saveResultToFirebase("running", 7, "운동 습관이 적으시군요. 7초부터 천천히 시작해봐요.");
        } else {
          saveResultToFirebase("running", 15, "운동을 자주 하시네요! 15초 플랭크로 시작해봐요.");
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
        MaterialPageRoute(builder: (_) => PlankResultScreen(resultText: resultText)),
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
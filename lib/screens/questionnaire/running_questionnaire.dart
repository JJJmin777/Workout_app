import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'questionnaire_result_screen.dart';
import '../../utils/firestore_helper.dart';

class RunningQuestionnaire extends StatefulWidget{
  @override
  _RunningQuestionnaireState createState() => _RunningQuestionnaireState();
}

class _RunningQuestionnaireState extends State<RunningQuestionnaire> {
  int step = 0;
  String resultText = "";

  void nextStep(int answer) async {
    if (step == 0) {
      setState(() {
        if (answer == 1) step = 1; // 해봤다
        else step = 2; // 안 해봤다
      });
    } else if (step == 1) {
      int levelSeconds;
      if (answer == 1) {
        levelSeconds = 300;
        resultText = "한 트랙 정도로 천천히 시작해봐요!";
      } else if (answer == 2) {
        levelSeconds = 600;
        resultText = "좋아요! 10분 러닝에 도전해보세요.";
      } else {
        levelSeconds = 1200;
        resultText = "대단해요! 20분 러닝이 당신에게 딱이에요.";
      }

      await saveResultToFirebase(workout: "running", levelSeconds: levelSeconds);

      if (!mounted) return;
      goToResultScreen(levelSeconds);

    } else if (step == 2) {
      int levelSeconds;
      if (answer == 1) {
        levelSeconds = 150;
        resultText = "가벼운 러닝부터 시작해보는 건 어때요?";
      } else if (answer == 2) {
        levelSeconds = 300;
        resultText = "좋아요! 5분 러닝부터 천천히 도전해봐요.";
      } else {
        levelSeconds = 400;
        resultText = "운동을 자주 하시는군요! 7분 러닝 도전해보세요.";
      }

      await saveResultToFirebase(workout: "running", levelSeconds: levelSeconds);

      if (!mounted) return;
      goToResultScreen(levelSeconds);
    }
  }

  void goToResultScreen(int levelSeconds) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => QuestionnaireResultScreen(
          workout: "running",
          levelSeconds: levelSeconds,
          resultText: resultText,
        ),
      ),
    );
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
              Text("러닝을 주로 하세요?"),
              ElevatedButton(onPressed: () => nextStep(1), child: Text("네")),
              ElevatedButton(onPressed: () => nextStep(2), child: Text("아니요")),
            ],
          ),
        ),
      );
    } else if (step == 1) {
      return Scaffold(
        appBar: AppBar(title: Text("런닝")),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("쉬지 않고 얼마나 달릴 수 있나요?"),
              ElevatedButton(onPressed: () => nextStep(1), child: Text("500m 이하")),
              ElevatedButton(onPressed: () => nextStep(2), child: Text("1km 이하")),
              ElevatedButton(onPressed: () => nextStep(3), child: Text("그 이상")),
            ],
          ),
        ),
      );
    } else if (step == 2) {
      return Scaffold(
        appBar: AppBar(title: Text("런닝")),
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

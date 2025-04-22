import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'questionnaire_result_screen.dart';
import '../../../utils/firestore_helper.dart';

class StairsQuestionnaire extends StatefulWidget {
  @override
  _StairsQuestionnaireState createState() => _StairsQuestionnaireState();
}

class _StairsQuestionnaireState extends State<StairsQuestionnaire> {
  int step = 0;
  String resultText = "";

  void nextStep(int answer) async {
    if (step == 0) {
      setState(() {
        if (answer == 1) step = 1;
        else step = 2;
      });

    } else if (step == 1) {
      int levelFloors;
      if (answer == 1) {
        levelFloors = 3;
        resultText = "가볍게 몸을 푸는 계단 루틴!";
      } else if (answer == 2) {
        levelFloors = 5;
        resultText = "적당한 난이도의 계단 운동에 도전해봐요.";
      } else {
        levelFloors = 7;
        resultText = "중급자를 위한 계단 오르기 도전!";
      }

      await saveResultToFirebase(workout: "stairs", levelSeconds: levelFloors);

      if (!mounted) return;
      goToResultScreen(levelFloors);

    } else if (step == 2) {
      int levelFloors;
      if (answer == 1) {
        levelFloors = 3;
        resultText = "처음 시작하는 가벼운 계단 운동이에요.";
      } else if (answer == 2) {
        levelFloors = 5;
        resultText = "초보자를 위한 계단 오르기에 도전해봐요.";
      } else {
        levelFloors = 7;
        resultText = "약간 도전적인 초보자용 계단 운동!";
      }

      await saveResultToFirebase(workout: "stairs", levelSeconds: levelFloors);

      if (!mounted) return;
      goToResultScreen(levelFloors);
    }
  }

  void goToResultScreen(int levelSeconds) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => QuestionnaireResultScreen(
          workout: "stairs",
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
        appBar: AppBar(title: Text("계단 오르기")),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("평소에 계단 오르기를 운동으로 하신 적 있으세요?"),
              ElevatedButton(onPressed: () => nextStep(1), child: Text("네")),
              ElevatedButton(onPressed: () => nextStep(2), child: Text("아니요")),
            ],
          ),
        ),
      );
    } else if (step == 1) {
      return Scaffold(
        appBar: AppBar(title: Text("계단 오르기")),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("쉬지 않고 몇 층을 올라가실 수 있나요?"),
              ElevatedButton(onPressed: () => nextStep(1), child: Text("4층 이하")),
              ElevatedButton(onPressed: () => nextStep(2), child: Text("7층 이하")),
              ElevatedButton(onPressed: () => nextStep(3), child: Text("그 이상")),
            ],
          ),
        ),
      );
    } else if (step == 2) {
      return Scaffold(
        appBar: AppBar(title: Text("계단 오르기")),
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
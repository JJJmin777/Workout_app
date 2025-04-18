import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'questionnaire_result_screen.dart';

class PlankQuestionnaire extends StatefulWidget{
  @override
  _PlankQuestionnaireState createState() => _PlankQuestionnaireState();
}

class _PlankQuestionnaireState extends State<PlankQuestionnaire> {
  int step = 0;

  void nextStep(int answer) {
    setState(() {
      if (step == 0) {
        if (answer == 1) step = 1; // 해봤다
        else step = 2; // 안 해봤다

      } else if (step == 1) {
        if (answer == 1 || answer == 2) {
          saveResultToFirebase("plank", 7, "당신의 경험에 따라 7초 플랭크부터 시작해보세요.");
        } else {
          saveResultToFirebase("plank", 60, "좋아요! 바로 60초 플랭크에 도전해보세요.");
        }
        step = 3;

      } else if (step == 2) {
        if (answer == 1 || answer == 2) {
          saveResultToFirebase("plank", 7, "운동 습관이 적으시군요. 7초부터 천천히 시작해봐요.");
        } else {
          saveResultToFirebase("plank", 15, "운동을 자주 하시네요! 15초 플랭크로 시작해봐요.");
        }
        step = 3;
      }
    });
  }

  void saveResultToFirebase(String workout, int levelSeconds, String resultText) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final profileRef = FirebaseFirestore.instance.collection('workout_profiles').doc(user.uid);
    final snapshot = await profileRef.get();

    List<Map<String, dynamic>> updatedWorkouts = [];

    if (snapshot.exists && snapshot.data()?['workouts'] != null) {
      final current = snapshot.data()!['workouts'] as List<dynamic>;

      // 이미 있는 workout이면 덮어쓰기, 없으면 그대로
      updatedWorkouts = current.map<Map<String, dynamic>>((w) {
        if (w['workout'] == workout) {
          return {
            'workout': workout,
            'level_seconds': levelSeconds, // 업데이트된 값으로 교체
          };
        }
        return Map<String, dynamic>.from(w);
      }).toList();

      // 새 workout이 없다면 추가
      final exists = current.any((w) => w['workout'] == workout);
      if (!exists) {
        updatedWorkouts.add({
          'workout': workout,
          'level_seconds': levelSeconds,
        });
      }
    } else {
    updatedWorkouts = [
      {
        'workout': workout,
        'level_seconds': levelSeconds,
      }
    ];
  }

    // Firebase 저장 (문서 전체 업데이트)
    await profileRef.set({
      'email': user.email,
      'workouts': updatedWorkouts,
      'timestamp': FieldValue.serverTimestamp(),
    });

    if (!mounted) return; // ← 비동기 처리 중 화면이 dispose된 경우 방지

    // 저장 후 홈으로 이동
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => QuestionnaireResultScreen(
          workout: workout, 
          levelSeconds:levelSeconds,
          resultText: resultText,
        )
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
      return SizedBox.shrink();
    }
  }
}
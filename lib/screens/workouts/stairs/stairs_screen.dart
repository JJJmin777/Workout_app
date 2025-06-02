import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workout_app/main.dart';


class StairsTimerScreen extends StatefulWidget{
  final String workout;
  final int targetfloors;

  StairsTimerScreen({required this.workout, required this.targetfloors});

  @override
  _StairsTimerScreenState createState() => _StairsTimerScreenState();
}

class _StairsTimerScreenState extends State<StairsTimerScreen> {
  bool hasStarted = false;

  void saveWorkout() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('workout_logs').add({
        'userId': user.uid,
        'workout': widget.workout,
        'workoutValue': widget.targetfloors,
        'date': FieldValue.serverTimestamp(),
      });

      showDialog(
        context: context, 
        builder: (_) => AlertDialog(
          title: Text("운동 완료!"),
          content: Text("${widget.targetfloors}층을 오르셨습니다. 수고하셨어요!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context, 
                  MaterialPageRoute(builder: (_) => MainScaffold()),
                  (route) => false  
                );
              }, 
              child: Text("홈으로 가기"),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("계단 오르기")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("오늘의 목표: ${widget.targetfloors}층 오르기!", style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            if (!hasStarted)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    hasStarted = true;
                  });
                },
                child: Text("운동 시작하기"),
              )
            else
              Column(
                children: [
                  Icon(Icons.directions_walk, size: 100, color: Colors.deepPurple),
                  SizedBox(height: 20),
                  Text("운동 중입니다..."),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: saveWorkout,
                    child: Text("운동 완료"),
                  )
                ],
              )
          ],
        ),
      ),
    );
  }
}
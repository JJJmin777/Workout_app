import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workout_app/main.dart';

class PlankScreen extends StatefulWidget{
  final String workout;
  final int targetSeconds;

  PlankScreen({required this.workout, required this.targetSeconds});

  @override
  _PlankScreenState createState() => _PlankScreenState();
}

class _PlankScreenState extends State<PlankScreen> {
  late int remainingSeconds;
  Timer? timer;
  bool isRunning = false;

  @override
  void initState() {
    super.initState();
    remainingSeconds = widget.targetSeconds;
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (t) {  // t는 타이머 객체로 콜백 함수 호출??
      setState(() {
        if (remainingSeconds > 0) {
          remainingSeconds--;
        } else {
          t.cancel();
          saveWorkout();
        }
      });
    });
  }

  void toggleTimer() {
    if (isRunning) {
      timer?.cancel();
    } else {
      startTimer();
    }
    setState(() {
      isRunning = !isRunning;
    });
  }

  void saveWorkout() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('workout_logs').add({
        'userId': user.uid,
        'workout': widget.workout,
        'time_seconds': widget.targetSeconds,
        'workoutValue': widget.targetSeconds,
        'date': FieldValue.serverTimestamp(),
      });

      showDialog(
        context: context, 
        builder: (_) => AlertDialog(
          title: Text("운동 완료!"),
          content: Text("오늘의 운동이 완료되었습니다."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context, 
                  MaterialPageRoute(builder: (_) => MainScaffold()),
                  (route) => false  
                );
              }, 
              child: Text("확인"),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String formatTime(int seconds) {
      final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
      final secs = (seconds % 60).toString().padLeft(2, '0'); // padLeft 5초를 -> 05초로 해줌
      return "$minutes.$secs";
    }

    return Scaffold(
      appBar: AppBar(title: Text("${widget.workout} 타이머")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer, size: 100, color: Colors.blue),
            SizedBox(height: 20),
            Text(formatTime(remainingSeconds), style: TextStyle(fontSize: 48)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: toggleTimer,
              child: Text(isRunning ? "Stop" : "Start"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel(); // 타이머가 남아 있다면 꺼줌
    super.dispose(); // Flutter가 자체 정리도 하도록 호출
  }
}
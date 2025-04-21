import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workout_app/main.dart';


class RunningScreen extends StatefulWidget {
  final String workout;
  final int targetDistance;

  RunningScreen({required this.workout, required this.targetDistance});

  @override
  _RunningScreenState createState() => _RunningScreenState();
}

class _RunningScreenState extends State<RunningScreen> {
  int elapsedSeconds = 0;
  Timer? timer;
  bool isRunning = false;

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (t) {
      setState(() {
        elapsedSeconds++;
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
        'duration': widget.targetDistance,
        'time_seconds': elapsedSeconds,
        'date': FieldValue.serverTimestamp(),
      });

      showDialog(
        context: context, 
        builder: (_) => AlertDialog(
          title: Text("운동 완료!"),
          content: Text("${widget.targetDistance}m 러닝 완료!. 소요 시간: ${formatTime(elapsedSeconds)}수고하셨어요!"),
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
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("러닝")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.directions_run, size: 100, color: Colors.orange,),
            SizedBox(height: 20),
            Text("목표 거리: ${widget.targetDistance}m", style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text("경과 시간: ${formatTime(elapsedSeconds)}", style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: toggleTimer,
              child: Text(isRunning ? "Stop" : "Start"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                timer?.cancel();
                saveWorkout();
              },
              child: Text("운동 완료"),
            ),
          ],
        ),
      ),
    );
  }
}
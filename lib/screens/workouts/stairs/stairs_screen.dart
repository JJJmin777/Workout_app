import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workout_app/main.dart';

import 'package:workout_app/utils/workout_timer.dart';  // 타이머 임포트


class StairsTimerScreen extends StatefulWidget{
  final String workout;
  final int targetfloors;

  const StairsTimerScreen({
    Key? key,
    required this.workout,
    required this.targetfloors
  }) : super(key: key);

  @override
  _StairsTimerScreenState createState() => _StairsTimerScreenState();
}

class _StairsTimerScreenState extends State<StairsTimerScreen> {
  late WorkoutTimer _timer;
  bool isRunning = false;

  @override
  void initState() {
    super.initState();
    _timer = WorkoutTimer(onTick: (_) {
      setState(() {}); // 시간 갱신
    });
  }

  void toggleStair() {
    if (isRunning) {
      _timer.stop();
    } else {
      _timer.start();
    }
    setState(() {
      isRunning = !isRunning;
    });
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  @override
  void dispose() {
    _timer.dispose();
    super.dispose();
  }

  void saveWorkout() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('workout_logs').add({
        'userId': user.uid,
        'workout': widget.workout,
        'time_seconds': _timer.elapsedSeconds, // 경과 시간
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
            SizedBox(height: 10),
            Text("경과 시간: ${_formatTime(_timer.elapsedSeconds)}"),
            SizedBox(height: 20),

            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isRunning) ...[
                  Icon(Icons.directions_walk, size: 100, color: Colors.deepPurple),
                  SizedBox(height: 20),
                  Text("운동 중입니다...", style: TextStyle(fontSize: 18)),
                  SizedBox(height: 30),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: toggleStair,
                      child: Text(isRunning ? 'Stop' : 'Start'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (isRunning) toggleStair();
                        saveWorkout();
                      },
                      child: const Text('운동 완료'),
                    ),
                  ],
                ),
              ],
            )
            

            // if (!hasStarted)
            //   ElevatedButton(
            //     onPressed: () {
            //       _timer.start();
            //       setState(() {
            //         hasStarted = true;
            //       });
            //     },
            //     child: Text("운동 시작하기"),
            //   )
            // else
            //   Column(
            //     children: [
            //       Icon(Icons.directions_walk, size: 100, color: Colors.deepPurple),
            //       SizedBox(height: 20),
            //       Text("운동 중입니다..."),
            //       SizedBox(height: 30),
            //       ElevatedButton(
            //         onPressed: () {
            //           _timer.stop();
            //           saveWorkout();
            //         },
            //         child: Text("운동 완료"),
            //       )
            //     ],
            //   )
          ],
        ),
      ),
    );
  }
}
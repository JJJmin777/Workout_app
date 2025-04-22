import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../utils/firestore_helper.dart';
import '../../../utils/workout_helper.dart';

class WorkoutEditScreen extends StatefulWidget {
  @override
  _WorkoutEditScreenState createState () => _WorkoutEditScreenState();
}

class _WorkoutEditScreenState extends State<WorkoutEditScreen> {
  final user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic> workouts = {}; // 운동 데이터

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final data = await loadWorkoutProfile(); // utils 함수 사용
    if (data != null && data.containsKey('workouts')) { // ✅ workouts 키 있는지 확인
    setState(() {
      workouts = Map<String, dynamic>.from(data['workouts']);
    });
    } else {
      print('[DEBUG] workout_profiles에 workouts 키가 없습니다.');
    }
  }

  Future<void> saveChanges() async {
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('workout_profiles')
          .doc(user!.uid)
          .update({'workouts': workouts});
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('운동 설정이 저장되었습니다.')),
      );
      Navigator.pop(context); // 저장하고 돌아가기
    }
  }

  @override
  Widget build(BuildContext context) {
    if (workouts.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('운동 설정 변경')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('운동 설정 변경')),
      body: ListView(
        children: workouts.entries.map((entry) {
          final workout = entry.key;
          final value = entry.value['level_seconds'];
          final info = getWorkoutInfo(workout);

          return ListTile(
            leading: Icon(info.icon, color: Colors.blueAccent),
            title: Text('$workout 설정'),
            subtitle: TextField(
              keyboardType: TextInputType.number,
              controller: TextEditingController(text: value.toString()),
              onChanged: (val) {
                setState(() {
                  workouts[workout]['level_seconds'] = int.tryParse(val) ?? 0;
                });
              },
              decoration: InputDecoration(
                labelText: '수정할 값 (${info.unit})',
              ),
            ),
          );
        }).toList(),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: saveChanges,
          child: Text('저장하기'),
        ), 
      ),
    );
  }
}
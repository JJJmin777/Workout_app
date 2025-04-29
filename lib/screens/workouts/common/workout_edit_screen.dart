import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workout_app/main.dart';
import '../../../utils/firestore_helper.dart';
import '../../../utils/workout_helper.dart';

class WorkoutEditScreen extends StatefulWidget {
  @override
  _WorkoutEditScreenState createState () => _WorkoutEditScreenState();
}

class _WorkoutEditScreenState extends State<WorkoutEditScreen> {
  final user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic> workouts = {}; // 운동 데이터
  final Map<String, int> defaultValues = {
    'plank': 30,
    'running': 300,
    'stairs': 5,
  };

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
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => MainScaffold()),
        (route) => false,
      ); // 저장하고 돌아가기
    }
  }

  void addWorkout(String type) {
    if (!workouts.containsKey(type)) {
      setState(() {
        workouts[type] = {'level_seconds': defaultValues[type]!};
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$type 운동은 이미 추가되어 있습니다.')),
      );
    }
  }

  void _showWorkoutAddDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("추가할 운동 선택"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!workouts.containsKey('plank'))
              ElevatedButton(
                    onPressed: () {
                      addWorkout('plank');  
                      Navigator.pop(context);
                    },
                    child: Text('플랭크 추가')),
            if (!workouts.containsKey('running'))
              ElevatedButton(
                onPressed: () {
                  addWorkout('running');
                  Navigator.pop(context);
                },
                child: Text('러닝 추가')),
            if (!workouts.containsKey('stairs'))
              ElevatedButton(
                onPressed: () {
                  addWorkout('stairs');
                  Navigator.pop(context);
                },
                child: Text('계단 추가')),
          ],
        ),
      ),
    );
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(title: Text('운동 설정 변경')),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 20),
          children: workouts.entries.map((entry) {
            final workout = entry.key;
            final value = entry.value['level_seconds'];
            final info = getWorkoutInfo(workout);

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(info.icon, size: 36, color: Colors.deepPurple),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: TextEditingController(text: value.toString()),
                        onChanged: (val) {
                          setState(() {
                            workouts[workout]['level_seconds'] = int.tryParse(val) ?? 0;
                          });
                        },
                        decoration: InputDecoration(
                        labelText: '$workout 설정 (${info.unit})',
                        labelStyle: TextStyle(color: Colors.deepPurple), // 라벨 색상
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.deepPurple), // 테두리 색상
                        ),
                        focusedBorder: OutlineInputBorder( // 포커스됐을 때 테두리 색
                          borderSide: BorderSide(color: Colors.deepPurple, width: 2.0),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        workouts.remove(workout);
                      });
                    },
                  )
                ],
              ), 
            ),
          );
        }).toList(),
      ),
    ),
    bottomNavigationBar: Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: saveChanges,
        child: Text('저장하기'),
        style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 48)),
      ),
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _showWorkoutAddDialog,
      label: Text("운동 추가"),
      icon: Icon(Icons.add),
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
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
  Map<String, dynamic> workouts = {}; // 운동 데이터

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final data = await loadWorkoutProfile(); // utils 함수 사용
    if (data != null) {
      setState(() {
        workouts = Map<String, dynamic>.from(data['workouts']);
      });
    }
  }

  Future<void> saveChanges() async {
    if (user != null) {
      
    }
  }
}
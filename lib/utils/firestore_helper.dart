import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 데이터 저장
Future<void> saveResultToFirebase({
  required String workout, 
  required int levelSeconds,
}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final profileRef = FirebaseFirestore.instance.collection('workout_profiles').doc(user.uid);
    final snapshot = await profileRef.get();

    Map<String, dynamic> updatedWorkouts = {};

    if (snapshot.exists && snapshot.data()?['workouts'] != null) {
      final current = Map<String, dynamic>.from(snapshot.data()!['workouts']);

      current[workout] = {
        'level_seconds': levelSeconds,
      };
      
      updatedWorkouts = current;
    } else {
      updatedWorkouts = {
      workout: {'level_seconds': levelSeconds}
    };
  }

  // Firebase 저장 (문서 전체 업데이트)
  await profileRef.set({
    'email': user.email,
    'workouts': updatedWorkouts,
    'timestamp': FieldValue.serverTimestamp(),
  });
}

/// workout_profiles에서 현재 사용자 운동 데이터 불러오기
Future<Map<String, dynamic>?> loadWorkoutProfile() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    final doc = await FirebaseFirestore.instance
        .collection('workout_profiles')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    }
  }
  return null;
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
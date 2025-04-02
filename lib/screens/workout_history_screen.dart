import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class WorkoutHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text("운동 기록 보기")),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('workout_logs')
            .where('userId', isEqualTo: user?.uid)
            .orderBy('date', descending: true)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            print("[DEBUG] 불러온 문서 수: ${snapshot.data?.docs.length ?? 0}");
            return Center(child: Text("운동 기록이 없습니다."));
          }

          final logs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final data = logs[index].data() as Map<String, dynamic>;
              final date = (data['date'] as Timestamp).toDate();
              final formattedDate = DateFormat('yyyy-MM-dd').format(date);

              return ListTile(
                leading: Icon(Icons.fitness_center),
                title: Text("운동: ${data['workout']}"),
                subtitle: Text("시간: ${data['duration']}초\n날짜: $formattedDate"),
              );
            }
          );
        },
      ),
    );
  }
}
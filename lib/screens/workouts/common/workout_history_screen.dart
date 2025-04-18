import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class WorkoutHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text("운동 기록")),
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
            return Center(child: Text("운동 기록이 없습니다.\n오늘 새로운 기록을 남겨보세요! 😊", textAlign: TextAlign.center));
          }

          final logs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final data = logs[index].data() as Map<String, dynamic>;
              final date = (data['date'] as Timestamp).toDate();
              final formattedDate = DateFormat('yyyy-MM-dd').format(date);

              final workoutType = data['workout'] ?? '운동';
              final duration = data['duration'] ?? 0;

              IconData icon;
              String unit;
              if (workoutType == 'plank') {
                icon = Icons.self_improvement;
                unit = "초";
              } else if (workoutType == 'running') {
                icon = Icons.directions_run;
                unit = "m";
              } else if (workoutType == 'stairs') {
                icon = Icons.stairs;
                unit = "층";
              } else {
                icon = Icons.fitness_center;
                unit = "단위";
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  child: ListTile(
                    leading: Icon(icon, size: 40, color: Colors.deepPurple),
                    title: Text(
                      workoutType,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Text(
                      "운동량: $duration$unit\n날짜: $formattedDate",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
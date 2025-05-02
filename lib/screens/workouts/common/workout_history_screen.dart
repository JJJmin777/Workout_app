import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../../utils/workout_helper.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  @override
  _WorkoutHistoryScreenState createState() => _WorkoutHistoryScreenState();
  }



class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text("운동 기록"),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: _pickDate,
            tooltip: "날짜로 검색",
          ),
          if (_selectedDate != null)
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _selectedDate = null;
                });
              },
              tooltip: "검색 해제",
            ),
        ],
      ),
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

          // 날짜별 그룹화
          final Map<String, List<Map<String, dynamic>>> groupedLogs = {};

          for (var doc in logs) {
            final data = doc.data() as Map<String, dynamic>;
            final date = (data['date'] as Timestamp).toDate();
            final formattedDate = DateFormat('yyyy-MM-dd').format(date);

            if (groupedLogs.containsKey(formattedDate)) {
              groupedLogs[formattedDate]!.add(data);
            } else {
              groupedLogs[formattedDate] = [data];
            }
          }

          final sortedDates = groupedLogs.keys.toList()..sort((a, b) => b.compareTo(a));

          // 날짜 필터링
          final filteredDates = _selectedDate == null
            ? sortedDates
            : sortedDates.where((d) => d == DateFormat('yyyy-MM-dd').format(_selectedDate!)).toList();

          if (filteredDates.isEmpty) {
            return Center(
              child: Text(
                "선택한 날짜에 운동 기록이 없습니다.\n운동하고 기록을 남겨보세요! 🏃‍♂️",
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            itemCount: filteredDates.length,
            itemBuilder: (context, index) {
              final date = filteredDates[index];
              final dayLogs = groupedLogs[date]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    date,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                    ),
                  ),
                  ...dayLogs.map((data) {
                    final workoutType = data['workout'] ?? '운동';
                    final workoutValue = data['workoutValue'] ?? 0;

                    final info = getWorkoutInfo(workoutType);

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                        child: ListTile(
                          leading: Icon(info.icon, size: 36, color: Colors.deepPurple),
                          title: Text(workoutType),
                          subtitle: Text("운동량: $workoutValue${info.unit}"),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023), 
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
}
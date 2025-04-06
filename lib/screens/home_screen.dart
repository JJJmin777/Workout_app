import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';
import 'workout_selection_screen.dart';
import 'workout_history_screen.dart';
import 'workout_timer_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<String>> workoutEvents = {};

  @override
  void initState() {
    super.initState();
    fetchWorkoutDates();
  }

  // ✅ Firestore에서 운동 기록 불러오기
  Future<void> fetchWorkoutDates() async {
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('workout_logs')
        .where('userId', isEqualTo: user!.uid)
        .get();

    Map<DateTime, List<String>> events = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final workoutName = data['workout'] ?? '운동';
      final timestamp = data['timestamp'] as Timestamp?;
      if (timestamp != null) {
        final date = DateTime(timestamp.toDate().year, timestamp.toDate().month, timestamp.toDate().day);
        events.update(
          date, 
          (value) => [...value, workoutName], // value가 있으면 복사한뒤 workoutName을 저장
          ifAbsent: () => [workoutName]
        );
      }
    }

    setState(() {
      workoutEvents = events;
    });
  }

  List<String> getEventsForDay(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    return workoutEvents[normalized] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("환영합니다, ${user?.email ?? '사용자'}님"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 달력
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selected, focused) {
                setState((){
                  _selectedDay = selected;
                  _focusedDay = focused;
                });
              },
              eventLoader: getEventsForDay,
              calendarStyle: CalendarStyle(
                markerDecoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (_selectedDay != null)
              ...getEventsForDay(_selectedDay!).map((e) => ListTile(title: Text("운동: $e"))),

            const SizedBox(height: 20),
            Text("오늘 운동을 시작하시겠습니까?", style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                print("[LOG] 운동 시작 버튼 클릭됨. 사용자: \${user?.email}");
                if (user != null){
                  final doc = await FirebaseFirestore.instance
                      .collection('workout_profiles')
                      .doc(user.uid)
                      .get();
                  if (doc.exists) {
                    final data = doc.data() as Map<String, dynamic>;
                    print("[LOG] 사용자 운동 데이터 로드됨: \${data.toString()}");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WorkoutTimerScreen(
                          workout: data['workout'],
                          durationSeconds: data['level_seconds'],
                        ),
                      ),
                    );
                  } else {
                    print("[LOG] workout_profiles 문서가 존재하지 않음");
                  }
                }
              },
              child: Text("운동 시작하기"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await FirebaseFirestore.instance
                      .collection('workout_profiles')
                      .doc(user.uid)
                      .delete();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => WorkoutSelectionScreen()),
                  );
                }
              },
              child: Text("운동 다시 설정하기"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => WorkoutHistoryScreen()),
                );
              }, 
              child: Text("운동 기록 보기")
            )
          ],
        ),
      ),
    );
  }
}
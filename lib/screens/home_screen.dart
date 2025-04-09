import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';
import 'workouts/common/workout_selection_screen.dart';
import 'workouts/common/workout_history_screen.dart';
import 'workouts/plank/plnak_timer_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? workoutData;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> workoutEvents = {};

  @override
  void initState() {
    super.initState();
    loadWorkoutProfile();
    fetchWorkoutDates();
  }

  // ✅ Firestore에서 저장된 운동 불러오기
  Future<void> loadWorkoutProfile() async {
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('workout_profiles')
          .doc(user!.uid)
          .get();
      
      if (doc.exists) {
        setState(() {
          workoutData = doc.data() as Map<String, dynamic>;
        });
      }
    }
  }

  // ✅ Firestore에서 운동 기록 불러오기
  Future<void> fetchWorkoutDates() async {
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('workout_logs')
        .where('userId', isEqualTo: user!.uid)
        .get();

    Map<DateTime, List<Map<String, dynamic>>> events = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final workoutName = data['workout'] ?? '운동';
      final duration = data['duration'] ?? 0;
      final timestamp = data['date'] as Timestamp?;
      if (timestamp != null) {
        final date = DateTime(timestamp.toDate().year, timestamp.toDate().month, timestamp.toDate().day);
        events.update(
          date, 
          (value) => [...value, {'workout': workoutName, 'duration': duration}], // value가 있으면 복사한뒤 workoutName을 저장
          ifAbsent: () => [{'workout': workoutName, 'duration': duration}]
        );
      }
    }

    setState(() {
      workoutEvents = events;
      print('[DEBUG] 운동 기록 불러오기 완료: $workoutEvents');
    });
  }

  List<Map<String, dynamic>> getEventsForDay(DateTime day) {
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
      body: SingleChildScrollView(
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
                markerSize: 6.0, // 마커 크기
                markersMaxCount: 3, // 한 날짜에 최대 몇 개까지 표시할지
              ),
            ),
            const SizedBox(height: 8),
            if (_selectedDay != null)
              ...getEventsForDay(_selectedDay!).map((e) {
                final workout = e['workout'];
                final duration = e['duration'];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    color: Colors.white,
                    child: ListTile(
                      leading: Icon(Icons.fitness_center, color: Colors.deepPurple),
                      title: Text(
                        "운동: $workout",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("소요 시간: $duration초"),
                    ),
                  ),
                );
              }),

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
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
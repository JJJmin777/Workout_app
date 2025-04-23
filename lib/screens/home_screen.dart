import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:workout_app/screens/workouts/common/workout_edit_screen.dart';
import 'package:workout_app/utils/firestore_helper.dart';
import 'workouts/common/workout_selection_screen.dart';
import 'workouts/common/workout_history_screen.dart';

import 'workouts/plank/plnak_screen.dart';
import 'workouts/stairs/stairs_screen.dart';
import 'workouts/running/running_screen.dart';
import '../utils/workout_helper.dart';

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
    loadProfile();
    _selectedDay = DateTime.now(); // 처음에 오늘 날짜로 선택
    fetchWorkoutDates();
  }

  // ✅ Firestore에서 저장된 운동 불러오기
  Future<void> loadProfile() async {
    final data = await loadWorkoutProfile(); // utils 함수 사용
    if (data != null) {
      setState(() {
        workoutData = data;
      });
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

  String getUnit(String workout) {
    if (workout == "plank") return "초";
    if (workout == "running") return "m";
    if (workout == "stairs") return "층";
    return '';
  }

  void startWorkoutSequence(Map<String, dynamic> workoutsMap) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // 오늘 한 운동 불러오기
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    final snapshot = await FirebaseFirestore.instance
        .collection('workout_logs')
        .where('userId', isEqualTo: user.uid)
        .where('date', isGreaterThanOrEqualTo: todayStart)
        .get();

    final doneToday = snapshot.docs.map((doc) => doc['workout'] as String).toSet();

    final remainingWorkouts = workoutsMap.entries
      .where((e) => !doneToday.contains(e.key))
      .map((e) => {'workout': e.key, 'level_seconds': e.value['level_seconds']})
      .toList();

    if (remainingWorkouts.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("운동 완료!"),
          content: Text("오늘의 모든 운동을 완료하셨습니다! 👏"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("확인"),
            ),
          ],
        ),
      );
      return;
    }

    // 운동 버튼들을 보여주는 화면으로 이동
    showModalBottomSheet(
      context: context,
      builder: (_) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(16),
        children: [
          Text("오늘 남은 운동을 선택하세요:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ...remainingWorkouts.map((w) {
            final workout = w['workout'];
            final level = w['level_seconds'];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);

                  Widget screen;
                  if (workout == 'plank') {
                    screen = PlankScreen(workout: workout, targetSeconds: level);
                  } else if (workout == 'running') {
                    screen = RunningScreen(workout: workout, targetDistance: level);
                  } else if (workout == 'stairs') {
                    screen = StairsTimerScreen(workout: workout, targetfloors: level);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("지원되지 않는 운동 유형입니다: $workout"))
                    );
                    return;
                  }

                  await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
                },
                child: Text("${workout} 시작하기 (${level}${getUnit(workout)})"),
              ),
            );
          }).toList()
        ],
      )
    );
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
              calendarFormat: CalendarFormat.month, // 기본: 월(Month) 단위로 표시
              availableCalendarFormats: const {
                CalendarFormat.month: 'Month' // 월만 선택 가능
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
                final info = getWorkoutInfo(workout);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    color: Colors.white,
                    child: ListTile(
                      leading: Icon(info.icon, color: Colors.deepPurple),
                      title: Text(
                        "$workout",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("운동량: $duration${info.unit}"),
                    ),
                  ),
                );
              }),

            const SizedBox(height: 20),
            Text("오늘 운동을 시작하시겠습니까?", style: TextStyle(fontSize: 20)),
            // if (workoutData != null && workoutData!['workouts'] != null) ...[
            //   SizedBox(height: 10),
            //   Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: (workoutData!['workouts'] as List<dynamic>).map((w) {
            //       final workout = w['workout'];
            //       final level = w['level_seconds'];
            //       return Text("• $workout (${level}${getUnit(workout)})");
            //     }).toList(),
            //   )
            // ],
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (workoutData == null || workoutData!['workouts'] == null) return;
                final workouts = Map<String, dynamic>.from(workoutData!["workouts"]);
                startWorkoutSequence(workouts);
              },
              child: Text("운동 시작하기"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text("운동 다시 설정"),
                    content: Text("운동 설정을 어떻게 변경하시겠습니까?\n\n"
                                  "- '새로 설정'은 설문을 통해 다시 추천받습니다.\n"
                                  "- '직접 수정'은 현재 운동 설정을 편집합니다."),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("취소"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => WorkoutSelectionScreen()),
                          );
                        },
                        child: Text("새로 설정"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => WorkoutEditScreen()) // 새로 만든 수정화면
                          );
                        },
                        child: Text("직접 수정"),
                      ),
                    ],
                  ),
                );
              },
              child: Text("운동 설정 변경"),
            ),
            SizedBox(height: 20),
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (_) => WorkoutHistoryScreen()),
            //     );
            //   }, 
            //   child: Text("운동 기록 보기")
            // ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
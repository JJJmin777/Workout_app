import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'screens/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/workouts/common/workout_selection_screen.dart';
import 'screens/workouts/common/workout_history_screen.dart';
import 'screens/settings/settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 시스템 준비
  await Firebase.initializeApp(); // Firebase 준비
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '운동 관리 앱',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(), // 로그인 상태 실시간 감지 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // 로딩중
          } 
          if (snapshot.data != null) {
            return MainScaffold(); // ✅ 로그인 되어있으면 MainScaffold 바로
          } else {
            return LoginScreen(); // ✅ 로그인 안 되어있으면 로그인 화면
          }
        },
      )
    );
  }
}

class MainScaffold extends StatefulWidget {
  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;
  bool? hasProfile;

  @override
  void initState() {
    super.initState();
    checkProfile();
  }

  Future<void> checkProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('workout_profiles')
        .doc(user.uid)
        .get();
    setState(() {
      hasProfile = doc.exists;
    });
  }

  final List<Widget> _pages =[
    HomeScreen(),
    WorkoutHistoryScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (hasProfile == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()) // 로딩중
      );
    }

    if (hasProfile == false) {
      return WorkoutHistoryScreen(); // 프로필 업으면 운동 설정 먼저
    }

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.deepPurple,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label:  '기록'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
        ],
      ),
    );
  }
}




import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workout_app/main.dart';



class RunningScreen extends StatefulWidget {
  final String workout;
  final int targetDistance;

  RunningScreen({required this.workout, required this.targetDistance});

  @override
  _RunningScreenState createState() => _RunningScreenState();
}

class _RunningScreenState extends State<RunningScreen> {
  int elapsedSeconds = 0;
  Timer? timer;
  bool isRunning = false;
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  List<LatLng> _locations = []; // 사용자 위치 추적 경로 리스트
  Location _location = Location(); // 위치 객체

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (t) {
      setState(() {
        elapsedSeconds++;
      });
    });
  }

  void toggleTimer() {
    if (isRunning) {
      timer?.cancel();
    } else {
      startTimer();
    }
    setState(() {
      isRunning = !isRunning;
    });
  }

  void saveWorkout() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // 실제 달린 거리를 저장하기 위해 targetDistance와 달리기 시간이 아니라 실제 시간을 저장
      await FirebaseFirestore.instance.collection('workout_logs').add({
        'userId': user.uid,
        'workout': widget.workout,
        'workoutValue': widget.targetDistance, // 목표 거리
        'time_seconds': elapsedSeconds, // 경과 시간
        'date': FieldValue.serverTimestamp(),
      });

      showDialog(
        context: context, 
        builder: (_) => AlertDialog(
          title: Text("운동 완료!"),
          content: Text("${widget.targetDistance}m 러닝 완료!. 소요 시간: ${formatTime(elapsedSeconds)}수고하셨어요!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context, 
                  MaterialPageRoute(builder: (_) => MainScaffold()),
                  (route) => false  
                );
              }, 
              child: Text("홈으로 가기"),
            )
          ],
        ),
      );
    }
  }

  // 위치 추적하기
  void _startLocationTracking() {
    _location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        _markers.add(Marker(
          markerId: MarkerId('user_location'),
          position: LatLng(currentLocation.latitude!, currentLocation.longitude!),
          infoWindow: InfoWindow(title: "현재 위치"),
        ));
        _locations.add(LatLng(currentLocation.latitude!, currentLocation.longitude!));
        _polylines.add(Polyline(
          polylineId: PolylineId('running_route'),
          visible: true,
          points: _locations,
          width: 5,
          color: Colors.blue,
        ));
      });
      _mapController.moveCamera(CameraUpdate.newLatLng(LatLng(currentLocation.latitude!, currentLocation.longitude!)));
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("러닝")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.directions_run, size: 100, color: Colors.orange,),
            SizedBox(height: 20),
            Text("목표 거리: ${widget.targetDistance}m", style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text("경과 시간: ${formatTime(elapsedSeconds)}", style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: toggleTimer,
              child: Text(isRunning ? "Stop" : "Start"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                timer?.cancel();
                saveWorkout();
              },
              child: Text("운동 완료"),
            ),
            // 구글 맵 부분
            Expanded(
              child: GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                },
                initialCameraPosition: CameraPosition(
                  target: LatLng(37.7749, -122.4194), // 샌프란시스코 예시
                  zoom: 15,
                ),
                markers: _markers,
                polylines: _polylines,
              ),
            )
          ],
        ),
      ),
    );
  }
}
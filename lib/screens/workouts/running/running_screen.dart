import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workout_app/main.dart';

class RunningScreen extends StatefulWidget {
  final String workout;
  final int targetDistance;

  const RunningScreen({
    Key? key,
    required this.workout,
    required this.targetDistance,
  }) : super(key: key);

  @override
  _RunningScreenState createState() => _RunningScreenState();
}

class _RunningScreenState extends State<RunningScreen> {
  int elapsedSeconds = 0;
  Timer? _timer;
  bool isRunning = false;
  double _totalDistance = 0.0;
  LatLng? _initialPosition; // 초기 위치
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final List<LatLng> _locations = []; // 사용자 위치 추적 경로 리스트
  final Location _location = Location(); // 위치 객체
  StreamSubscription<LocationData>? _locationSubscription; // 위치(Location)를 실시간으로 추적
  
  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    final permission = await _location.requestPermission(); // 사용자에게 위치 접근 권한을 요청
    if (permission != PermissionStatus.granted) return; // granted - 사용자가 허용함(위치 추적 가능)

    bool serviceEnabled = await _location.serviceEnabled(); // 앱에서 위치(GPS) 서비스가 켜져 있는지 확인하고, 꺼져 있으면 켜달라고 요청
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return;
    }

    final loc = await _location.getLocation(); // 사용자의 현재 위치(GPS 좌표)를 받기기
    setState(() {
      _initialPosition = LatLng(loc.latitude!, loc.longitude!);
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        elapsedSeconds++;
      });
    });
  }

  // 위치 추적하기
  void _startLocationTracking() {
    _locations.clear();
    _totalDistance = 0.0;

    // 사용자의 **위치(GPS)**가 변할 때마다 데이터를 계속 흘려보내는 스트림과 listen으로 그 스트림을 구독하고, 새로운 위치 데이터가 들어올 때마다 실행
    _locationSubscription = _location.onLocationChanged.listen((locData) { 
      final newPos = LatLng(locData.latitude!, locData.longitude!);
      setState(() {
        if (_locations.isNotEmpty) {
          final prev = _locations.last;
          final distance = Geolocator.distanceBetween(
            prev.latitude,
            prev.longitude,
            newPos.latitude,
            newPos.longitude,
          );
          _totalDistance += distance;
        }
        _locations.add(newPos);

        // 마커 갱신
        _markers
          ..clear()
          ..add(Marker(
            markerId: const MarkerId('me'),
            position: newPos
          ));
        
        // 폴리라인 갱신
        _polylines
          ..clear()
          ..add(Polyline(
            polylineId: const PolylineId('route'),
            points: _locations,
            width: 5,
          ));
      });

      _mapController.animateCamera(
        CameraUpdate.newLatLng(newPos),
      );
    });
  }

  void toggleStartStop() {
    if (isRunning) {
      _timer?.cancel();
      _locationSubscription?.cancel();
    } else {
      _startTimer();
      _startLocationTracking();
    }
    setState(() {
      isRunning = !isRunning;
    });
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  Future<void> _saveWorkout() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // 위치 정보들
    final routeGeoPoints = _locations
        .map((p) => GeoPoint(p.latitude, p.longitude))
        .toList();

    // 실제 달린 거리를 저장하기 위해 targetDistance와 달리기 시간이 아니라 실제 시간을 저장
    await FirebaseFirestore.instance.collection('workout_logs').add({
      'userId': user.uid,
      'workout': widget.workout,
      'time_seconds': elapsedSeconds, // 경과 시간
      'workoutValue': _totalDistance, // 거리
      'route': routeGeoPoints,
      'date': FieldValue.serverTimestamp(),
    });

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("운동 완료!"),
            content: Text(
              "${widget.targetDistance}m 러닝 완료!." 
              "소요 시간: ${_formatTime(elapsedSeconds)}, "
              '총 이동 거리: ${_totalDistance.toStringAsFixed(1)}m 수고하셨어요!'
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => MainScaffold()),
                    (_) => false,
                  );
                },
                child: const Text("홈으로 가기"),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel(); // 타이머 멈춤
    _locationSubscription?.cancel(); // 위치 추적 중단
    super.dispose(); // Flutter 시스템이 원래 하던 리소스 정리 작업 실행 (필수)
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('러닝')),
      body: Column(
        children: [
          Icon(Icons.directions_run, size: 100, color: Colors.orange),
          const SizedBox(height: 20),
          Text(
            '목표 거리: ${widget.targetDistance}m',
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 10),
          Text(
            '경과 시간: ${_formatTime(elapsedSeconds)}',
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 10),
          Text(
            '이동 거리: ${_totalDistance.toStringAsFixed(1)} m',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: toggleStartStop,
                child: Text(isRunning ? 'Stop' : 'Start'),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  if (isRunning) toggleStartStop();
                  _saveWorkout();
                },
                child: const Text('운동 완료'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _initialPosition == null
                ? const Center(child: CircularProgressIndicator())
                : GoogleMap(
                    onMapCreated: (c) => _mapController = c,
                    initialCameraPosition: CameraPosition(
                      target: _initialPosition!,
                      zoom: 16,
                    ),
                    markers: _markers,
                    polylines: _polylines,
                    myLocationEnabled: true,
                  ),
          ),
        ],
      ),
    );
  }
}

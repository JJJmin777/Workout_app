import 'dart:async';

class WorkoutTimer {
  late int _elapsedSeconds;
  Timer? _timer;
  void Function(int)? onTick;

  WorkoutTimer({this.onTick}) {
    _elapsedSeconds = 0;
  }

  int get elapsedSeconds => _elapsedSeconds;
  
  void start() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsedSeconds++;
      if (onTick != null) onTick!(_elapsedSeconds);
    });
  }

  void stop() {
    _timer?.cancel();
  }

  void reset() {
    _timer?.cancel();
    _elapsedSeconds = 0;
  }

  void dispose() {
    _timer?.cancel();
  }
}
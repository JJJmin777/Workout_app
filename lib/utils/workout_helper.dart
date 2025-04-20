import 'package:flutter/material.dart';

class WorkoutInfo {
  final IconData icon;
  final String unit;

  WorkoutInfo({required this.icon, required this.unit});
}

WorkoutInfo getWorkoutInfo(String workoutType) {
   if (workoutType == 'plank') {
    return WorkoutInfo(icon: Icons.self_improvement, unit: "초");
  } else if (workoutType == 'running') {
    return WorkoutInfo(icon: Icons.directions_run, unit: "m");
  } else if (workoutType == 'stairs') {
    return WorkoutInfo(icon: Icons.stairs, unit: "층");
  } else {
    return WorkoutInfo(icon: Icons.fitness_center, unit: "단위");
  }
}
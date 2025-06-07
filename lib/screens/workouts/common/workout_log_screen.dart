import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WorkoutLogScreen extends StatelessWidget {
  final String workoutType;
  final String unit;

  const WorkoutLogScreen({
    Key? key,
    required this.workoutType,
    required this.unit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("12321312312312321321312321321312 $workoutType");
    final user = FirebaseAuth.instance.currentUser!;
    final logsQuery = FirebaseFirestore.instance
        .collection('workout_logs')
        .where('userId', isEqualTo: user.uid)
        .where('workout', isEqualTo: workoutType)
        .orderBy('date', descending: true);

    return Scaffold(
      appBar: AppBar(title: Text('$workoutType 기록')),
      body: StreamBuilder<QuerySnapshot>( // 실시간으로 받아오고, 업데이트
        stream: logsQuery.snapshots(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty)
            return Center(child: Text('아직 기록이 없습니다.'));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final data = docs[i].data()! as Map<String, dynamic>;
              final time = data['time_seconds'];
              final distance = data['workoutValue'];
              final docId = docs[i].id;

              return ListTile(
                title: Text(
                  workoutType == 'running'
                    ? '${distance.toStringAsFixed(1)} m'
                    : '${time} 초',
                ),
                subtitle: Text(
                  '${(data['date'] as Timestamp).toDate()}'
                ),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      // 예: 간단한 다이얼로그로 시간/거리 재입력한 뒤 update 호출
                      _showEditDialog(context, docId, data);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection('workout_logs')
                          .doc(docId)
                          .delete();
                    },
                  ),
                ]),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // 새 기록 추가 기능
          _showAddDialog(context, workoutType, unit);
        },
      ),
    );
  }

  void _showAddDialog(BuildContext ctx, String type, String unit) {
    final controller = TextEditingController();
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text('새 $type 기록 추가'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: type == 'running' ? '거리($unit)' : '시간(초)',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('취소')),
          TextButton(
            onPressed: () async {
              final val = double.tryParse(controller.text);
              if (val == null) return;
              final user = FirebaseAuth.instance.currentUser!;
              await FirebaseFirestore.instance.collection('workout_logs').add({
                'userId': user.uid,
                'workout': type,
                'time_seconds': type == 'running' ? 0 : val.toInt(),
                'distance_m': type == 'running' ? val : 0,
                'date': FieldValue.serverTimestamp(),
              });
              Navigator.pop(ctx);
            },
            child: Text('저장'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext ctx, String docId, Map<String, dynamic> data) {
    final controller = TextEditingController(
      text: data['time_seconds']?.toString() ?? data['distance_m']?.toString(),
    );
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text('기록 수정'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: '값을 입력하세요'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('취소')),
          TextButton(
            onPressed: () async {
              final val = double.tryParse(controller.text);
              if (val == null) return;
              final updateData = data['workout'] == 'running'
                ? {'distance_m': val}
                : {'time_seconds': val.toInt()};
              await FirebaseFirestore.instance
                  .collection('workout_logs')
                  .doc(docId)
                  .update(updateData);
              Navigator.pop(ctx);
            },
            child: Text('수정'),
          ),
        ],
      ),
    );
  }
}
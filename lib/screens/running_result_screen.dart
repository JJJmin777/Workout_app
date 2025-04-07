import 'package:flutter/material.dart';
import 'home_screen.dart';

class PlankResultScreen extends StatelessWidget {
  final String resultText;

  PlankResultScreen({required this.resultText});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("추천 결과")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(resultText, style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => HomeScreen()),
                  (route) => false,
                );
              },
              child: Text("홈으로 가기"),
            )
          ],
        ),
      ),
    );
  }
}
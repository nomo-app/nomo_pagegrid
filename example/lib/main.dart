import 'package:flutter/material.dart';
import 'package:nomo_pagegrid/nomo_pagegrid.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: NomoPageGrid(
          rows: 8,
          columns: 4,
          itemSize: Size(64, 64),
          onChanged: (newItems) {
            print("New Items: $newItems");
          },
          items: {
            0: Container(
              color: Colors.red,
            ),
            1: Container(
              color: Colors.yellow,
            ),
            2: Container(
              color: Colors.deepOrange,
            ),
            // 3: Container(
            //   color: Colors.blue,
            // ),
            // 4: Container(
            //   color: Colors.cyan,
            // ),
            // 5: Container(
            //   color: Colors.green,
            // ),
            6: Container(
              color: Colors.greenAccent,
            ),
            7: Container(
              color: Colors.deepPurple,
            ),
            8: Container(
              color: Colors.blueAccent,
            ),

            80: Container(
              color: Colors.lime,
            ),
          },
        ),
      ),
    );
  }
}

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
        body: LayoutBuilder(
          builder: (context, constraints) {
            return NomoPageGrid(
              rows: 8,
              columns: 4,
              itemSize: 64,
              maxWidth: constraints.maxWidth,
              items: {
                0: Container(
                  color: Colors.red,
                ),
                1: Container(
                  color: Colors.yellow,
                ),
                3: Container(
                  color: Colors.blue,
                ),
              },
            );
          },
        ),
      ),
    );
  }
}

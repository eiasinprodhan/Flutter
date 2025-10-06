import 'dart:ui';
import 'package:crems/pages/Home.dart';
import 'package:crems/pages/SignIn.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CREMS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Roboto', // Or any font you prefer
      ),
      // Apply the custom scroll behavior here
      scrollBehavior: MyCustomScrollBehavior(),
      home: const Home(),
    );
  }
}
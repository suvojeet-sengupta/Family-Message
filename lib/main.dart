import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const AuroraWeather());
}

class AuroraWeather extends StatelessWidget {
  const AuroraWeather({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AuroraWeather',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

import 'package:AuroraWeather/screens/weather_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/settings_service.dart';
import 'services/weather_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SettingsService()),
        ChangeNotifierProvider(create: (context) => WeatherProvider()),
      ],
      child: const AuroraWeather(),
    ),
  );
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
      home: const WeatherDetailScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

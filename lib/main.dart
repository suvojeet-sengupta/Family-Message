import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/weather_model.dart';
import 'screens/home_screen.dart';
import 'services/weather_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final lastOpenedCity = prefs.getString('lastOpenedCity');

  Weather? initialWeather;
  if (lastOpenedCity != null) {
    try {
      initialWeather = await WeatherService().fetchWeatherByCity(lastOpenedCity);
    } catch (e) {
      print('Error fetching initial weather: $e');
    }
  }

  runApp(AuroraWeather(initialWeather: initialWeather));
}

class AuroraWeather extends StatelessWidget {
  final Weather? initialWeather;

  const AuroraWeather({super.key, this.initialWeather});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AuroraWeather',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.white,
          secondary: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      home: HomeScreen(initialWeather: initialWeather),
      debugShowCheckedModeBanner: false,
    );
  }
}
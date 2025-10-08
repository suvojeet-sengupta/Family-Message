import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/weather_model.dart';
import 'screens/home_screen.dart';
import 'services/settings_service.dart';
import 'services/weather_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Weather? initialWeather;
  try {
    initialWeather = await WeatherService().fetchWeather();
  } catch (e) {
    print('Error fetching initial weather for current location: $e');
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => SettingsService(),
      child: AuroraWeather(initialWeather: initialWeather),
    ),
  );
}

class AuroraWeather extends StatelessWidget {
  final Weather? initialWeather;

  const AuroraWeather({super.key, this.initialWeather});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AuroraWeather',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      ),
      home: HomeScreen(initialWeather: initialWeather),
      debugShowCheckedModeBanner: false,
    );
  }
}

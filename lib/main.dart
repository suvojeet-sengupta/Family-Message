import 'package:AuroraWeather/screens/weather_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/settings_service.dart';
import 'services/weather_provider.dart';
import 'config/app_themes.dart'; // New import

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
    return Consumer<SettingsService>(
      builder: (context, settingsService, child) {
        return MaterialApp(
          title: 'Aurora Weather',
          theme: AppThemes.lightTheme, // Use light theme as default
          darkTheme: AppThemes.darkTheme, // Use dark theme
          themeMode: settingsService.themeMode, // Apply selected theme mode
          home: const WeatherDetailScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

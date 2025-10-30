import 'package:AuroraWeather/screens/weather_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:in_app_update/in_app_update.dart'; // Added for in-app updates
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

class AuroraWeather extends StatefulWidget {
  const AuroraWeather({super.key});

  @override
  State<AuroraWeather> createState() => _AuroraWeatherState();
}

class _AuroraWeatherState extends State<AuroraWeather> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    checkForUpdate(); // Check for updates on app start
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Check for app updates on resume
      InAppUpdate.checkForUpdate().then((info) {
        if (info.installStatus == InstallStatus.downloaded) {
          InAppUpdate.completeFlexibleUpdate();
        }
      }).catchError((e) {
        print('Failed to check for update on resume: $e');
      });
    }
  }

  Future<void> checkForUpdate() async {
    try {
      AppUpdateInfo appUpdateInfo = await InAppUpdate.checkForUpdate();

      if (appUpdateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (appUpdateInfo.flexibleUpdateAllowed) {
          // Start a flexible update
          await InAppUpdate.startFlexibleUpdate();
          // Listen for the update to be downloaded
          InAppUpdate.installUpdateListener.listen((status) {
            if (status == InstallStatus.downloaded) {
              // When the update is downloaded, complete it
              InAppUpdate.completeFlexibleUpdate();
            }
          });
        } else if (appUpdateInfo.immediateUpdateAllowed) {
          // Perform an immediate update if flexible is not allowed
          await InAppUpdate.performImmediateUpdate();
        }
      }
    } catch (e) {
      print('Failed to check for update: $e');
      // Handle error, e.g., show a message to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsService>(
      builder: (context, settingsService, child) {
        return MaterialApp(
          title: 'Aurora Weather',
          theme: AppThemes.lightTheme.copyWith(
            useMaterial3: true,
          ),
          darkTheme: AppThemes.darkTheme.copyWith(
            useMaterial3: true,
          ),
          themeMode: settingsService.themeMode, // Apply selected theme mode
          home: const WeatherDetailScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

# AuroraWeather

AuroraWeather is a beautifully designed, multi-source weather application for Flutter. It provides current weather conditions, hourly forecasts, and a 10-day forecast with a clean, dark-themed user interface. The app is built with a resilient architecture that includes multiple fallback weather data providers and an offline caching mechanism.

## Features

- **Current Weather:** Get real-time weather information for your current location or any searched city.
- **Detailed Forecasts:** Access hourly and 10-day weather forecasts.
- **Global City Search:** Find weather information for any city in the world.
- **Saved Locations:** Save your favorite cities for quick access from the home screen.
- **Data-Rich Details:** Get in-depth information on Precipitation, UV Index, Wind Speed, Pressure, Humidity, and more.
- **Resilient Data Fetching:** If the primary weather API fails, the app automatically falls back to secondary and tertiary providers to ensure you always get data.
- **Offline Caching:** Weather data is cached locally. If you're offline or can't reach the servers, you'll still see the last-known weather conditions. The cache automatically expires after one hour.
- **Settings:** Customize your experience by switching between Celsius and Fahrenheit, and manage your saved locations.

## Getting Started

Follow these instructions to get a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (Channel stable)
- A code editor like [VS Code](https://code.visualstudio.com/) or [Android Studio](https://developer.android.com/studio).
- API Keys from [WeatherAPI.com](https://www.weatherapi.com/) and [OpenWeatherMap](https://openweathermap.org/api).

### Installation & Setup

1.  **Clone the repository:**
    ```sh
    git clone https://github.com/suvojeet-sengupta/AuroraWeather.git
    cd AuroraWeather
    ```

2.  **Install dependencies:**
    ```sh
    flutter pub get
    ```

3.  **Provide API Keys:**
    This project requires API keys from two different weather services. You must provide them at runtime using the `--dart-define` flag.

    - `WEATHER_API_KEY`: Your API key from [WeatherAPI.com](https://www.weatherapi.com/).
    - `OPEN_WEATHER_API`: Your API key from [OpenWeatherMap](https://openweathermap.org/).

4.  **Run the application:**
    ```sh
    flutter run --dart-define=WEATHER_API_KEY=YOUR_WEATHERAPI_KEY --dart-define=OPEN_WEATHER_API=YOUR_OPENWEATHERMAP_KEY
    ```

## Project Architecture

The application follows a clean, service-oriented architecture that separates UI, business logic, and data models.

### Project Structure

```
lib/
├── main.dart           # App entry point and theme configuration.
├── models/             # Data models for weather information.
│   └── weather_model.dart
├── screens/            # UI for each screen of the application.
│   ├── home_screen.dart
│   ├── search_screen.dart
│   ├── settings_screen.dart
│   └── ... (detail screens)
├── services/           # Business logic and data handling.
│   ├── weather_service.dart      # Main service orchestrator.
│   ├── open_meteo_service.dart   # Fallback weather provider.
│   ├── open_weather_service.dart # Fallback weather provider.
│   ├── database_helper.dart      # Local database (SQFlite) for caching.
│   ├── settings_service.dart     # Manages user settings (e.g., temp unit).
│   └── ...
└── widgets/            # Reusable UI components.
    ├── weather_card.dart
    ├── current_weather.dart
    └── ...
```

### Data Flow and Services

The app's data flow is designed to be robust and resilient.

1.  **UI Layer (`screens`, `widgets`):** The user interacts with the UI, triggering an event (e.g., refresh, search for a city).
2.  **Orchestrator (`WeatherService`):** The UI calls the main `WeatherService`. This service acts as a facade, orchestrating calls to other services.
3.  **Caching (`DatabaseHelper`):**
    - The `WeatherService` first checks the `DatabaseHelper` for cached data for the requested location.
    - If fresh data (less than 1 hour old) exists in the cache, it is returned immediately.
    - If the data is stale or doesn't exist, the service proceeds to fetch it from the network.
4.  **API Fetching (Fallback Strategy):**
    - **Primary:** The `WeatherService` first attempts to fetch data from **WeatherAPI.com**.
    - **Secondary:** If the primary service fails (due to an API error, network issue, or invalid key), it automatically calls the `OpenWeatherService` as a fallback.
    - **Tertiary:** If `OpenWeatherService` also fails, it makes a final attempt using `OpenMeteoService`, which does not require an API key.
5.  **Data Modeling (`models`):** The JSON response from the successful API call is parsed into strongly-typed Dart objects using the models defined in `weather_model.dart`.
6.  **UI Update:** The fetched and parsed `Weather` object is returned to the UI layer, which then uses `setState` to rebuild and display the new information.

### State Management

The app uses a simple and effective state management approach with `StatefulWidget` and the `setState` method. For shared user preferences, `shared_preferences` is used via the `SettingsService`.

## Core Dependencies

- **`http`**: For making network requests to weather APIs.
- **`geolocator` & `geocoding`**: To get the user's current location.
- **`sqflite` & `path`**: For local database storage and caching.
- **`shared_preferences`**: For persisting user settings.
- **`flutter_animate`**: For beautiful and simple UI animations.
- **`shimmer`**: To provide a loading effect while data is being fetched.
- **`intl`**: For date and number formatting.

---
This documentation provides a clear overview of the AuroraWeather application, its features, and its internal workings, making it easy for any developer to understand and contribute to the project.
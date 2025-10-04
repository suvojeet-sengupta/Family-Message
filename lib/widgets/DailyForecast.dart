import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import 'package:intl/intl.dart';

class DailyForecastWidget extends StatelessWidget {
  final List<DailyForecast> dailyForecast;

  const DailyForecastWidget({super.key, required this.dailyForecast});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '10-DAY FORECAST',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dailyForecast.length,
              itemBuilder: (context, index) {
                final forecast = dailyForecast[index];
                return _buildForecastItem(
                  date: DateFormat.E().format(DateTime.parse(forecast.date)),
                  iconUrl: forecast.iconUrl,
                  maxTemp: '${forecast.maxTemp.round()}°',
                  minTemp: '${forecast.minTemp.round()}°',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastItem({required String date, required String iconUrl, required String maxTemp, required String minTemp}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 50,
            child: Text(
              date,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ),
          Image.network(
            iconUrl,
            height: 32,
            width: 32,
          ),
          SizedBox(
            width: 50,
            child: Text(
              maxTemp,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            width: 50,
            child: Text(
              minTemp,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

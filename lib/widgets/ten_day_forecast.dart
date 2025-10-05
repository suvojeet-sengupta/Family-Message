import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';

class TenDayForecast extends StatelessWidget {
  final List<DailyForecast> dailyForecast;

  const TenDayForecast({super.key, required this.dailyForecast});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '10-day forecast',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: dailyForecast.length,
                itemBuilder: (context, index) {
                  final day = dailyForecast[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Column(
                      children: [
                        Text(
                          DateFormat('E').format(DateTime.parse(day.date)),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(DateFormat('MM/dd').format(DateTime.parse(day.date))),
                        const SizedBox(height: 8),
                        Image.network(
                          day.iconUrl,
                          height: 40,
                          width: 40,
                        ),
                        const SizedBox(height: 8),
                        Text('${day.maxTemp.round()}° / ${day.minTemp.round()}°'),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

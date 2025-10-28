import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/weather_provider.dart';

class SavedLocationsScreen extends StatelessWidget {
  const SavedLocationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Locations'),
      ),
      body: weatherProvider.savedCities.isEmpty
          ? const Center(child: Text('No saved locations.'))
          : ReorderableListView.builder(
              itemCount: weatherProvider.savedCities.length,
              onReorder: (oldIndex, newIndex) {
                weatherProvider.reorderSavedCities(oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final city = weatherProvider.savedCities[index];
                return ListTile(
                  key: ValueKey(city),
                  leading: const Icon(Icons.drag_handle),
                  title: Text(city),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _showDeleteConfirmation(context, city, weatherProvider),
                  ),
                );
              },
            ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String city, WeatherProvider weatherProvider) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete City?'),
          content: Text('Are you sure you want to delete $city?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                weatherProvider.removeCity(city);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
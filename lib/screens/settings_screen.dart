
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../services/settings_service.dart';
import '../constants/detail_card_constants.dart'; // New import

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<String> _savedCities = [];

  @override
  void initState() {
    super.initState();
    _loadSavedCities();
  }

  Future<void> _loadSavedCities() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedCities = prefs.getStringList(AppConstants.recentSearchesKey) ?? [];
    });
  }

  Future<void> _deleteCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    _savedCities.remove(city);
    await prefs.setStringList(AppConstants.recentSearchesKey, _savedCities);
    setState(() {});
  }

  Future<void> _reorderCities(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final city = _savedCities.removeAt(oldIndex);
    _savedCities.insert(newIndex, city);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(AppConstants.recentSearchesKey, _savedCities);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final settingsService = Provider.of<SettingsService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text('Use Fahrenheit'),
            value: settingsService.useFahrenheit,
            onChanged: (value) {
              settingsService.toggleUnit(value);
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Saved Locations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ReorderableListView(
              onReorder: _reorderCities,
              children: [
                for (final city in _savedCities)
                  ListTile(
                    key: ValueKey(city),
                    leading: const Icon(Icons.drag_handle),
                    title: Text(city),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteCity(city),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Detail Card Customization',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Consumer<SettingsService>(
            builder: (context, settingsService, child) {
              final cards = settingsService.detailCardPreferences;
              return Expanded(
                child: ReorderableListView.builder(
                  itemCount: cards.length,
                  onReorder: (oldIndex, newIndex) {
                    settingsService.reorderDetailCards(oldIndex, newIndex);
                  },
                  itemBuilder: (context, index) {
                    final card = cards[index];
                    final detailCard = defaultDetailCards.firstWhere((dc) => dc.id == card.cardTypeId);
                    return SwitchListTile(
                      key: ValueKey(card.cardTypeId),
                      secondary: Icon(detailCard.icon),
                      title: Text(detailCard.title),
                      value: card.isVisible,
                      onChanged: (value) {
                        settingsService.toggleDetailCardVisibility(card.cardTypeId, value);
                      },
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

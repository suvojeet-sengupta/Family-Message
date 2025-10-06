import 'dart:async';

import '../models/search_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../services/weather_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _cityController = TextEditingController();
  final WeatherService _weatherService = WeatherService();
  List<SearchResult> _suggestions = [];
  List<String> _recentSearches = [];
  Timer? _debounce;
  bool _isLoading = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _cityController.addListener(() {
      setState(() {
        _isSearching = _cityController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList(AppConstants.recentSearchesKey) ?? [];
    });
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isNotEmpty) {
        setState(() {
          _isLoading = true;
        });
        try {
          final suggestions = await _weatherService.searchCities(query);
          setState(() {
            _suggestions = suggestions;
          });
        } catch (e) {
          // Handle error, maybe show a snackbar
          print('Error searching cities: $e');
        } finally {
          setState(() {
            _isLoading = false;
          });
        }
      }
    });
  }

  Future<void> _saveSearch(String city) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> recentSearches = prefs.getStringList(AppConstants.recentSearchesKey) ?? [];
    if (!recentSearches.contains(city)) {
      recentSearches.insert(0, city);
      if (recentSearches.length > 5) {
        recentSearches.removeLast();
      }
      await prefs.setStringList(AppConstants.recentSearchesKey, recentSearches);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search City'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _cityController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Enter city name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                suffixIcon: _isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
              ),
              onChanged: _onSearchChanged,
            ).animate().fade(duration: 300.ms).slideX(),
            const SizedBox(height: 16),
            Expanded(
              child: _isSearching ? _buildSuggestionsList() : _buildRecentSearchesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionsList() {
    return ListView.builder(
      itemCount: _suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = _suggestions[index];
        return Card(
          color: Colors.white.withOpacity(0.1),
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            title: Text(suggestion.name),
            subtitle: Text('${suggestion.region}, ${suggestion.country}'),
            onTap: () async {
              await _saveSearch(suggestion.name);
              Navigator.pop(context, suggestion.name);
            },
          ),
        ).animate().fade(duration: 300.ms).slideY(delay: (100 * index).ms);
      },
    );
  }

  Widget _buildRecentSearchesList() {
    if (_recentSearches.isEmpty) {
      return const Center(
        child: Text('No recent searches', style: TextStyle(color: Colors.white54)),
      );
    }
    return ListView.builder(
      itemCount: _recentSearches.length,
      itemBuilder: (context, index) {
        final city = _recentSearches[index];
        return Card(
          color: Colors.white.withOpacity(0.1),
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: const Icon(Icons.history, color: Colors.white54),
            title: Text(city),
            onTap: () {
              Navigator.pop(context, city);
            },
          ),
        ).animate().fade(duration: 300.ms).slideY(delay: (100 * index).ms);
      },
    );
  }
}
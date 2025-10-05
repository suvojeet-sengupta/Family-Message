import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _cityController = TextEditingController();
  List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recentSearches') ?? [];
    });
  }

  Future<void> _saveSearch(String city) async {
    final prefs = await SharedPreferences.getInstance();
    if (!_recentSearches.contains(city)) {
      _recentSearches.insert(0, city);
      if (_recentSearches.length > 5) {
        _recentSearches.removeLast();
      }
      await prefs.setStringList('recentSearches', _recentSearches);
      setState(() {});
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
              decoration: InputDecoration(
                labelText: 'Enter city name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
              ),
              onSubmitted: (value) {
                _handleSearch();
              },
            ).animate().fade(duration: 300.ms).slideX(),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _handleSearch,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Search'),
            ).animate().fade(duration: 300.ms).slideX(delay: 100.ms),
            const SizedBox(height: 32),
            if (_recentSearches.isNotEmpty)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent Searches',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _recentSearches.length,
                        itemBuilder: (context, index) {
                          final city = _recentSearches[index];
                          return Card(
                            color: Colors.white.withOpacity(0.1),
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              title: Text(city),
                              onTap: () {
                                Navigator.pop(context, city);
                              },
                            ),
                          ).animate().fade(duration: 300.ms).slideY(delay: (100 * index).ms);
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handleSearch() {
    if (_cityController.text.isNotEmpty) {
      _saveSearch(_cityController.text);
      Navigator.pop(context, _cityController.text);
    }
  }
}
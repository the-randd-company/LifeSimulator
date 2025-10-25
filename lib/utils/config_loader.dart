import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

class ConfigLoader {
  // Cache for loaded configs
  static final Map<String, dynamic> _cache = {};
  
  static Future<Map<String, dynamic>> loadConfig(String path) async {
    if (_cache.containsKey(path)) {
      return _cache[path] as Map<String, dynamic>;
    }
    
    try {
      final jsonString = await rootBundle.loadString(path);
      final config = json.decode(jsonString) as Map<String, dynamic>;
      _cache[path] = config;
      return config;
    } catch (e) {
      debugPrint('Error loading config from $path: $e');
      return {};
    }
  }
  
  static Future<List<dynamic>> loadConfigList(String path, String key) async {
    final config = await loadConfig(path);
    return config[key] as List<dynamic>? ?? [];
  }
  
  // Clear cache (useful for hot reload during development)
  static void clearCache() {
    _cache.clear();
  }
  
  // Specific loaders for convenience
  static Future<Map<String, dynamic>> loadGameSettings() async {
    return loadConfig('assets/config/game_settings.json');
  }
  
  static Future<List<dynamic>> loadActivities() async {
    return loadConfigList('assets/config/activities.json', 'activities');
  }
  
  static Future<List<dynamic>> loadJobs() async {
    return loadConfigList('assets/config/jobs.json', 'jobs');
  }
  
  static Future<List<dynamic>> loadEvents() async {
    return loadConfigList('assets/config/events.json', 'events');
  }
  
  static Future<List<dynamic>> loadStoreItems() async {
    final config = await loadConfig('assets/config/store_items.json');
    return config['categories'] as List<dynamic>? ?? [];
  }
  
  static Future<List<dynamic>> loadSocializationActivities() async {
    return loadConfigList('assets/config/socialization.json', 'activities');
  }
  
  static Future<Map<String, dynamic>> loadSocializationSettings() async {
    final config = await loadConfig('assets/config/socialization.json');
    return config['hangoutCost'] as Map<String, dynamic>? ?? {};
  }
}
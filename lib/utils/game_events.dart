import 'dart:math';
import '../models/player.dart';
import '../models/relationship.dart';
import 'config_loader.dart';

class GameEvents {
  static List<dynamic>? _cachedEvents;
  
  static Future<void> _loadEvents() async {
    _cachedEvents ??= await ConfigLoader.loadEvents();
  }
    
  static Future<String?> triggerRandomEvent(Player player, Random random) async {
    await _loadEvents();
    
    if (_cachedEvents == null || _cachedEvents!.isEmpty) {
      return null;
    }
    
    // Filter events based on conditions
    final availableEvents = _cachedEvents!.where((event) {
      // Check if event requires a job
      if (event['requiresJob'] == true && player.job == null) {
        return false;
      }
      return true;
    }).toList();
    
    if (availableEvents.isEmpty) return null;
    
    // Select random event
    final event = availableEvents[random.nextInt(availableEvents.length)];
    String eventMessage = "RANDOM EVENT: ${event['message']}";
    
    // Apply effects
    if (event['effects'] != null) {
      final effects = event['effects'] as Map<String, dynamic>;
      
      if (effects.containsKey('health')) {
        player.adjustStat('health', (effects['health'] as num).toInt());
      }
      if (effects.containsKey('energy')) {
        player.adjustStat('energy', (effects['energy'] as num).toInt());
      }
      if (effects.containsKey('money')) {
        player.money += (effects['money'] as num).toDouble();
      }
      if (effects.containsKey('happiness')) {
        player.adjustStat('happiness', (effects['happiness'] as num).toInt());
      }
      
      // Special effects
      if (effects['removeJob'] == true) {
        player.job = null;
      }
      
      if (effects.containsKey('addRelationship')) {
        final relData = effects['addRelationship'] as Map<String, dynamic>;
        String newPerson = "Person_${random.nextInt(9000) + 1000}";
        player.relationships.add(
          Relationship(
            newPerson,
            relData['type'] as String,
            (relData['strength'] as num).toInt(),
          )
        );
        eventMessage += " You met $newPerson!";
      }
    }
    
    return eventMessage;
  }
}
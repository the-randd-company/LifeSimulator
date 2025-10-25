import 'package:flutter/material.dart';
import 'dart:math';
import '../models/player.dart';
import '../models/relationship.dart';
import '../utils/config_loader.dart';
import '../utils/icon_helper.dart';

class RelationshipsTab extends StatefulWidget {
  final Player player;
  final Function(String, {String? message}) onActivity;

  const RelationshipsTab({
    super.key,
    required this.player,
    required this.onActivity,
  });

  @override
  RelationshipsTabState createState() => RelationshipsTabState();
}

class RelationshipsTabState extends State<RelationshipsTab> {
  List<dynamic> socializationActivities = [];
  Map<String, dynamic> hangoutSettings = {};
  bool isLoading = true;
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final activities = await ConfigLoader.loadSocializationActivities();
    final settings = await ConfigLoader.loadSocializationSettings();
    setState(() {
      socializationActivities = activities;
      hangoutSettings = settings;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Relationships',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            if (widget.player.relationships.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(30.0),
                  child: Column(
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No relationships yet.',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Socialize to meet new people.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              
            ...widget.player.relationships.map((relationship) => 
              _buildRelationshipCard(context, relationship)),

            const SizedBox(height: 30),
            _buildSocializationOptions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildRelationshipCard(BuildContext context, Relationship relationship) {
    IconData relationIcon;
    Color relationColor;
    
    switch(relationship.type) {
      case 'friend':
        relationIcon = Icons.people;
        relationColor = Colors.blue;
        break;
      case 'partner':
        relationIcon = Icons.favorite;
        relationColor = Colors.red;
        break;
      case 'family':
        relationIcon = Icons.family_restroom;
        relationColor = Colors.green;
        break;
      case 'acquaintance':
      default:
        relationIcon = Icons.person_outline;
        relationColor = Colors.grey;
        break;
    }
    
    final energyCost = (hangoutSettings['energy'] as num?)?.toInt() ?? 10;
    final strengthGain = (hangoutSettings['strengthGain'] as num?)?.toInt() ?? 5;
    final happinessGain = (hangoutSettings['happinessGain'] as num?)?.toInt() ?? 5;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: relationColor.withAlpha(51),
          child: Icon(relationIcon, color: relationColor),
        ),
        title: Text(relationship.person),
        subtitle: Text(
          '${relationship.type.capitalize()} - Relationship Strength: ${relationship.strength}'
        ),
          trailing: ElevatedButton(
          onPressed: () {
            widget.player.adjustStat("energy", -energyCost);
            widget.player.adjustStat("happiness", happinessGain);
            relationship.strength = (relationship.strength + strengthGain).clamp(0, 100);
            
            // Force UI refresh
            if (mounted) {
              setState(() {});
            }
            
            widget.onActivity('socialize');
          },
          child: const Text('Hang Out'),
        ),
      ),
    );
  }
  
  Widget _buildSocializationOptions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Socialize',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...socializationActivities.map((activity) => 
          _buildSocializationCard(activity)),
      ],
    );
  }

  Widget _buildSocializationCard(Map<String, dynamic> activity) {
    final energyCost = (activity['energyCost'] as num?)?.toInt() ?? 0;
    final moneyCost = (activity['moneyCost'] as num?)?.toDouble() ?? 0;
    
    return Card(
      child: ListTile(
        leading: Icon(
          IconHelper.getIconData(activity['icon']),
          color: _colorFromHex(activity['color']),
        ),
        title: Text(activity['title']),
        subtitle: Text(
          '${activity['description']} (Energy: -$energyCost, Money: \$${moneyCost.toStringAsFixed(0)})'
        ),
        trailing: ElevatedButton(
          onPressed: () => _performSocialization(activity),
          child: const Text('Go'),
        ),
      ),
    );
  }

  void _performSocialization(Map<String, dynamic> activity) {
    // Apply effects
    if (activity['effects'] != null) {
      final effects = activity['effects'] as Map<String, dynamic>;
      effects.forEach((stat, value) {
        if (stat == 'money') {
          widget.player.money += (value as num).toDouble();
        } else {
          widget.player.adjustStat(stat, (value as num).toInt());
        }
      });
    }
    
    String message = activity['message'];
    
    // Check if player meets someone new
    final meetChance = (activity['meetChance'] as num?)?.toDouble() ?? 0.0;
    if (random.nextDouble() < meetChance) {
      final meetTypes = activity['meetTypes'] as List<dynamic>;
      if (meetTypes.isNotEmpty) {
        // Select relationship type based on probability
        double roll = random.nextDouble();
        double cumulative = 0.0;
        
        for (var meetType in meetTypes) {
          cumulative += (meetType['probability'] as num).toDouble();
          if (roll < cumulative) {
            String newPerson = "Person_${random.nextInt(9000) + 1000}";
            String relationType = meetType['type'] as String;
            int strength = (meetType['strength'] as num).toInt();
            
            widget.player.relationships.add(
              Relationship(newPerson, relationType, strength)
            );
            
            message += " You met $newPerson and became ${relationType}s!";
            break;
          }
        }
      }
    } else {
      message += " but didn't meet anyone new.";
    }
    
    widget.onActivity('socialize', message: message);
  }

  Color _colorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
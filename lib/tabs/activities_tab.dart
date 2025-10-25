import 'package:flutter/material.dart';
import 'dart:math';
import '../models/player.dart';
import '../utils/config_loader.dart';
import '../utils/icon_helper.dart';

class ActivitiesTab extends StatefulWidget {
  final Player player;
  final Function(String, {String? message}) onActivity;

  const ActivitiesTab({
    super.key,  // Use super.key instead of Key? key
    required this.player,
    required this.onActivity,
  });

  @override
  ActivitiesTabState createState() => ActivitiesTabState();
}

class ActivitiesTabState extends State<ActivitiesTab> {
  List<dynamic> activities = [];
  bool isLoading = true;
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    final loadedActivities = await ConfigLoader.loadActivities();
    setState(() {
      activities = loadedActivities;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Activities',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...activities.map((activity) => _buildActivityCard(activity)),
        ],
      ),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _performActivity(activity),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                IconHelper.getIconData(activity['icon']), 
                size: 40, 
                color: _colorFromHex(activity['color'])
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity['title'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      activity['description'],
                      style: const TextStyle(
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _buildResourceChips(activity),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.black54,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _performActivity(Map<String, dynamic> activity) {
  final energyCost = (activity['energyCost'] as num?)?.toInt() ?? 0;
  final moneyCost = (activity['moneyCost'] as num?)?.toDouble() ?? 0;
  
  // Deduct costs first
  widget.player.adjustStat("energy", -energyCost);
  widget.player.money -= moneyCost;
  
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
  
  // Handle variable money gain (for part-time work, etc.)
  if (activity.containsKey('moneyGainMin') && activity.containsKey('moneyGainMax')) {
    final min = (activity['moneyGainMin'] as num).toInt();
    final max = (activity['moneyGainMax'] as num).toInt();
    final earned = min + random.nextInt(max - min + 1);
    widget.player.money += earned.toDouble();
  }
  
  // Force UI refresh
  if (mounted) {
    setState(() {});
  }
  
  widget.onActivity(activity['id']);
}

  List<Widget> _buildResourceChips(Map<String, dynamic> activity) {
    final List<Widget> chips = [];
    
    final energyCost = (activity['energyCost'] as num?)?.toInt() ?? 0;
    final moneyCost = (activity['moneyCost'] as num?)?.toDouble() ?? 0;
    
    if (energyCost > 0) {
      chips.add(_buildResourceChip(
        Icons.battery_charging_full,
        '-$energyCost',
        Colors.orange,
      ));
    } else if (energyCost < 0) {
      chips.add(_buildResourceChip(
        Icons.battery_charging_full,
        '+${-energyCost}',
        Colors.green,
      ));
    }
    
    if (moneyCost > 0) {
      chips.add(_buildResourceChip(
        Icons.attach_money,
        '-\$${moneyCost.toStringAsFixed(0)}',
        Colors.red,
      ));
    }
    
    // Show money gain range if exists
    if (activity.containsKey('moneyGainMin') && activity.containsKey('moneyGainMax')) {
      chips.add(_buildResourceChip(
        Icons.attach_money,
        '+\$${activity['moneyGainMin']}-${activity['moneyGainMax']}',
        Colors.green,
      ));
    }
    
    return chips;
  }

  Widget _buildResourceChip(IconData icon, String text, Color color) {
    return Chip(
      backgroundColor: color.withAlpha(51),
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      avatar: Icon(icon, size: 16, color: color),
      label: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Color _colorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}
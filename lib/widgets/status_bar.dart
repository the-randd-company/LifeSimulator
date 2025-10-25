// lib/widgets/status_bar.dart
import 'package:flutter/material.dart';
import '../models/player.dart';

class StatusBar extends StatelessWidget {
  final Player player;
  
  const StatusBar({
    super.key,
    required this.player,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.withAlpha(76)),
      ),
      child: Column(
        children: [
          // Minimized stats - just icons and percentages (removed education)
          _buildMinimizedStats(),
        ],
      ),
    );
  }

  Widget _buildMinimizedStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildMinimizedStat(
          icon: Icons.favorite,
          value: player.health,
          color: Colors.red,
        ),
        _buildMinimizedStat(
          icon: Icons.bolt,
          value: player.energy,
          color: Colors.amber,
        ),
        _buildMinimizedStat(
          icon: Icons.emoji_emotions,
          value: player.happiness,
          color: Colors.green,
        ),
        // REMOVED: education stat
      ],
    );
  }

  Widget _buildMinimizedStat({
    required IconData icon,
    required int value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 4),
        Text(
          '$value%',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
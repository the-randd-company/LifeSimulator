// lib/screens/death_screen.dart
import 'package:flutter/material.dart';
import '../models/player.dart';

class DeathScreen extends StatelessWidget {
  final Player player;
  final VoidCallback onRestart;

  const DeathScreen({
    super.key,
    required this.player,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final bool isRetirement = player.causeOfDeath?.contains("retired") == true || 
                             player.causeOfDeath?.contains("Congratulations") == true;

    return Scaffold(
      backgroundColor: isRetirement ? Colors.green.shade50 : Colors.red.shade50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isRetirement ? Icons.celebration : Icons.sentiment_very_dissatisfied,
                size: 80,
                color: isRetirement ? Colors.green : Colors.red,
              ),
              const SizedBox(height: 24),
              Text(
                isRetirement ? 'Congratulations!' : 'Game Over',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isRetirement ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                player.causeOfDeath ?? "Your journey has ended.",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, height: 1.4),
              ),
              const SizedBox(height: 32),
              
              // Statistics Card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Text(
                        'Final Statistics',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildStatRow('Age', '${player.age}'),
                      _buildStatRow('Money', '\$${player.money.toStringAsFixed(2)}'),
                      _buildStatRow('Health', '${player.health}'),
                      _buildStatRow('Energy', '${player.energy}'),
                      _buildStatRow('Happiness', '${player.happiness}'),
                      _buildStatRow('Job', player.job?.title ?? 'Unemployed'),
                      _buildStatRow('Possessions', '${player.possessions.length} items'),
                      _buildStatRow('Relationships', '${player.relationships.length} people'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Action Buttons
              Column(
                children: [
                  ElevatedButton(
                    onPressed: onRestart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRetirement ? Colors.green : Colors.blue,
                      minimumSize: const Size(200, 50),
                    ),
                    child: const Text(
                      'Start New Life',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      // This would close the app
                      // For a real app, you might want to use SystemNavigator.pop()
                      // For now, just go back to welcome screen
                      onRestart();
                    },
                    child: const Text(
                      'Exit Game',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
// lib/utils/dialogs.dart
import 'package:flutter/material.dart';
import '../models/player.dart';

class GameDialogs {
  static void showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Play'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome to Life Simulator!', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text('In this game, you manage your life from age 18 to retirement. Here\'s how to play:'),
              SizedBox(height: 10),
              Text('• Activities Tab: Perform daily activities like studying, exercising, and working'),
              Text('• Career Tab: Find jobs and work to earn money'),
              Text('• Store Tab: Buy items to improve your stats'),
              Text('• Relationships Tab: Socialize and build relationships'),
              Text('• Inventory Tab: View items you own'),
              SizedBox(height: 10),
              Text('Keep an eye on your health, energy, and happiness levels.'),
              SizedBox(height: 10),
              Text('You can die from:'),
              Text('- Health dropping to zero'),
              Text('- Extreme unhappiness'),
              Text('- Severe debt'),
              Text('Or you can reach retirement at age 80.'),
              SizedBox(height: 10),
              Text('All game content is customizable through config files!', 
                style: TextStyle(fontStyle: FontStyle.italic)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  static void showGameOver(
    BuildContext context, 
    String message, 
    Player player, 
    {required VoidCallback onRestart}
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Over'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              const Text('Final Statistics:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text('Age: ${player.age}'),
              Text('Money: \$${player.money.toStringAsFixed(2)}'),
              Text('Health: ${player.health}'),
              Text('Energy: ${player.energy}'),
              Text('Happiness: ${player.happiness}'),
              Text('Job: ${player.job?.title ?? 'Unemployed'}'),
              const SizedBox(height: 10),
              Text('Possessions: ${player.possessions.isEmpty ? "None" : player.possessions.length.toString()} items'),
              Text('Relationships: ${player.relationships.isEmpty ? "None" : player.relationships.length.toString()} people'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRestart();
            },
            child: const Text('Start New Game'),
          ),
        ],
      ),
    );
  }
}
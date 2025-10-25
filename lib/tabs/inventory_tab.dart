// lib/tabs/inventory_tab.dart
import 'package:flutter/material.dart';
import '../models/player.dart';

class InventoryTab extends StatelessWidget {
  final Player player;

  const InventoryTab({
    super.key,
    required this.player,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: player.possessions.isEmpty
          ? const Center(
              child: Text(
                'You don\'t own any items yet.\nVisit the App Store to buy something!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: player.possessions.length,
              itemBuilder: (context, index) {
                final item = player.possessions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: ListTile(
                    leading: _getIconForItem(item),
                    title: Text(item),
                    subtitle: Text(_getDescriptionForItem(item)),
                  ),
                );
              },
            ),
    );
  }
  
  Icon _getIconForItem(String item) {
    if (item.contains('Phone') || item.contains('Smartphone')) {
      return const Icon(Icons.phone_android);
    } else if (item.contains('Car')) {
      return const Icon(Icons.directions_car);
    } else if (item.contains('Food') || item.contains('Dinner')) {
      return const Icon(Icons.fastfood);
    } else if (item.contains('Clothes')) {
      return const Icon(Icons.shopping_bag);
    } else if (item.contains('Book')) {
      return const Icon(Icons.book);
    } else if (item.contains('Computer') || item.contains('Laptop')) {
      return const Icon(Icons.computer);
    } else {
      return const Icon(Icons.shopping_basket);
    }
  }
  
  String _getDescriptionForItem(String item) {
    if (item.contains('Phone') || item.contains('Smartphone')) {
      return 'A device to keep you connected';
    } else if (item.contains('Car')) {
      return 'Your personal transportation';
    } else if (item.contains('Food') || item.contains('Dinner')) {
      return 'Delicious nourishment';
    } else if (item.contains('Clothes')) {
      return 'Stylish apparel';
    } else if (item.contains('Book')) {
      return 'Knowledge in written form';
    } else if (item.contains('Computer') || item.contains('Laptop')) {
      return 'Your digital workstation';
    } else {
      return 'A useful possession';
    }
  }
}
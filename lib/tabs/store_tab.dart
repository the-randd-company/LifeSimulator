import 'package:flutter/material.dart';
import '../models/player.dart';
import '../utils/config_loader.dart';
// Add this import

class StoreTab extends StatefulWidget {
  final Player player;
  final Function(String, {String? message}) onActivity;

  const StoreTab({
    super.key,
    required this.player,
    required this.onActivity,
  });

  @override
  StoreTabState createState() => StoreTabState();
}

class StoreTabState extends State<StoreTab> {
  List<dynamic> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStore();
  }

  Future<void> _loadStore() async {
    final loadedCategories = await ConfigLoader.loadStoreItems();
    setState(() {
      categories = loadedCategories;
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
              'Store',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Your Money: \$${widget.player.money.toStringAsFixed(2)}', // Fixed: removed backslash
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            
            ...categories.map((category) => _buildStoreCategory(category)),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreCategory(Map<String, dynamic> category) {
    final items = category['items'] as List<dynamic>;
    final iconData = _getIconFromString(category['icon'] as String);
    final color = _colorFromHex(category['color'] as String);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              Icon(iconData, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                category['name'],
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        ...items.map((item) => _buildStoreItem(item)),
        const Divider(height: 32),
      ],
    );
  }

  Widget _buildStoreItem(Map<String, dynamic> item) {
    final cost = (item['cost'] as num).toDouble();
    final bool canAfford = widget.player.money >= cost;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey.shade200,
              child: Icon(
                _getIconFromString(item['icon'] as String),
                color: Colors.black87,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['description'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    children: [
                      if ((item['health'] as num?)?.toInt() != 0)
                        _buildStatChip(
                          'Health',
                          (item['health'] as num?)?.toInt() ?? 0,
                          Icons.favorite,
                          Colors.red,
                        ),
                      if ((item['energy'] as num?)?.toInt() != 0)
                        _buildStatChip(
                          'Energy',
                          (item['energy'] as num?)?.toInt() ?? 0,
                          Icons.bolt,
                          Colors.amber,
                        ),
                      if ((item['happiness'] as num?)?.toInt() != 0)
                        _buildStatChip(
                          'Happiness',
                          (item['happiness'] as num?)?.toInt() ?? 0,
                          Icons.sentiment_satisfied_alt,
                          Colors.blue,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${cost.toStringAsFixed(0)}', // Fixed: removed backslash
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: canAfford ? Colors.black : Colors.red,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: canAfford ? () => _purchaseItem(item) : null,
                  child: const Text('Buy'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _purchaseItem(Map<String, dynamic> item) {
  final cost = (item['cost'] as num).toDouble();
  
  widget.player.money -= cost;
  
  // Check if this is a diet tier item
  if (item.containsKey('dietTier')) {
    widget.player.setDietTier(item['dietTier'] as String);
  }
  
  // Apply immediate stat changes
  if ((item['health'] as num?)?.toInt() != 0) {
    widget.player.adjustStat("health", (item['health'] as num).toInt());
  }
  if ((item['energy'] as num?)?.toInt() != 0) {
    widget.player.adjustStat("energy", (item['energy'] as num).toInt());
  }
  if ((item['happiness'] as num?)?.toInt() != 0) {
    widget.player.adjustStat("happiness", (item['happiness'] as num).toInt());
  }
  
  // Only add to possessions if not a diet item (diet is consumed weekly)
  if (!item.containsKey('dietTier')) {
    widget.player.possessions.add(item['name']);
  }
  
  // Force UI refresh
  if (mounted) {
    setState(() {});
  }
  
  widget.onActivity('purchase');
}

  Widget _buildStatChip(String label, int value, IconData icon, Color color) {
    return Chip(
      backgroundColor: color.withAlpha(25),
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      avatar: Icon(icon, size: 16, color: color),
      label: Text(
        '$label ${value > 0 ? "+$value" : value}',
        style: TextStyle(
          fontSize: 12,
          color: color.withAlpha(204),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'fastfood': return Icons.fastfood;
      case 'devices': return Icons.devices;
      case 'directions_car': return Icons.directions_car;
      case 'beach_access': return Icons.beach_access;
      case 'lunch_dining': return Icons.lunch_dining;
      case 'restaurant': return Icons.restaurant;
      case 'medication': return Icons.medication;
      case 'smartphone': return Icons.smartphone;
      case 'laptop': return Icons.laptop;
      case 'games': return Icons.games;
      case 'pedal_bike': return Icons.pedal_bike;
      case 'airport_shuttle': return Icons.airport_shuttle;
      case 'movie': return Icons.movie;
      case 'weekend': return Icons.weekend;
      case 'flight': return Icons.flight;
      case 'group': return Icons.group;
      case 'coffee': return Icons.coffee;
      case 'local_bar': return Icons.local_bar;
      default: return Icons.shopping_basket;
    }
  }

  Color _colorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}
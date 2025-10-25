import 'package:flutter/material.dart';

class IconHelper {
  static IconData getIconData(String iconName) {
    switch (iconName) {
      // Education & Work
      case 'school': return Icons.school;
      case 'work': return Icons.work;
      case 'work_outline': return Icons.work_outline;
      
      // Health & Fitness
      case 'fitness_center': return Icons.fitness_center;
      case 'favorite': return Icons.favorite;
      case 'medication': return Icons.medication;
      
      // Social
      case 'people': return Icons.people;
      case 'person_outline': return Icons.person_outline;
      case 'family_restroom': return Icons.family_restroom;
      case 'group': return Icons.group;
      
      // Leisure
      case 'weekend': return Icons.weekend;
      case 'beach_access': return Icons.beach_access;
      case 'movie': return Icons.movie;
      case 'games': return Icons.games;
      
      // Food & Dining
      case 'fastfood': return Icons.fastfood;
      case 'restaurant': return Icons.restaurant;
      case 'lunch_dining': return Icons.lunch_dining;
      case 'coffee': return Icons.coffee;
      case 'local_bar': return Icons.local_bar;
      
      // Electronics & Devices
      case 'devices': return Icons.devices;
      case 'smartphone': return Icons.smartphone;
      case 'laptop': return Icons.laptop;
      case 'computer': return Icons.computer;
      
      // Transportation
      case 'directions_car': return Icons.directions_car;
      case 'pedal_bike': return Icons.pedal_bike;
      case 'airport_shuttle': return Icons.airport_shuttle;
      case 'flight': return Icons.flight;
      
      // Shopping & Inventory
      case 'shopping_basket': return Icons.shopping_basket;
      case 'shopping_bag': return Icons.shopping_bag;
      case 'inventory_2': return Icons.inventory_2;
      
      // Money
      case 'attach_money': return Icons.attach_money;
      case 'money': return Icons.monetization_on;
      
      // Misc
      case 'bolt': return Icons.bolt;
      case 'battery_charging_full': return Icons.battery_charging_full;
      case 'sentiment_satisfied_alt': return Icons.sentiment_satisfied_alt;
      
      default: return Icons.circle;
    }
  }
}
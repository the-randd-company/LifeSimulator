// lib/screens/game_screen.dart
import 'package:flutter/material.dart';
import 'dart:math';
import '../models/player.dart';
import '../utils/config_loader.dart';
import '../utils/game_events.dart';
import '../tabs/inventory_tab.dart';
import '../tabs/career_tab.dart';
import '../tabs/activities_tab.dart';
import '../tabs/relationships_tab.dart';
import '../tabs/store_tab.dart';
import './welcome_screen.dart';
import './death_screen.dart';
import '../widgets/status_bar.dart';
import '../utils/money_formatter.dart';

class GameScreen extends StatefulWidget {
  final Player player;

  const GameScreen({
    super.key,
    required this.player,
  });

  @override
  State<GameScreen> createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> {
  int week = 1;
  int year = 0;
  final Random random = Random();
  bool _isUpdatingWeek = false;
  int _currentIndex = 0;
  
  // Config-loaded settings
  Map<String, dynamic> gameSettings = {};
  bool settingsLoaded = false;

  late final List<Widget> _tabs;
  
  @override
  void initState() {
    super.initState();
    _loadGameSettings();
    _tabs = [
      ActivitiesTab(player: widget.player, onActivity: _handleActivity),
      CareerTab(player: widget.player, onActivity: _handleActivity),
      StoreTab(player: widget.player, onActivity: _handleActivity),
      RelationshipsTab(player: widget.player, onActivity: _handleActivity),
      InventoryTab(player: widget.player),
    ];
  }

  Future<void> _loadGameSettings() async {
    final settings = await ConfigLoader.loadGameSettings();
    setState(() {
      gameSettings = settings;
      settingsLoaded = true;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    if (!settingsLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left side: Week and Age
            Row(
              children: [
                // Week widget
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withAlpha(25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue.withAlpha(76)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.blue[700]),
                      const SizedBox(width: 6),
                      Text(
                        'Week $week',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Age widget
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.purple.withAlpha(25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.purple.withAlpha(76)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.person, size: 16, color: Colors.purple[700]),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.player.age}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Right side: Money
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(51),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green.withAlpha(127)),
              ),
              child: Row(
                children: [
                  Icon(Icons.attach_money, size: 16, color: Colors.green[700]),
                  const SizedBox(width: 4),
                  Text(
                    formatMoneyCompact(widget.player.money),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          StatusBar(
            player: widget.player,
          ),
          Expanded(child: _tabs[_currentIndex]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.local_activity), label: 'Activities'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Career'),
          BottomNavigationBarItem(icon: Icon(Icons.apps), label: 'Store'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Relationships'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Inventory'),
        ],
      ),
    );
  }

  void _handleActivity(String activity, {String? message}) {
    setState(() {});
    
    // Check death conditions after activity
    if (widget.player.checkDeathConditions()) {
      Future.microtask(() {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => DeathScreen(
                player: widget.player,
                onRestart: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                  );
                },
              ),
            ),
          );
        }
      });
    } else {
      // Only update week if player is still alive
      _updateWeek();
    }
  }

  void _updateWeek() {
    if (_isUpdatingWeek) return;
    _isUpdatingWeek = true;
    
    try {
      week++;
      
      // Track job tenure
      if (widget.player.job != null) {
        widget.player.weeksInCurrentJob++;
      }
      
      // Apply consequences from config
      _applyConsequences();
      
      // Handle year transition (52 weeks in a year)
      if (week > 52) {
        week = 1;
        year++;
        widget.player.age++;
        
        if (widget.player.job != null) {
          widget.player.money += widget.player.job!.salary;
        }
        
        // Apply weekly expenses
        widget.player.applyWeeklyExpenses();
      }
      
      // Apply weekly passive effects (happiness decay, energy recovery, diet-based health)
      widget.player.applyWeeklyPassiveEffects();
      
      // Random events from config
      final eventChance = (gameSettings['randomEventChance'] as num?)?.toDouble() ?? 0.3;
      if (random.nextDouble() < eventChance) {
        Future.microtask(() async {
          await GameEvents.triggerRandomEvent(widget.player, random);
        });
      }

      // Update negative stat tracking
      widget.player.updateNegativeStatTracking();

      // Check death conditions after all updates
      if (widget.player.checkDeathConditions()) {
        Future.microtask(() {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => DeathScreen(
                  player: widget.player,
                  onRestart: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                    );
                  },
                ),
              ),
            );
          }
        });
        return; // Stop further processing if player died
      }
    } finally {
      _isUpdatingWeek = false;
    }
  }

  void _applyConsequences() {
    final consequences = gameSettings['consequences'] as Map<String, dynamic>?;
    if (consequences == null) return;
    
    // Low happiness
    final lowHappiness = consequences['lowHappiness'] as Map<String, dynamic>?;
    if (lowHappiness != null) {
      final threshold = (lowHappiness['threshold'] as num?)?.toInt() ?? 20;
      if (widget.player.happiness <= threshold) {
        final penalty = (lowHappiness['healthPenalty'] as num?)?.toInt() ?? -10;
        widget.player.adjustStat("health", penalty);
      }
    }
    
    // Low health
    final lowHealth = consequences['lowHealth'] as Map<String, dynamic>?;
    if (lowHealth != null) {
      final threshold = (lowHealth['threshold'] as num?)?.toInt() ?? 30;
      if (widget.player.health <= threshold) {
        final penalty = (lowHealth['energyPenalty'] as num?)?.toInt() ?? -15;
        widget.player.adjustStat("energy", penalty);
      }
    }
    
    // Low energy
    final lowEnergy = consequences['lowEnergy'] as Map<String, dynamic>?;
    if (lowEnergy != null) {
      final threshold = (lowEnergy['threshold'] as num?)?.toInt() ?? 20;
      if (widget.player.energy <= threshold) {
        final penalty = (lowEnergy['happinessPenalty'] as num?)?.toInt() ?? -10;
        widget.player.adjustStat("happiness", penalty);
      }
    }
    
    // In debt
    final inDebt = consequences['inDebt'] as Map<String, dynamic>?;
    if (inDebt != null) {
      final threshold = (inDebt['threshold'] as num?)?.toDouble() ?? 0;
      if (widget.player.money < threshold) {
        final penalty = (inDebt['happinessPenalty'] as num?)?.toInt() ?? -10;
        widget.player.adjustStat("happiness", penalty);
      }
    }
  }
}
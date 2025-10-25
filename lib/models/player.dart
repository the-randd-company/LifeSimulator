// lib/models/player.dart
import 'job.dart';
import 'relationship.dart';

// Work Experience Model
class WorkExperience {
  String title;
  String company;
  String industry;
  String level; // 'entry', 'mid', 'senior', 'support', 'executive'
  int weeksWorked;
  double salary;
  DateTime startDate;
  DateTime? endDate;
  
  WorkExperience({
    required this.title,
    required this.company,
    required this.industry,
    required this.level,
    required this.weeksWorked,
    required this.salary,
    required this.startDate,
    this.endDate,
  });
  
  double calculateExperienceValue() {
    double levelValue = ExperienceValueSystem.getLevelValue(level);
    double tenureMultiplier = 1.0 + (weeksWorked / 52.0) * 0.1;
    double industryMultiplier = ExperienceValueSystem.getIndustryMultiplier(industry);
    return levelValue * tenureMultiplier * industryMultiplier;
  }
  
  double getYearsOfExperience() => weeksWorked / 52.0;
}

// Experience Value System
class ExperienceValueSystem {
  static const Map<String, double> levelValues = {
    'entry': 1.0,
    'mid': 2.5,
    'senior': 5.0,
    'support': 1.5,
    'executive': 10.0,
  };
  
  static const Map<String, double> industryMultipliers = {
    'Technology': 1.3,
    'Finance': 1.25,
    'Healthcare': 1.2,
    'Education': 1.0,
    'Retail': 0.9,
    'Food Service': 0.8,
  };
  
  static double getLevelValue(String level) => levelValues[level] ?? 1.0;
  static double getIndustryMultiplier(String industry) => industryMultipliers[industry] ?? 1.0;
  
  static double calculateTotalExperienceValue(List<WorkExperience> experiences) {
    return experiences.fold(0.0, (sum, exp) => sum + exp.calculateExperienceValue());
  }
  
  static double getIndustryExperience(List<WorkExperience> experiences, String industry) {
    return experiences
        .where((exp) => exp.industry == industry)
        .fold(0.0, (sum, exp) => sum + exp.calculateExperienceValue());
  }
  
  static double getLevelExperience(List<WorkExperience> experiences, String level) {
    return experiences
        .where((exp) => exp.level == level)
        .fold(0.0, (sum, exp) => sum + exp.calculateExperienceValue());
  }
  
  static double getTotalYearsWorked(List<WorkExperience> experiences) {
    return experiences.fold(0.0, (sum, exp) => sum + exp.getYearsOfExperience());
  }
  
  static double calculateSalaryBoost(
    List<WorkExperience> experiences,
    String targetIndustry,
    String targetLevel,
  ) {
    double industryValue = getIndustryExperience(experiences, targetIndustry);
    double levelValue = getLevelExperience(experiences, targetLevel);
    double totalValue = calculateTotalExperienceValue(experiences);
    
    double industryBonus = industryValue * 0.15;
    double levelBonus = levelValue * 0.10;
    double generalBonus = totalValue * 0.05;
    
    return 1.0 + industryBonus + levelBonus + generalBonus;
  }
}

class Player {
  String name;
  int age = 18;
  int health = 100;
  int energy = 100;
  double money = 1000;
  int happiness = 50;
  Job? job; // REMOVED: education field
  List<String> possessions = [];
  List<Relationship> relationships = [];
  bool isAlive = true;
  String? causeOfDeath;
  
  Map<String, double> weeklyExpenses = {};
  
  // Track weeks each stat has been below 0
  int weeksHealthBelowZero = 0;
  int weeksEnergyBelowZero = 0;
  int weeksHappinessBelowZero = 0;
  int weeksMoneyBelowZero = 0;
  
  // Diet tier tracking (affects weekly health)
  // Tiers: 'none', 'poor', 'basic', 'good', 'premium'
  String currentDietTier = 'none';
  int weeksOnCurrentDiet = 0;
  
  // Work experience tracking
  List<WorkExperience> workHistory = [];
  int weeksInCurrentJob = 0;
  DateTime? currentJobStartDate;
  String? currentJobLevel; // Track level of current job
  
  Player(this.name);
  
  // Create player from config
  factory Player.fromConfig(String name, Map<String, dynamic> config) {
    final player = Player(name);
    
    // Set starting age
    player.age = (config['startingAge'] as num?)?.toInt() ?? 18;
    
    // Set starting money
    player.money = (config['startingMoney'] as num?)?.toDouble() ?? 1000;
    
    // Set starting stats
    final startingStats = config['startingStats'] as Map<String, dynamic>?;
    if (startingStats != null) {
      player.health = (startingStats['health'] as num?)?.toInt() ?? 100;
      player.energy = (startingStats['energy'] as num?)?.toInt() ?? 100;
      player.happiness = (startingStats['happiness'] as num?)?.toInt() ?? 50;
      // REMOVED: education assignment
    }
    
    return player;
  }
  
  double getTotalWeeklyExpenses() {
    double total = 0;
    weeklyExpenses.forEach((_, amount) {
      total += amount;
    });
    return total;
  }
  
  void applyWeeklyExpenses() {
    double total = getTotalWeeklyExpenses();
    if (total > 0) {
      money -= total;
      adjustStat('happiness', -2); // Expenses reduce happiness
    }
  }
  
  void setDietTier(String tier) {
    if (tier != currentDietTier) {
      currentDietTier = tier;
      weeksOnCurrentDiet = 0;
    }
  }
  
  void applyWeeklyPassiveEffects() {
    // Natural happiness decay (-3 per week)
    adjustStat('happiness', -3);
    
    // Natural energy recovery (+15 per week from rest)
    adjustStat('energy', 15);
    
    // Health changes based on diet tier
    weeksOnCurrentDiet++;
    switch (currentDietTier) {
      case 'none':
        adjustStat('health', -10); // No food = severe health loss
        break;
      case 'poor':
        adjustStat('health', -5); // Poor diet = health loss
        break;
      case 'basic':
        adjustStat('health', 0); // Basic diet = neutral
        break;
      case 'good':
        adjustStat('health', 3); // Good diet = slight health gain
        break;
      case 'premium':
        adjustStat('health', 5); // Premium diet = good health gain
        break;
    }
    
    // Reset diet tier after applying (must buy food each week)
    currentDietTier = 'none';
    weeksOnCurrentDiet = 0;
  }
  
  void updateNegativeStatTracking() {
    // Track health
    if (health < 0) {
      weeksHealthBelowZero++;
    } else {
      weeksHealthBelowZero = 0;
    }
    
    // Track energy
    if (energy < 0) {
      weeksEnergyBelowZero++;
    } else {
      weeksEnergyBelowZero = 0;
    }
    
    // Track happiness
    if (happiness < 0) {
      weeksHappinessBelowZero++;
    } else {
      weeksHappinessBelowZero = 0;
    }
    
    // Track money
    if (money < 0) {
      weeksMoneyBelowZero++;
    } else {
      weeksMoneyBelowZero = 0;
    }
  }
  
  bool checkDeathConditions() {
    // Check if any stat has been below 0 for 3+ weeks
    if (weeksHealthBelowZero >= 3) {
      causeOfDeath = "Your health remained critical for too long. You died from poor health.";
      isAlive = false;
      return true;
    }
    
    if (weeksEnergyBelowZero >= 3) {
      causeOfDeath = "You were exhausted for too long. Your body gave out from extreme fatigue.";
      isAlive = false;
      return true;
    }
    
    if (weeksHappinessBelowZero >= 3) {
      causeOfDeath = "You suffered from severe depression for too long and couldn't recover.";
      isAlive = false;
      return true;
    }
    
    if (weeksMoneyBelowZero >= 3) {
      causeOfDeath = "You were in debt for too long and couldn't recover financially.";
      isAlive = false;
      return true;
    }
    
    // Check retirement age
    if (age >= 80) {
      causeOfDeath = "Congratulations! You lived to the age of $age and retired.";
      isAlive = false;
      return true;
    }
    
    return false;
  }
  
  void adjustStat(String stat, int amount) {
    switch (stat) {
      case "health":
        health = (health + amount).clamp(-100, 100);
        break;
      case "energy":
        energy = (energy + amount).clamp(-100, 100);
        break;
      case "happiness":
        happiness = (happiness + amount).clamp(-100, 100);
        break;
      // REMOVED: education case
    }
  }
}
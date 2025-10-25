import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';
import '../models/player.dart';
import '../models/job.dart';
import '../utils/config_loader.dart';
import '../utils/icon_helper.dart';

class CareerTab extends StatefulWidget {
  final Player player;
  final Function(String, {String? message}) onActivity;

  const CareerTab({
    super.key,
    required this.player,
    required this.onActivity,
  });

  @override
  CareerTabState createState() => CareerTabState();
}

class CareerTabState extends State<CareerTab> {
  List<dynamic> industries = [];
  bool isLoading = true;
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    _loadIndustries();
  }

  Future<void> _loadIndustries() async {
    final jobsData = await ConfigLoader.loadConfig('assets/config/jobs.json');
    setState(() {
      industries = jobsData['industries'] as List<dynamic>? ?? [];
      isLoading = false;
    });
    if (industries.isEmpty) {
      debugPrint('Warning: No industries loaded from jobs.json');
      debugPrint('JobsData keys: ${jobsData.keys}');
    } else {
      debugPrint('Loaded ${industries.length} industries');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Current Career'),
              Tab(text: 'Job Market'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCurrentCareer(context),
            _buildJobMarket(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentCareer(BuildContext context) {
    return widget.player.job == null
        ? const Center(
            child: Text(
              'You are currently unemployed.\nGo to the Job Market tab to find work!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.player.job!.title,
                          style: const TextStyle(
                            fontSize: 24, 
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Company: ${widget.player.job!.company}',
                          style: const TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Industry: ${widget.player.job!.industry}',
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const Divider(height: 24),
                        Text(
                          'Annual Salary: \$${widget.player.job!.salary.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Daily Income: \$${(widget.player.job!.salary / 365).toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    double dailyIncome = widget.player.job!.salary / 365;
                    widget.player.money += dailyIncome;
                    widget.player.adjustStat("energy", -40);
                    widget.player.adjustStat("happiness", -10);
                    widget.onActivity(
                      'work',
                      message: "You worked today and earned \$${dailyIncome.toStringAsFixed(2)}.",
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text('Go to Work (Energy: -40)'),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    // Save job to work history before quitting
                    if (widget.player.currentJobStartDate != null) {
                      final currentJob = widget.player.job!;
                      widget.player.workHistory.add(
                        WorkExperience(
                          title: currentJob.title,
                          company: currentJob.company,
                          industry: currentJob.industry,
                          level: widget.player.currentJobLevel ?? 'entry',
                          weeksWorked: widget.player.weeksInCurrentJob,
                          salary: currentJob.salary,
                          startDate: widget.player.currentJobStartDate!,
                          endDate: DateTime.now(),
                        ),
                      );
                    }
                    
                    widget.player.job = null;
                    widget.player.weeksInCurrentJob = 0;
                    widget.player.currentJobStartDate = null;
                    widget.player.currentJobLevel = null;
                    
                    widget.onActivity(
                      'quit',
                      message: "You quit your job. Experience added to your resume.",
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text('Quit Job'),
                ),
              ],
            ),
          );
  }

  Widget _buildJobMarket(BuildContext context) {
    if (industries.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No jobs available.\n\nPlease restart the app to load job data.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: industries.length,
      itemBuilder: (context, index) {
        final industry = industries[index] as Map<String, dynamic>;
        return _buildIndustryCard(industry);
      },
    );
  }

  Widget _buildIndustryCard(Map<String, dynamic> industry) {
    final color = _colorFromHex(industry['color'] as String);
    final iconData = IconHelper.getIconData(industry['icon'] as String);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Icon(iconData, color: color, size: 32),
        title: Text(
          industry['name'],
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        subtitle: Text('${_getJobCount(industry)} positions available'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildJobListings(industry),
            ),
          ),
        ],
      ),
    );
  }

  int _getJobCount(Map<String, dynamic> industry) {
    final positions = industry['positions'] as Map<String, dynamic>;
    int count = 0;
    positions.forEach((tier, jobs) {
      count += (jobs as List).length;
    });
    return count;
  }

  List<Widget> _buildJobListings(Map<String, dynamic> industry) {
    final List<Widget> listings = [];
    final positions = industry['positions'] as Map<String, dynamic>;
    final companies = industry['companies'] as List<dynamic>;
    
    // Order: entry, mid, senior, support, executive
    final tierOrder = ['entry', 'mid', 'senior', 'support', 'executive'];
    final tierLabels = {
      'entry': 'Entry Level (10%)',
      'mid': 'Mid Level (25%)',
      'senior': 'Senior / Manager (35%)',
      'support': 'Support / HR (25%)',
      'executive': 'Executive (5%)',
    };
    
    for (var tier in tierOrder) {
      if (positions.containsKey(tier)) {
        listings.add(
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              tierLabels[tier]!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
        );
        
        final jobs = positions[tier] as List<dynamic>;
        for (var job in jobs) {
          listings.add(_buildJobListing(
            job as Map<String, dynamic>,
            companies[random.nextInt(companies.length)] as String,
            industry['name'] as String,
            tier,
          ));
        }
      }
    }
    
    return listings;
  }

  Widget _buildJobListing(
    Map<String, dynamic> jobData,
    String company,
    String industryName,
    String level,
  ) {
    final salaryMin = (jobData['salaryMin'] as num).toDouble();
    final salaryMax = (jobData['salaryMax'] as num).toDouble();
    final title = jobData['title'] as String;
    
    // Calculate potential salary boost
    double salaryBoost = ExperienceValueSystem.calculateSalaryBoost(
      widget.player.workHistory,
      industryName,
      level,
    );
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(company),
            const SizedBox(height: 4),
            Text(
              'Base Salary: \$${salaryMin.toStringAsFixed(0)} - \$${salaryMax.toStringAsFixed(0)}/year',
              style: const TextStyle(color: Colors.green),
            ),
            if (salaryBoost > 1.0)
              Text(
                'Your experience: +${((salaryBoost - 1.0) * 100).toStringAsFixed(1)}% bonus',
                style: const TextStyle(color: Colors.blue, fontSize: 12),
              ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () => _applyForJob(title, company, industryName, salaryMin, salaryMax, level),
          child: const Text('Apply'),
        ),
      ),
    );
  }

  void _applyForJob(
    String title,
    String company,
    String industry,
    double salaryMin,
    double salaryMax,
    String level,
  ) {
    // Save current job to work history if player has one
    if (widget.player.job != null && widget.player.currentJobStartDate != null) {
      final currentJob = widget.player.job!;
      widget.player.workHistory.add(
        WorkExperience(
          title: currentJob.title,
          company: currentJob.company,
          industry: currentJob.industry,
          level: widget.player.currentJobLevel ?? 'entry',
          weeksWorked: widget.player.weeksInCurrentJob,
          salary: currentJob.salary,
          startDate: widget.player.currentJobStartDate!,
          endDate: DateTime.now(),
        ),
      );
    }
    
    // Calculate salary boost based on experience
    double salaryBoost = ExperienceValueSystem.calculateSalaryBoost(
      widget.player.workHistory,
      industry,
      level,
    );
    
    // Generate random salary within range and apply experience boost
    double baseSalary = salaryMin + random.nextDouble() * (salaryMax - salaryMin);
    final salary = baseSalary * salaryBoost;
    
    // Set new job
    widget.player.job = Job(
      title: title,
      salary: salary,
      company: company,
      industry: industry,
    );
    
    // Reset job tracking
    widget.player.weeksInCurrentJob = 0;
    widget.player.currentJobStartDate = DateTime.now();
    widget.player.currentJobLevel = level;
    
    // Show experience bonus if applicable
    String experienceMessage = '';
    if (salaryBoost > 1.0) {
      double bonusPercent = (salaryBoost - 1.0) * 100;
      experienceMessage = ' (+${bonusPercent.toStringAsFixed(1)}% experience bonus!)';
    }
    
    widget.onActivity(
      'getJob',
      message: "Congratulations! You got the job as a $title at $company with a salary of \$${salary.toStringAsFixed(0)}/year$experienceMessage",
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
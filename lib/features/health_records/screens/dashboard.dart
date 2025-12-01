import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/health_record.dart';
import '../providers/health_provider.dart';
import 'add_record_screen.dart';
import 'list_screen.dart';
import 'welcome_screen.dart';

class DashboardScreen extends StatefulWidget {
  final HealthRecord? selectedRecord;
  const DashboardScreen({super.key, this.selectedRecord});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 1;

  static const int stepsGoal = 10000;
  static const int caloriesGoal = 2000;
  static const int waterGoal = 2000;

  @override
  void initState() {
    super.initState();
    // Load once
    Provider.of<HealthProvider>(context, listen: false).loadRecords();
    // Optionally start auto refresh if needed
    Provider.of<HealthProvider>(context, listen: false).startAutoRefresh();
  }

  @override
  Widget build(BuildContext context) {
    // We'll use StreamBuilder to rebuild when the provider stream emits
    final provider = Provider.of<HealthProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddRecordScreen()),
        ),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, size: 28),
      ),

      body: StreamBuilder<List<HealthRecord>>(
        stream: provider.recordsStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Use provider methods to compute totals / streak / achievements
          final todaySteps = provider.getTodayTotal('steps');
          final todayCalories = provider.getTodayTotal('calories');
          final todayWater = provider.getTodayTotal('water');

          bool isTodayEmpty = todaySteps == 0 && todayCalories == 0 && todayWater == 0;

          final steps = isTodayEmpty ? provider.getMonthTotal('steps') : todaySteps;
          final calories = isTodayEmpty ? provider.getMonthTotal('calories') : todayCalories;
          final water = isTodayEmpty ? provider.getMonthTotal('water') : todayWater;

          final dateTitle = isTodayEmpty ? "This Month Summary" : "Today’s Summary";

          // Achievements + streak
          final achievements = provider.getAchievements();
          final streak = provider.getDailyStreak();

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                

                const SizedBox(height: 10),

                // Gradient Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4A90E2), Color(0xFF8E44AD)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        dateTitle,
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Your daily health overview",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Pie Chart
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 250,
                    child: PieChart(
                      PieChartData(
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                        sections: _chartSections(steps, calories, water),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Summary cards
                _summaryCard(
                  icon: Icons.directions_walk,
                  label: "Steps",
                  value: steps,
                  goal: stepsGoal,
                  color: Colors.green,
                ),
                _summaryCard(
                  icon: Icons.local_fire_department,
                  label: "Calories",
                  value: calories,
                  goal: caloriesGoal,
                  color: Colors.orange,
                ),
                _summaryCard(
                  icon: Icons.water_drop,
                  label: "Water (ml)",
                  value: water,
                  goal: waterGoal,
                  color: Colors.blue,
                ),

                const SizedBox(height: 12),

                // Streak card (only show when > 0)
                if (streak > 0) _streakCard(streak),

                const SizedBox(height: 8),

                // Achievements section
                if (achievements.isNotEmpty) _achievementBadges(achievements) else
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: const Text(
                        'No achievements yet — keep going! 💙',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 15,
        onTap: (index) {
          if (index == _selectedIndex) return; 
          setState(() => _selectedIndex = index);

          if (index == 0) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const WelcomeScreen()));
          } else if (index == 1) {
            // already on dashboard - do nothing
          } else if (index == 2) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ListScreen()));
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Welcome"),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Records"),
        ],
      ),
    );
  }

          // Edit button
          InkWell(
            onTap: () {
              // Handle profile edit
            },
            borderRadius: BorderRadius.circular(50),
            child: const CircleAvatar(
              backgroundColor: Colors.white24,
              child: Icon(Icons.edit, color: Colors.white),
            ),
          )
  }

  // ACHIEVEMENT BADGES UI
  Widget _achievementBadges(List<String> badges) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Achievements",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: badges
                .map(
                  (b) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          b,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  // STREAK CARD
  Widget _streakCard(int streak) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.orangeAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orangeAccent.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department, color: Colors.orange, size: 32),
          const SizedBox(width: 14),
          Text(
            "$streak-Day Streak",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
          ),
        ],
      ),
    );
  }

  // SUMMARY CARD
  Widget _summaryCard({
    required IconData icon,
    required String label,
    required int value,
    required int goal,
    required Color color,
  }) {
    final pct = (value / goal).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color, size: 30),
        ),
        title: Text("$label: $value / $goal", style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: pct,
              color: color,
              backgroundColor: Colors.grey[300],
            ),
          ],
        ),
      ),
    );
  }

  // PIE CHART SECTIONS
  List<PieChartSectionData> _chartSections(int steps, int calories, int water) {
    final total = steps + calories + water;

    if (total == 0) {
      return [
        PieChartSectionData(
          value: 1,
          title: 'No Data',
          color: Colors.grey,
          radius: 50,
          titleStyle: const TextStyle(color: Colors.white),
        ),
      ];
    }

    return [
      PieChartSectionData(
        value: steps.toDouble(),
        title: '${((steps / total) * 100).toStringAsFixed(1)}%',
        color: Colors.green,
        radius: 55,
        titleStyle: const TextStyle(color: Colors.white),
      ),
      PieChartSectionData(
        value: calories.toDouble(),
        title: '${((calories / total) * 100).toStringAsFixed(1)}%',
        color: Colors.orange,
        radius: 55,
        titleStyle: const TextStyle(color: Colors.white),
      ),
      PieChartSectionData(
        value: water.toDouble(),
        title: '${((water / total) * 100).toStringAsFixed(1)}%',
        color: Colors.blue,
        radius: 55,
        titleStyle: const TextStyle(color: Colors.white),
      ),
    ];
}


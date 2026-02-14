import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reminder_provider.dart';
import '../widgets/circular_progress.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ReminderProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Stats')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircularProgressWidget(percent: provider.completionRate),
            const SizedBox(height: 24),
            Text(
              'Completed: ${provider.completedCount} / ${provider.items.length}',
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: provider.items.isNotEmpty
                        ? provider.items.length.toDouble()
                        : 1,
                    barTouchData: BarTouchData(enabled: true),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final labels = ['Work', 'Personal'];
                            final idx = value.toInt();
                            if (idx >= 0 && idx < labels.length) {
                              return Text(labels[idx]);
                            }
                            return const Text('');
                          },
                        ),
                      ),
                    ),
                    gridData: FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: _makeBarGroups(provider),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _makeBarGroups(ReminderProvider provider) {
    final work = provider.items
        .where((r) => r.type == 'Work')
        .length
        .toDouble();
    final personal = provider.items
        .where((r) => r.type == 'Personal')
        .length
        .toDouble();
    return [
      BarChartGroupData(
        x: 0,
        barRods: [BarChartRodData(toY: work, color: Colors.blueAccent)],
      ),
      BarChartGroupData(
        x: 1,
        barRods: [BarChartRodData(toY: personal, color: Colors.greenAccent)],
      ),
    ];
  }
}

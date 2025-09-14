import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final List<Map<String, dynamic>> historiques = [
    {'type': 'Vente', 'date': DateTime(2025, 1, 15)},
    {'type': 'Panne', 'date': DateTime(2025, 1, 28)},
    {'type': 'Vente', 'date': DateTime(2025, 2, 5)},
    {'type': 'Panne', 'date': DateTime(2025, 3, 10)},
    {'type': 'Vente', 'date': DateTime(2025, 3, 25)},
  ];

  int get totalVentes =>
      historiques.where((e) => e['type'] == 'Vente').length;

  int get totalPannes =>
      historiques.where((e) => e['type'] == 'Panne').length;

  List<PieChartSectionData> _generatePieChartSections() {
    final total = totalVentes + totalPannes;
    return [
      PieChartSectionData(
        value: totalVentes.toDouble(),
        title: '${((totalVentes / total) * 100).toStringAsFixed(1)}%',
        color: Colors.green,
        radius: 70,
      ),
      PieChartSectionData(
        value: totalPannes.toDouble(),
        title: '${((totalPannes / total) * 100).toStringAsFixed(1)}%',
        color: Colors.red,
        radius: 70,
      ),
    ];
  }

  List<BarChartGroupData> _generateBarData() {
    List<int> ventesParMois = List.filled(12, 0);
    List<int> pannesParMois = List.filled(12, 0);

    for (var h in historiques) {
      if (h['type'] == 'Vente') {
        ventesParMois[h['date'].month - 1]++;
      } else {
        pannesParMois[h['date'].month - 1]++;
      }
    }

    return List.generate(12, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
              toY: ventesParMois[index].toDouble(),
              color: Colors.green,
              width: 7),
          BarChartRodData(
              toY: pannesParMois[index].toDouble(),
              color: Colors.red,
              width: 7),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fond blanc ici
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text('Statistiques',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard("Total Ventes", totalVentes, Colors.green),
                _buildStatCard("Total Pannes", totalPannes, Colors.red),
              ],
            ),
            const SizedBox(height: 30),
            const Text('Répartition Ventes / Pannes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: _generatePieChartSections(),
                  centerSpaceRadius: 40,
                  sectionsSpace: 5,
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text('Évolution par mois',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  barGroups: _generateBarData(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const mois = [
                            'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                            'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                          ];
                          return Text(
                            mois[value.toInt()],
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, int count, Color color) {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(16),
        width: 140,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: color.withOpacity(0.1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$count',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color)),
            const SizedBox(height: 5),
            Text(title,
                style: TextStyle(fontSize: 14, color: color)),
          ],
        ),
      ),
    );
  }
}

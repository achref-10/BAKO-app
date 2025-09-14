import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class HistoriquePage extends StatefulWidget {
  const HistoriquePage({super.key});

  @override
  State<HistoriquePage> createState() => _HistoriquePageState();
}

class _HistoriquePageState extends State<HistoriquePage> {
  String _selectedFilter = 'Mensuel';

  final List<Map<String, dynamic>> historiques = [
    {'type': 'Vente', 'voiture': 'BEE123', 'date': DateTime(2025, 1, 15), 'client': 'Ali'},
    {'type': 'Panne', 'voiture': 'BVAN456', 'date': DateTime(2025, 1, 28), 'description': 'Batterie défectueuse'},
    {'type': 'Vente', 'voiture': 'B1X789', 'date': DateTime(2025, 2, 5), 'client': 'Salma'},
    {'type': 'Panne', 'voiture': 'BEE123', 'date': DateTime(2025, 3, 10), 'description': 'Moteur en surchauffe'},
    {'type': 'Vente', 'voiture': 'B1X111', 'date': DateTime(2025, 3, 25), 'client': 'Karim'},
  ];

  List<BarChartGroupData> _generateBarData(bool isPanne) {
    List<int> mois = List.filled(12, 0);
    for (var h in historiques) {
      if ((isPanne && h['type'] == 'Panne') || (!isPanne && h['type'] == 'Vente')) {
        mois[h['date'].month - 1]++;
      }
    }
    return List.generate(12, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: mois[index].toDouble(),
            width: 14,
            color: isPanne ? Colors.redAccent : Colors.green,
            borderRadius: BorderRadius.circular(6),
          ),
        ],
      );
    });
  }

  Widget _buildChart(String title, bool isPanne) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Container(
          height: 250,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: BarChart(
            BarChartData(
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, _) {
                      const mois = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                      return Text(mois[value.toInt()], style: const TextStyle(fontSize: 10));
                    },
                  ),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),
              ),
              barGroups: _generateBarData(isPanne),
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
            ),
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _filteredData() {
    if (_selectedFilter == 'Annuel') return historiques;
    final now = DateTime.now();
    return historiques.where((h) =>
    h['date'].month == now.month && h['date'].year == now.year).toList();
  }

  @override
  Widget build(BuildContext context) {
    final data = _filteredData();

    return Scaffold(
      backgroundColor: Colors.white, // 👈 Fond blanc ici
      appBar: AppBar(
        title: const Text("Historique", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF577f65),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              dropdownColor: Colors.white,
              value: _selectedFilter,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              items: const [
                DropdownMenuItem(value: 'Mensuel', child: Text('Mensuel')),
                DropdownMenuItem(value: 'Annuel', child: Text('Annuel')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
              },
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildChart("Pannes par mois", true),
            const SizedBox(height: 20),
            _buildChart("Ventes par mois", false),
            const SizedBox(height: 30),
            const Text("Détails de l'historique",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...data.map((entry) => Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                title: Text("${entry['type']} - ${entry['voiture']}",
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  "Date: ${entry['date'].toString().substring(0, 10)}\n"
                      "${entry['type'] == 'Vente' ? 'Client: ${entry['client']}' : 'Problème: ${entry['description']}'}",
                  style: const TextStyle(height: 1.5),
                ),
                leading: Icon(
                  entry['type'] == 'Vente' ? Icons.sell : Icons.warning,
                  color: entry['type'] == 'Vente' ? Colors.green : Colors.red,
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

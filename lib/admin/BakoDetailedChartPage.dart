import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

class BakoDetailedChartPage extends StatefulWidget {
  final Map<String, dynamic> vehicle;
  final String chartType; // 'battery', 'pv', 'motor', 'dcdc'

  const BakoDetailedChartPage({
    Key? key, 
    required this.vehicle,
    required this.chartType,
  }) : super(key: key);

  @override
  State<BakoDetailedChartPage> createState() => _BakoDetailedChartPageState();
}

class _BakoDetailedChartPageState extends State<BakoDetailedChartPage> {
  String selectedMetric = 'soc'; // Par défaut SOC pour batterie

  // Génération de données historiques simulées
  List<FlSpot> _generateHistoricalData(double baseValue, double variance, int points) {
    final random = math.Random();
    List<FlSpot> spots = [];
    
    for (int i = 0; i < points; i++) {
      double value = baseValue + (random.nextDouble() - 0.5) * variance;
      value = math.max(0, value);
      spots.add(FlSpot(i.toDouble(), value));
    }
    return spots;
  }

  // Obtenir les données selon le type de graphique
  Map<String, Map<String, dynamic>> _getChartData() {
    switch (widget.chartType) {
      case 'battery':
        return {
          'soc': {
            'data': _generateHistoricalData((widget.vehicle['battery'] ?? 0).toDouble(), 10, 20),
            'label': 'SOC (%)',
            'color': Colors.green,
            'currentValue': (widget.vehicle['battery'] ?? 0).toDouble(),
          },
          'voltage': {
            'data': _generateHistoricalData(57.4, 2, 20),
            'label': 'Tension (V)',
            'color': Colors.blue,
            'currentValue': 57.4,
          },
          'current': {
            'data': _generateHistoricalData(5.2, 8, 20),
            'label': 'Courant (A)',
            'color': Colors.orange,
            'currentValue': 5.2,
          },
          'temp': {
            'data': _generateHistoricalData(28.0, 4, 20),
            'label': 'Température (°C)',
            'color': Colors.red,
            'currentValue': 28.0,
          },
        };
      case 'pv':
        return {
          'power': {
            'data': _generateHistoricalData(1250, 300, 20),
            'label': 'Puissance PV (W)',
            'color': Colors.green,
            'currentValue': 1250.0,
          },
          'voltage': {
            'data': _generateHistoricalData(48.2, 3, 20),
            'label': 'Tension PV (V)',
            'color': Colors.blue,
            'currentValue': 48.2,
          },
          'current': {
            'data': _generateHistoricalData(26.0, 6, 20),
            'label': 'Courant PV (A)',
            'color': Colors.orange,
            'currentValue': 26.0,
          },
        };
      case 'motor':
        final bool isMoving = widget.vehicle['status'] == 'En route';
        return {
          'speed': {
            'data': _generateHistoricalData(isMoving ? 65.0 : 0.0, 20, 20),
            'label': 'Vitesse (km/h)',
            'color': Colors.blue,
            'currentValue': isMoving ? 65.0 : 0.0,
          },
          'power': {
            'data': _generateHistoricalData(isMoving ? 2800.0 : 0.0, 800, 20),
            'label': 'Puissance (W)',
            'color': Colors.green,
            'currentValue': isMoving ? 2800.0 : 0.0,
          },
          'temp': {
            'data': _generateHistoricalData(35.0, 5, 20),
            'label': 'Température (°C)',
            'color': Colors.red,
            'currentValue': 35.0,
          },
        };
      case 'dcdc':
        return {
          'input_voltage': {
            'data': _generateHistoricalData(57.4, 2, 20),
            'label': 'Tension Entrée (V)',
            'color': Colors.blue,
            'currentValue': 57.4,
          },
          'output_voltage': {
            'data': _generateHistoricalData(12.0, 0.5, 20),
            'label': 'Tension Sortie (V)',
            'color': Colors.green,
            'currentValue': 12.0,
          },
          'power': {
            'data': _generateHistoricalData(180, 50, 20),
            'label': 'Puissance (W)',
            'color': Colors.orange,
            'currentValue': 180.0,
          },
        };
      default:
        return <String, Map<String, dynamic>>{};
    }
  }

  @override
  void initState() {
    super.initState();
    // Définir la métrique par défaut selon le type
    switch (widget.chartType) {
      case 'battery':
        selectedMetric = 'soc';
        break;
      case 'pv':
        selectedMetric = 'power';
        break;
      case 'motor':
        selectedMetric = 'speed';
        break;
      case 'dcdc':
        selectedMetric = 'input_voltage';
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final chartData = _getChartData();
    final currentData = chartData[selectedMetric];
    
    if (currentData == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Erreur'),
        ),
        body: const Center(
          child: Text('Données non disponibles'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF00BCD4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BCD4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${_getChartTitle()} - ${widget.vehicle['id'] ?? 'Unknown'}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                // Régénérer les données pour simuler "Curve clear"
              });
            },
            child: const Text(
              'Curve clear',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Sélecteur de métriques
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: const Color(0xFF00BCD4),
            child: Row(
              children: chartData.keys.map((metric) {
                final isSelected = selectedMetric == metric;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => selectedMetric = metric),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected 
                          ? Colors.white.withOpacity(0.2)
                          : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected 
                          ? Border.all(color: Colors.white.withOpacity(0.5))
                          : null,
                      ),
                      child: Center(
                        child: Text(
                          _getMetricLabel(metric),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: isSelected 
                              ? FontWeight.bold 
                              : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Graphique principal
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Titre avec valeur actuelle
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentData['label'] ?? '',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                'Valeur actuelle',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: (currentData['color'] as Color).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              (currentData['currentValue'] as double).toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: currentData['color'] as Color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Graphique
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: true,
                              horizontalInterval: _getGridInterval(selectedMetric),
                              verticalInterval: 2,
                              getDrawingHorizontalLine: (value) {
                                return FlLine(
                                  color: Colors.grey[300]!,
                                  strokeWidth: 1,
                                  dashArray: [3, 3],
                                );
                              },
                              getDrawingVerticalLine: (value) {
                                return FlLine(
                                  color: Colors.grey[300]!,
                                  strokeWidth: 1,
                                  dashArray: [3, 3],
                                );
                              },
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  interval: 4,
                                  getTitlesWidget: (value, meta) {
                                    final time = DateTime.now().subtract(
                                      Duration(minutes: ((20 - value) * 5).toInt()),
                                    );
                                    return Text(
                                      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 10,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: _getGridInterval(selectedMetric),
                                  reservedSize: 40,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      value.toStringAsFixed(0),
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 10,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                            minX: 0,
                            maxX: 19,
                            minY: _getMinY(selectedMetric),
                            maxY: _getMaxY(selectedMetric),
                            lineBarsData: [
                              LineChartBarData(
                                spots: currentData['data'] as List<FlSpot>,
                                isCurved: true,
                                color: currentData['color'] as Color,
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: (currentData['color'] as Color).withOpacity(0.1),
                                ),
                              ),
                            ],
                            lineTouchData: LineTouchData(
                              enabled: true,
                                                              touchTooltipData: LineTouchTooltipData(
                                getTooltipColor: (touchedSpot) => Colors.black87,
                                tooltipBorderRadius: BorderRadius.circular(8),
                                getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                                  return touchedBarSpots.map((barSpot) {
                                    return LineTooltipItem(
                                      '${barSpot.y.toStringAsFixed(1)}\n${_getUnit(selectedMetric)}',
                                      const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    );
                                  }).toList();
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getChartTitle() {
    switch (widget.chartType) {
      case 'battery':
        return 'Historique Batterie';
      case 'pv':
        return 'Historique Panneaux PV';
      case 'motor':
        return 'Historique Moteur';
      case 'dcdc':
        return 'Historique DC-DC';
      default:
        return 'Historique';
    }
  }

  String _getMetricLabel(String metric) {
    switch (metric) {
      case 'soc':
        return 'SOC';
      case 'voltage':
        return 'Tension';
      case 'current':
        return 'Courant';
      case 'temp':
        return 'Temp';
      case 'power':
        return 'Puissance';
      case 'speed':
        return 'Vitesse';
      case 'input_voltage':
        return 'V. Entrée';
      case 'output_voltage':
        return 'V. Sortie';
      default:
        return metric;
    }
  }

  String _getUnit(String metric) {
    switch (metric) {
      case 'soc':
        return '%';
      case 'voltage':
      case 'input_voltage':
      case 'output_voltage':
        return 'V';
      case 'current':
        return 'A';
      case 'temp':
        return '°C';
      case 'power':
        return 'W';
      case 'speed':
        return 'km/h';
      default:
        return '';
    }
  }

  double _getGridInterval(String metric) {
    switch (metric) {
      case 'soc':
        return 20;
      case 'voltage':
      case 'input_voltage':
        return 10;
      case 'output_voltage':
        return 2;
      case 'current':
        return 5;
      case 'temp':
        return 10;
      case 'power':
        return 500;
      case 'speed':
        return 20;
      default:
        return 10;
    }
  }

  double _getMinY(String metric) {
    switch (metric) {
      case 'soc':
        return 0;
      case 'voltage':
      case 'input_voltage':
        return 40;
      case 'output_voltage':
        return 10;
      case 'current':
        return 0;
      case 'temp':
        return 15;
      case 'power':
        return 0;
      case 'speed':
        return 0;
      default:
        return 0;
    }
  }

  double _getMaxY(String metric) {
    switch (metric) {
      case 'soc':
        return 100;
      case 'voltage':
      case 'input_voltage':
        return 70;
      case 'output_voltage':
        return 15;
      case 'current':
        return 30;
      case 'temp':
        return 50;
      case 'power':
        return 3000;
      case 'speed':
        return 100;
      default:
        return 100;
    }
  }
}
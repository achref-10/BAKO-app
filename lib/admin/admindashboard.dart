import 'package:control_car/connexion_screen.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'BakoDetailedChartPage.dart';

// Modification de votre AdminDashboard existant pour ajouter la navigation vers les graphiques
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  bool _isRefreshing = false;

  // Données de la flotte
  final List<Map<String, dynamic>> vehicles = [
    {
      'id': 'BAKO001',
      'model': 'BAKO Bee',
      'client': 'Ahmed Ben Ali',
      'battery': 85,
      'status': 'En route',
      'location': 'Tunis Centre',
      'lastUpdate': '2 min ago',
      'isOnline': true,
      'range': 220,
      'issues': 0,
    },
    {
      'id': 'BAKO002',
      'model': 'BAKO B-Van',
      'client': 'Fatma Hadj',
      'battery': 45,
      'status': 'En charge',
      'location': 'La Marsa',
      'lastUpdate': '5 min ago',
      'isOnline': true,
      'range': 120,
      'issues': 0,
    },
    {
      'id': 'BAKO003',
      'model': 'BAKO Bee',
      'client': 'Mohamed Triki',
      'battery': 15,
      'status': 'Stationnée',
      'location': 'Sfax',
      'lastUpdate': '1h ago',
      'isOnline': false,
      'range': 40,
      'issues': 2,
    },
    {
      'id': 'BAKO004',
      'model': 'BAKO B-Van',
      'client': 'Leila Mansouri',
      'battery': 92,
      'status': 'En route',
      'location': 'Sousse',
      'lastUpdate': '1 min ago',
      'isOnline': true,
      'range': 280,
      'issues': 0,
    },
  ];

  // Statistiques globales
  int totalVehicles = 4;
  int onlineVehicles = 3;
  int chargingVehicles = 1;
  int criticalBatteryVehicles = 1;
  int vehiclesWithIssues = 1;
  double averageBattery = 59.25;

  Future<void> _refreshData() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF577F65),
        elevation: 0,
        title: const Text(
          'Dashboard Administrateur',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshData,
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _isRefreshing
          ? const Center(child: CircularProgressIndicator())
          : _buildCurrentPage(),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildFleetOverview();
      case 1:
        return _buildVehicleManagement();
      case 2:
        return _buildUsersManagement();
      case 3:
        return _buildAnalytics();
      case 4:
        return _buildMaintenanceAlerts();
      default:
        return _buildFleetOverview();
    }
  }

  Widget _buildFleetOverview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsOverview(),
          const SizedBox(height: 25),
          _buildFleetStatus(),
          const SizedBox(height: 25),
          _buildRecentActivity(),
          const SizedBox(height: 25),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildStatsOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vue d\'ensemble de la flotte',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 200, // Hauteur fixe pour éviter l'overflow
          child: GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            children: [
              _buildStatCard(
                'Total Véhicules',
                '$totalVehicles',
                Icons.directions_car,
                Colors.blue,
              ),
              _buildStatCard(
                'En ligne',
                '$onlineVehicles/$totalVehicles',
                Icons.wifi,
                Colors.green,
              ),
              _buildStatCard(
                'En charge',
                '$chargingVehicles',
                Icons.battery_charging_full,
                Colors.orange,
              ),
              _buildStatCard(
                'Alertes',
                '$vehiclesWithIssues',
                Icons.warning,
                Colors.red,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    Map<String, dynamic>? vehicle,
    String? chartType,
  }) {
    return GestureDetector(
      onTap: vehicle != null && chartType != null
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BakoDetailedChartPage(
                    vehicle: vehicle,
                    chartType: chartType,
                  ),
                ),
              );
            }
          : null,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            if (vehicle != null && chartType != null)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Icon(Icons.show_chart, size: 16, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFleetStatus() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'État des véhicules',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => setState(() => _selectedIndex = 1),
                child: const Text('Voir tout'),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ...vehicles.take(3).map((vehicle) => _buildVehicleCard(vehicle)),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(Map<String, dynamic> vehicle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(
            color: vehicle['isOnline'] ? Colors.green : Colors.red,
            width: 4,
          ),
        ),
      ),
      child: Column(
        children: [
          // Section des informations du véhicule (existante)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getStatusColor(vehicle['status']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getStatusIcon(vehicle['status']),
                  color: _getStatusColor(vehicle['status']),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          vehicle['id'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: vehicle['isOnline']
                                ? Colors.green
                                : Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            vehicle['isOnline'] ? 'EN LIGNE' : 'HORS LIGNE',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${vehicle['client']} - ${vehicle['model']}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      '${vehicle['location']} - ${vehicle['lastUpdate']}',
                      style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${vehicle['range']} km',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  if (vehicle['issues'] > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${vehicle['issues']} alerte(s)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Grid des métriques avec navigation vers les graphiques
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.8,
              children: [
                _buildStatCard(
                  'Batterie',
                  '${vehicle['battery']}%',
                  Icons.battery_full,
                  _getBatteryColor(vehicle['battery']),
                  vehicle: vehicle,
                  chartType: 'battery',
                ),
                _buildStatCard(
                  'PV',
                  '1.2kW',
                  Icons.wb_sunny,
                  Colors.green,
                  vehicle: vehicle,
                  chartType: 'pv',
                ),
                _buildStatCard(
                  'Moteur',
                  '${vehicle['status'] == 'En route' ? '65 km/h' : '0 km/h'}',
                  Icons.speed,
                  Colors.blue,
                  vehicle: vehicle,
                  chartType: 'motor',
                ),
                _buildStatCard(
                  'DC-DC',
                  '12V',
                  Icons.electrical_services,
                  Colors.orange,
                  vehicle: vehicle,
                  chartType: 'dcdc',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Fonction helper pour la couleur de la batterie
  Color _getBatteryColor(int battery) {
    if (battery > 50) return Colors.green;
    if (battery > 20) return Colors.orange;
    return Colors.red;
  }

  Widget _buildVehicleManagement() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Gestion des véhicules',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('Nouveau'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF577F65),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Rechercher par ID, client...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF577F65),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(15),
                      ),
                      child: const Icon(Icons.filter_list),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ...vehicles.map(
                  (vehicle) => _buildDetailedVehicleCard(vehicle),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedVehicleCard(Map<String, dynamic> vehicle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border(
          left: BorderSide(
            color: vehicle['isOnline'] ? Colors.green : Colors.red,
            width: 5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        vehicle['id'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: vehicle['isOnline']
                              ? Colors.green
                              : Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          vehicle['isOnline'] ? 'EN LIGNE' : 'HORS LIGNE',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    vehicle['model'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              PopupMenuButton<String>(
                onSelected: (value) => _handleVehicleAction(value, vehicle),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'details',
                    child: Row(
                      children: [
                        Icon(Icons.info, size: 18),
                        SizedBox(width: 8),
                        Text('Détails'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'remote_control',
                    child: Row(
                      children: [
                        Icon(Icons.settings_remote, size: 18),
                        SizedBox(width: 8),
                        Text('Contrôle à distance'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'maintenance',
                    child: Row(
                      children: [
                        Icon(Icons.build, size: 18),
                        SizedBox(width: 8),
                        Text('Maintenance'),
                      ],
                    ),
                  ),
                ],
                child: const Icon(Icons.more_vert),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Client',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      vehicle['client'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Localisation',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      vehicle['location'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'Batterie',
                  '${vehicle['battery']}%',
                  Icons.battery_full,
                  _getBatteryColor(vehicle['battery']),
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  'Autonomie',
                  '${vehicle['range']} km',
                  Icons.route,
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  'Statut',
                  vehicle['status'],
                  _getStatusIcon(vehicle['status']),
                  _getStatusColor(vehicle['status']),
                ),
              ),
            ],
          ),
          if (vehicle['issues'] > 0) ...[
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${vehicle['issues']} problème(s) détecté(s)',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _showVehicleIssues(vehicle),
                    child: const Text('Voir', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildUsersManagement() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Gestion des utilisateurs',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.person_add),
                label: const Text('Ajouter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF577F65),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher un utilisateur...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 20),
                ...vehicles.map((vehicle) => _buildUserCard(vehicle)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> vehicle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: const Color(0xFF577F65),
            child: Text(
              vehicle['client'].substring(0, 2).toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle['client'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Véhicule: ${vehicle['id']}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                Text(
                  'Dernière activité: ${vehicle['lastUpdate']}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: vehicle['isOnline'] ? Colors.green : Colors.grey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  vehicle['isOnline'] ? 'ACTIF' : 'INACTIF',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _contactUser(vehicle['client']),
                    icon: const Icon(Icons.message, size: 18),
                  ),
                  IconButton(
                    onPressed: () => _editUser(vehicle),
                    icon: const Icon(Icons.edit, size: 18),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalytics() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistiques et Analytics',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildAnalyticsCards(),
          const SizedBox(height: 25),
          _buildBatteryChart(),
          const SizedBox(height: 25),
          _buildUsageChart(),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.5,
      children: [
        _buildAnalyticsCard(
          'Batterie Moyenne',
          '${averageBattery.toStringAsFixed(1)}%',
          Icons.battery_3_bar,
          Colors.green,
        ),
        _buildAnalyticsCard(
          'Distance Totale',
          '1,250 km',
          Icons.straighten,
          Colors.blue,
        ),
        _buildAnalyticsCard(
          'Temps Charge',
          '45h 30min',
          Icons.access_time,
          Colors.orange,
        ),
        _buildAnalyticsCard('Économie CO²', '185 kg', Icons.eco, Colors.teal),
      ],
    );
  }

  Widget _buildAnalyticsCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBatteryChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Niveau de batterie de la flotte',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final vehicleIds = [
                          'BAKO001',
                          'BAKO002',
                          'BAKO003',
                          'BAKO004',
                        ];
                        return Text(
                          vehicleIds[value.toInt()],
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}%',
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(
                  vehicles.length,
                  (index) => BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: vehicles[index]['battery'].toDouble(),
                        color: _getBatteryColor(vehicles[index]['battery']),
                        width: 20,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Utilisation hebdomadaire',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final days = [
                          'Lun',
                          'Mar',
                          'Mer',
                          'Jeu',
                          'Ven',
                          'Sam',
                          'Dim',
                        ];
                        return Text(
                          days[value.toInt()],
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}h',
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 3),
                      FlSpot(1, 4),
                      FlSpot(2, 3.5),
                      FlSpot(3, 5),
                      FlSpot(4, 4),
                      FlSpot(5, 3),
                      FlSpot(6, 2),
                    ],
                    isCurved: true,
                    color: const Color(0xFF577F65),
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF577F65).withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceAlerts() {
    final alerts = [
      {
        'title': 'Batterie faible critique',
        'vehicle': 'BAKO003',
        'severity': 'high',
        'time': '2h ago',
        'description': 'Niveau batterie: 15%',
      },
      {
        'title': 'Maintenance préventive',
        'vehicle': 'BAKO001',
        'severity': 'medium',
        'time': '1 jour',
        'description': 'Révision programmée dans 500km',
      },
      {
        'title': 'Mise à jour disponible',
        'vehicle': 'Tous',
        'severity': 'low',
        'time': '3 jours',
        'description': 'Firmware v2.1.3 disponible',
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Maintenance et Alertes',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ...alerts.map((alert) => _buildAlertCard(alert)),
        ],
      ),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    Color severityColor = alert['severity'] == 'high'
        ? Colors.red
        : alert['severity'] == 'medium'
        ? Colors.orange
        : Colors.blue;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border(left: BorderSide(color: severityColor, width: 5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: severityColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              alert['severity'] == 'high'
                  ? Icons.warning
                  : alert['severity'] == 'medium'
                  ? Icons.build
                  : Icons.info,
              color: severityColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Véhicule: ${alert['vehicle']}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                Text(
                  alert['description'],
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                alert['time'],
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _handleAlert(alert),
                style: ElevatedButton.styleFrom(
                  backgroundColor: severityColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                ),
                child: const Text('Traiter', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    final activities = [
      'BAKO001 - Charge terminée (Ahmed Ben Ali)',
      'BAKO004 - Démarrage moteur (Leila Mansouri)',
      'BAKO002 - Stationnement (Fatma Hadj)',
      'BAKO003 - Alerte batterie faible (Mohamed Triki)',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Activité récente',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          ...activities.map(
            (activity) => Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFF577F65),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      activity,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actions rapides',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 2.5,
            children: [
              _buildQuickActionButton(
                'Verrouiller Tous',
                Icons.lock,
                Colors.blue,
                () => _lockAllVehicles(),
              ),
              _buildQuickActionButton(
                'Rapport Flotte',
                Icons.description,
                Colors.green,
                () => _generateFleetReport(),
              ),
              _buildQuickActionButton(
                'Alerte Urgente',
                Icons.notification_important,
                Colors.red,
                () => _sendUrgentAlert(),
              ),
              _buildQuickActionButton(
                'Mise à jour',
                Icons.system_update,
                Colors.orange,
                () => _updateFirmware(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

Widget _buildDrawer() {
  return Drawer(
    child: Column(
      children: [
        const UserAccountsDrawerHeader(
          decoration: BoxDecoration(color: Color(0xFF577F65)),
          currentAccountPicture: CircleAvatar(
            backgroundImage: AssetImage("assets/images/admin_avatar.png"),
          ),
          accountName: Text("Administrateur"),
          accountEmail: Text("admin@smartcars.tn"),
        ),
        ListTile(
          leading: const Icon(Icons.dashboard),
          title: const Text('Vue d\'ensemble'),
          selected: _selectedIndex == 0,
          onTap: () => _navigateTo(0),
        ),
        ListTile(
          leading: const Icon(Icons.car_rental),
          title: const Text('Véhicules'),
          selected: _selectedIndex == 1,
          onTap: () => _navigateTo(1),
        ),
        ListTile(
          leading: const Icon(Icons.people),
          title: const Text('Utilisateurs'),
          selected: _selectedIndex == 2,
          onTap: () => _navigateTo(2),
        ),
        ListTile(
          leading: const Icon(Icons.analytics),
          title: const Text('Analytics'),
          selected: _selectedIndex == 3,
          onTap: () => _navigateTo(3),
        ),
        ListTile(
          leading: const Icon(Icons.build),
          title: const Text('Maintenance'),
          selected: _selectedIndex == 4,
          onTap: () => _navigateTo(4),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Paramètres'),
          onTap: () => Navigator.pop(context),
        ),
        const Spacer(),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Se déconnecter'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ConnexionScreen()),
            );
          },
        ),
      ],
    ),
  );
}
  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Déconnecté avec succès'),
                  backgroundColor: Color(0xFF577F65),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Déconnecter'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.dashboard, 0, 'Accueil'),
          _buildNavItem(Icons.car_rental, 1, 'Véhicules'),
          _buildNavItem(Icons.people, 2, 'Clients'),
          _buildNavItem(Icons.analytics, 3, 'Stats'),
          _buildNavItem(Icons.build, 4, 'Maintenance'),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, String label) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF577F65)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[400],
                size: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? const Color(0xFF577F65) : Colors.grey[400],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'en route':
        return Colors.blue;
      case 'en charge':
        return Colors.orange;
      case 'stationnée':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'en route':
        return Icons.directions_car;
      case 'en charge':
        return Icons.battery_charging_full;
      case 'stationnée':
        return Icons.local_parking;
      default:
        return Icons.help;
    }
  }

  void _navigateTo(int index) {
    setState(() => _selectedIndex = index);
    Navigator.pop(context);
  }

  // Actions des véhicules
  void _handleVehicleAction(String action, Map<String, dynamic> vehicle) {
    switch (action) {
      case 'details':
        _showVehicleDetails(vehicle);
        break;
      case 'remote_control':
        _showRemoteControl(vehicle);
        break;
      case 'maintenance':
        _scheduleMaintenance(vehicle);
        break;
    }
  }

  void _showVehicleDetails(Map<String, dynamic> vehicle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Détails ${vehicle['id']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Modèle: ${vehicle['model']}'),
            Text('Client: ${vehicle['client']}'),
            Text('Batterie: ${vehicle['battery']}%'),
            Text('Autonomie: ${vehicle['range']} km'),
            Text('Status: ${vehicle['status']}'),
            Text('Localisation: ${vehicle['location']}'),
            Text('Dernière mise à jour: ${vehicle['lastUpdate']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showRemoteControl(Map<String, dynamic> vehicle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contrôle à distance - ${vehicle['id']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _showConfirmation('Verrouillage des portes activé');
              },
              icon: const Icon(Icons.lock),
              label: const Text('Verrouiller portes'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _showConfirmation('Moteur coupé à distance');
              },
              icon: const Icon(Icons.power_settings_new),
              label: const Text('Couper moteur'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _showConfirmation('Klaxon activé - Véhicule localisé');
              },
              icon: const Icon(Icons.volume_up),
              label: const Text('Localiser (klaxon)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  void _scheduleMaintenance(Map<String, dynamic> vehicle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Programmer maintenance - ${vehicle['id']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Date de maintenance',
                hintText: 'JJ/MM/AAAA',
              ),
            ),
            const SizedBox(height: 15),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Type de maintenance',
                hintText: 'Révision, Réparation...',
              ),
            ),
            const SizedBox(height: 15),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Notes',
                hintText: 'Détails supplémentaires',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showConfirmation('Maintenance programmée avec succès');
            },
            child: const Text('Programmer'),
          ),
        ],
      ),
    );
  }

  void _showVehicleIssues(Map<String, dynamic> vehicle) {
    final issues = ['Température batterie élevée', 'Pression pneu faible'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Problèmes détectés - ${vehicle['id']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: issues
              .map(
                (issue) => ListTile(
                  leading: const Icon(Icons.warning, color: Colors.red),
                  title: Text(issue),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                ),
              )
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showConfirmation('Technicien notifié');
            },
            child: const Text('Notifier technicien'),
          ),
        ],
      ),
    );
  }

  // Actions utilisateurs
  void _contactUser(String userName) {
    _showConfirmation('Message envoyé à $userName');
  }

  void _editUser(Map<String, dynamic> vehicle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier utilisateur - ${vehicle['client']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Nom'),
              controller: TextEditingController(text: vehicle['client']),
            ),
            const SizedBox(height: 15),
            const TextField(decoration: InputDecoration(labelText: 'Email')),
            const SizedBox(height: 15),
            const TextField(
              decoration: InputDecoration(labelText: 'Téléphone'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showConfirmation('Utilisateur modifié avec succès');
            },
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
    );
  }

  // Actions rapides
  void _lockAllVehicles() {
    _showConfirmation('Tous les véhicules ont été verrouillés');
  }

  void _generateFleetReport() {
    _showConfirmation('Rapport de flotte généré et envoyé par email');
  }

  void _sendUrgentAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Envoyer alerte urgente'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Message d\'alerte',
                hintText: 'Entrez votre message urgent...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showConfirmation(
                'Alerte urgente envoyée à tous les utilisateurs',
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }

  void _updateFirmware() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mise à jour firmware'),
        content: const Text(
          'Voulez-vous mettre à jour le firmware de tous les véhicules vers la version 2.1.3 ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showConfirmation(
                'Mise à jour firmware lancée sur tous les véhicules',
              );
            },
            child: const Text('Mettre à jour'),
          ),
        ],
      ),
    );
  }

  void _handleAlert(Map<String, dynamic> alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Traiter l\'alerte'),
        content: Text(
          'Comment voulez-vous traiter l\'alerte "${alert['title']}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ignorer'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showConfirmation('Alerte traitée et archivée');
            },
            child: const Text('Marquer comme traitée'),
          ),
        ],
      ),
    );
  }

  // Remplacez la méthode _logout() existante par celle-ci :

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => ConnexionScreen()),
                (route) => false,
              );

              // Afficher un message de confirmation
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Déconnecté avec succès'),
                  backgroundColor: Color(0xFF577F65),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
  }

  // Et aussi, corrigez la méthode _showLogoutConfirmation() dans le drawer :

  void _showConfirmation(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              // Fermer le dialogue
              Navigator.pop(context);

              Navigator.pushReplacementNamed(context, '/login');

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Déconnecté avec succès'),
                  backgroundColor: Color(0xFF577F65),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Déconnecter'),
          ),
        ],
      ),
    );
  }
}

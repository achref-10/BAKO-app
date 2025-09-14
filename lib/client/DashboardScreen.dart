import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import './map.dart';
import './notification.dart';
import './account.dart';
import 'package:control_car/connexion_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String? username;
  final String? imageUrl;
  final String? email;

  const DashboardScreen({super.key, this.username, this.imageUrl, this.email});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  bool _isRefreshing = false;

  // Database reference
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // Données simplifiées pour le client
  int batteryPercentage = 65;
  int rangeKm = 180; // Autonomie en km
  bool isCharging = true;
  bool isEngineOn = false;
  bool doorsLocked = true;
  bool ecoMode = true;
  double currentSpeed = 0.0;
  int totalDistance = 15420; // en km
  String carStatus = "Stationnée";

  @override
  void initState() {
    super.initState();

    // Print the Firebase Database URL for debugging
    print("Firebase Database URL: ${FirebaseDatabase.instance.databaseURL}");

    // Initialize with a call to fetch data immediately
    _refreshData();

    // Then set up the listener for real-time updates
    _setupBatteryListener();
  }

  void _setupBatteryListener() {
    print("Setting up battery percentage listener at 'id-1/pourcentage'");

    _dbRef
        .child('id-1/pourcentage')
        .onValue
        .listen(
          (event) {
            print("Battery data received: ${event.snapshot.value}");

            if (event.snapshot.value != null) {
              try {
                final dynamic value = event.snapshot.value;
                final int newPercentage = value is int
                    ? value
                    : int.parse(value.toString());

                setState(() {
                  batteryPercentage = newPercentage;
                  rangeKm = (batteryPercentage * 3).round(); // 100% = ~300km
                });

                print(
                  'Battery percentage updated successfully: $batteryPercentage%',
                );
              } catch (e) {
                print('Error parsing battery percentage: $e');
              }
            } else {
              print('Battery snapshot value is null');
            }
          },
          onError: (error) {
            print('Error listening to battery data: $error');
          },
        );

    // Also try without the child path to check the root structure
    _dbRef.onValue.listen(
      (event) {
        print("Database root structure: ${event.snapshot.value}");
      },
      onError: (error) {
        print('Error reading database root: $error');
      },
    );
  }

  Future<void> _refreshData() async {
    setState(() => _isRefreshing = true);

    try {
      print("Manually refreshing data from Firebase...");

      // Try to get data from 'pourcentage' directly
      try {
        final batterySnapshot = await _dbRef.child('pourcentage').get();
        if (batterySnapshot.exists) {
          final dynamic value = batterySnapshot.value;
          final int newPercentage = value is int
              ? value
              : int.parse(value.toString());

          setState(() {
            batteryPercentage = newPercentage;
            rangeKm = (batteryPercentage * 3).round();
          });
          print('Direct path battery percentage updated: $batteryPercentage%');
        } else {
          print("'pourcentage' path does not exist");
        }
      } catch (e) {
        print("Error reading from 'pourcentage' path: $e");
      }

      // Try with the 'id-1/pourcentage' path
      try {
        final batterySnapshot = await _dbRef.child('id-1/pourcentage').get();
        if (batterySnapshot.exists) {
          final dynamic value = batterySnapshot.value;
          final int newPercentage = value is int
              ? value
              : int.parse(value.toString());

          setState(() {
            batteryPercentage = newPercentage;
            rangeKm = (batteryPercentage * 3).round();
          });
          print(
            'Path with id-1 battery percentage updated: $batteryPercentage%',
          );
        } else {
          print("'id-1/pourcentage' path does not exist");
        }
      } catch (e) {
        print("Error reading from 'id-1/pourcentage' path: $e");
      }

      // Get charging status if available
      try {
        final chargingSnapshot = await _dbRef.child('id-1/enCharge').get();
        if (chargingSnapshot.exists) {
          setState(() {
            isCharging = chargingSnapshot.value as bool;
            carStatus = isCharging ? "En charge" : "Stationnée";
          });
          print('Charging status updated: $isCharging');
        } else {
          print("'id-1/enCharge' path does not exist");
        }
      } catch (e) {
        print("Error reading charging status: $e");
      }

      // Try to read the entire database structure to see what's available
      final rootSnapshot = await _dbRef.get();
      print("Database structure: ${rootSnapshot.value}");
    } catch (e) {
      print('Error refreshing data: $e');
    } finally {
      setState(() => _isRefreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF577F65),
      body: SafeArea(child: _buildCurrentPage()),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardPage();
      case 1:
        return const MapPage();
      case 2:
        return const NotificationPage();
      case 3:
        return const AccountPage();
      default:
        return _buildDashboardPage();
    }
  }

  Widget _buildDashboardPage() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: _isRefreshing
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        'Mise à jour...',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : _buildMainDashboard(),
        ),
      ],
    );
  }

  Widget _buildMainDashboard() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildCarSection(),
            const SizedBox(height: 30),
            _buildQuickStatusCards(),
            const SizedBox(height: 30),
            _buildControlButtons(),
            const SizedBox(height: 20),
            _buildBottomInfoSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: _showUserMenu,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 24),
            ),
          ),
          Column(
            children: [
              Text(
                'Ma Voiture',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                'BAKO Électrique',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: _refreshData,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.refresh, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarSection() {
    return Column(
      children: [
        Container(
          height: 180,
          child: Image.asset(
            'assets/Bee.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Icon(
                    Icons.directions_car,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Text(
          carStatus,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatusCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatusCard(
            'Autonomie',
            '$rangeKm km',
            Icons.route,
            _getRangeColor(),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildStatusCard(
            'Batterie',
            '$batteryPercentage%',
            Icons.battery_full,
            _getBatteryColor(),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildStatusCard(
            'Vitesse',
            '${currentSpeed.toInt()} km/h',
            Icons.speed,
            Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contrôles',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildControlButton(
                  isCharging ? 'Arrêter Charge' : 'Démarrer Charge',
                  isCharging ? Icons.stop : Icons.ev_station,
                  isCharging ? Colors.red : Colors.green,
                  () => _toggleCharging(),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildControlButton(
                  doorsLocked ? 'Déverrouiller' : 'Verrouiller',
                  doorsLocked ? Icons.lock_open : Icons.lock,
                  doorsLocked ? Colors.orange : Colors.blue,
                  () => _toggleDoors(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildControlButton(
                  'Localiser',
                  Icons.my_location,
                  Colors.purple,
                  () => _locateCar(),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildControlButton(
                  ecoMode ? 'Mode Normal' : 'Mode Éco',
                  Icons.eco,
                  ecoMode ? Colors.green : Colors.grey,
                  () => _toggleEcoMode(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Distance Totale',
                  '${_formatDistance(totalDistance)} km',
                  Icons.straighten,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  'État',
                  isCharging ? 'En Charge' : 'Disponible',
                  isCharging ? Icons.battery_charging_full : Icons.check_circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getBatteryColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Icon(_getBatteryIcon(), color: _getBatteryColor(), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'État Batterie',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: batteryPercentage / 100,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getBatteryColor(),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$batteryPercentage% - ${_getBatteryStatus()}',
                        style: TextStyle(
                          fontSize: 12,
                          color: _getBatteryColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: const Color(0xFF577F65)),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 90,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home, 0, 'Accueil'),
          _buildNavItem(Icons.map, 1, 'Carte'),
          _buildNavItem(Icons.notifications, 2, 'Alertes'),
          _buildNavItem(Icons.person, 3, 'Profil'),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, String label) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF577F65)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[400],
                size: 24,
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

  void _showUserMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundImage: widget.imageUrl != null
                    ? NetworkImage(widget.imageUrl!)
                    : const AssetImage("assets/R.png") as ImageProvider,
              ),
              title: Text(widget.username ?? 'Utilisateur'),
              subtitle: Text(widget.email ?? 'email@exemple.com'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Paramètres'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Aide'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Se déconnecter',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ConnexionScreen()),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
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
              Navigator.pop(context);
              // Logique de déconnexion
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Déconnecté avec succès')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Déconnecter'),
          ),
        ],
      ),
    );
  }

  // Méthodes de contrôle
  void _toggleCharging() {
    final bool newChargingStatus = !isCharging;

    print("Toggling charging status to: $newChargingStatus");

    // Update in Firebase
    _dbRef
        .child('id-1/enCharge')
        .set(newChargingStatus)
        .then((_) {
          setState(() {
            isCharging = newChargingStatus;
            carStatus = isCharging ? "En charge" : "Stationnée";
          });

          print("Charging status updated successfully in Firebase");

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isCharging ? 'Charge démarrée' : 'Charge arrêtée'),
              backgroundColor: isCharging ? Colors.green : Colors.orange,
            ),
          );
        })
        .catchError((error) {
          print('Error updating charging status: $error');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Erreur lors de la mise à jour du statut de charge',
              ),
              backgroundColor: Colors.red,
            ),
          );
        });
  }

  void _toggleDoors() {
    setState(() {
      doorsLocked = !doorsLocked;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          doorsLocked ? 'Portes verrouillées' : 'Portes déverrouillées',
        ),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _locateCar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Localisation activée - Votre voiture clignote'),
        backgroundColor: Colors.purple,
      ),
    );
  }

  void _toggleEcoMode() {
    setState(() {
      ecoMode = !ecoMode;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ecoMode ? 'Mode éco activé' : 'Mode normal activé'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Méthodes utilitaires
  Color _getBatteryColor() {
    if (batteryPercentage > 50) return Colors.green;
    if (batteryPercentage > 20) return Colors.orange;
    return Colors.red;
  }

  Color _getRangeColor() {
    if (rangeKm > 100) return Colors.green;
    if (rangeKm > 50) return Colors.orange;
    return Colors.red;
  }

  IconData _getBatteryIcon() {
    if (batteryPercentage > 75) return Icons.battery_full;
    if (batteryPercentage > 50) return Icons.battery_5_bar;
    if (batteryPercentage > 25) return Icons.battery_3_bar;
    return Icons.battery_1_bar;
  }

  String _getBatteryStatus() {
    if (isCharging) return 'En charge';
    if (batteryPercentage > 80) return 'Excellent';
    if (batteryPercentage > 50) return 'Bon';
    if (batteryPercentage > 20) return 'Moyen';
    return 'Critique';
  }

  String _formatDistance(int distance) {
    if (distance >= 1000) {
      return '${(distance / 1000).toStringAsFixed(1)}k';
    }
    return distance.toString();
  }
}

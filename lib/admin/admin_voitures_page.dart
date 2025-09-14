import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Admin Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: Colors.white, // Background en blanc
      ),
      home: AdminVoituresPage(
        status: '',
        cars: [
          Car(
            id: '001',
            type: 'bee',
            status: 'Non vendu',
            chassisNumber: 'ABC123',
            clientName: '',
            clientEmail: '',
            carModel: 'Model S',
            carDetails: 'Électrique, 85 kWh, autonomie 420km',
            reservationDate: DateTime(2025, 4, 18),
          ),
          Car(
            id: '002',
            type: 'bee',
            status: 'Réservé',
            chassisNumber: 'XYZ789',
            clientName: 'Yassmine Ourfelli',
            clientEmail: 'yassmine@example.com',
            carModel: 'Model 3',
            carDetails: 'Électrique, 75 kWh, autonomie 390km',
            reservationDate: DateTime(2025, 4, 20),
          ),
        ],
      ),
    );
  }
}

class Car {
  final String id;
  final String type;
  String status;
  final String chassisNumber;
  String clientName;
  String clientEmail;
  final String carModel;
  final String carDetails;
  DateTime reservationDate;

  Car({
    required this.id,
    required this.type,
    required this.status,
    required this.chassisNumber,
    required this.clientName,
    required this.clientEmail,
    required this.carModel,
    required this.carDetails,
    required this.reservationDate,
  });
}

class AdminVoituresPage extends StatefulWidget {
  final String status;
  final List<Car> cars;

  const AdminVoituresPage({super.key, required this.status, required this.cars});

  @override
  State<AdminVoituresPage> createState() => _AdminVoituresPageState();
}

class _AdminVoituresPageState extends State<AdminVoituresPage> {
  String? selectedType;
  String? selectedStatus;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final Map<String, String> carTypeImages = {
    'bee': 'assets/bee.png',
    'bvan': 'assets/bvan.png',
    'b1': 'assets/b1.png',
  };

  void updateCar(Car updatedCar) {
    setState(() {
      int index = widget.cars.indexWhere((car) => car.id == updatedCar.id);
      if (index != -1) {
        widget.cars[index] = updatedCar;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Car> filteredCars = widget.cars;
    if (selectedType != null) {
      filteredCars = filteredCars.where((car) => car.type == selectedType).toList();
    }
    if (selectedStatus != null) {
      filteredCars = filteredCars.where((car) => car.status == selectedStatus).toList();
    }
    if (selectedStatus == 'Réservé' && _selectedDay != null) {
      filteredCars = filteredCars.where((car) =>
      car.reservationDate.year == _selectedDay!.year &&
          car.reservationDate.month == _selectedDay!.month &&
          car.reservationDate.day == _selectedDay!.day).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin - Voitures"),
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (selectedType == null) ...[
              const Text('Choisissez un type de voiture',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
              const SizedBox(height: 20),
              Column(
                children: carTypeImages.entries.map((entry) {
                  return Center(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedType = entry.key;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Center(child: Image.asset(entry.value, height: 150)),
                            const SizedBox(height: 10),
                            Text(entry.key.toUpperCase(),
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ] else if (selectedStatus == null) ...[
              const SizedBox(height: 20),
              Text('Type sélectionné : $selectedType',
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
              const SizedBox(height: 50),
              Column(
                children: ['Vendu', 'Non vendu', 'Réservé'].map((status) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          backgroundColor: Colors.blueGrey                     ),
                        onPressed: () {
                          setState(() {
                            selectedStatus = status;
                          });
                        },
                        child: Text(status, style: const TextStyle(fontSize: 20)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ] else ...[
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      setState(() {
                        selectedStatus = null;
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Type: $selectedType | Statut: $selectedStatus',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (selectedStatus == 'Réservé') ...[
                TableCalendar(
                  firstDay: DateTime.now().subtract(const Duration(days: 365)),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                ),
                const SizedBox(height: 20),
              ],
              ...filteredCars.map((car) => Card(
                color: Colors.white,
                child: ListTile(
                  leading: Image.asset('assets/${car.type}.png', width: 50),
                  title: Text(car.carModel),
                  subtitle: Text('Châssis: ${car.chassisNumber}'),
                  trailing: Text(car.status),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CarDetailsPage(
                          car: car,
                          onUpdate: updateCar,
                        ),
                      ),
                    );
                  },
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }
}

class CarDetailsPage extends StatelessWidget {
  final Car car;
  final Function(Car) onUpdate;

  const CarDetailsPage({super.key, required this.car, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails - ${car.carModel}'),
        backgroundColor: Colors.blueGrey,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/${car.type}.png',
                height: 150,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),
              Text('Modèle: ${car.carModel}', style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 10),
              Text('Numéro de châssis: ${car.chassisNumber}'),
              const SizedBox(height: 10),
              Text('Statut: ${car.status}'),
              const SizedBox(height: 20),
              const Text('Informations client:', style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                initialValue: car.clientName,
                decoration: const InputDecoration(labelText: 'Nom client'),
                onChanged: (value) => car.clientName = value,
              ),
              TextFormField(
                initialValue: car.clientEmail,
                decoration: const InputDecoration(labelText: 'Email client'),
                onChanged: (value) => car.clientEmail = value,
              ),
              const SizedBox(height: 20),
              const Text('Détails du véhicule:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(car.carDetails),
              if (car.status == 'Réservé') ...[
                const SizedBox(height: 20),
                Text('Date de réservation: ${DateFormat('dd/MM/yyyy').format(car.reservationDate)}'),
              ],
              const SizedBox(height: 30),
              if (car.status == 'Non vendu')
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      car.status = 'Réservé';
                      car.reservationDate = DateTime.now();
                      onUpdate(car);
                      Navigator.pop(context);
                    },
                    child: const Text('Réserver cette voiture'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

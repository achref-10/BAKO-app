import 'package:flutter/material.dart';
import 'admin_voitures_page.dart';

class VehicleListPage extends StatefulWidget {
  final String status;
  final String vehicleType;

  const VehicleListPage({super.key, required this.status, required this.vehicleType});

  @override
  State<VehicleListPage> createState() => _VehicleListPageState();
}

class _VehicleListPageState extends State<VehicleListPage> {
  List<Car> allCars = [];
  List<Car> filteredCars = [];
  String searchQuery = "";
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    allCars = [
      Car(
        id: '001',
        type: widget.vehicleType,
        status: widget.status,
        chassisNumber: 'ABC123',
        clientName: widget.status != 'Non Vendu' ? 'Cyrine Najjar' : '',
        clientEmail: widget.status != 'Non Vendu' ? 'cyrine@example.com' : '',
        carModel: 'Model S',
        carDetails: 'Électrique, 85 kWh, autonomie 420km',
        reservationDate: DateTime(2025, 4, 18),
      ),
      Car(
        id: '002',
        type: widget.vehicleType,
        status: widget.status,
        chassisNumber: 'XYZ789',
        clientName: widget.status != 'Non Vendu' ? 'Yassmine Ourfelli' : '',
        clientEmail: widget.status != 'Non Vendu' ? 'yassmine@example.com' : '',
        carModel: 'Model 3',
        carDetails: 'Électrique, 75 kWh, autonomie 390km',
        reservationDate: DateTime(2025, 4, 12),
      ),
    ];
    filteredCars = allCars;
  }

  void filterCars() {
    setState(() {
      filteredCars = allCars.where((car) {
        final matchesText = searchQuery.isEmpty ||
            car.chassisNumber.contains(searchQuery) ||
            car.id.contains(searchQuery) ||
            car.clientName.toLowerCase().contains(searchQuery.toLowerCase());

        final matchesDate = selectedDate == null ||
            (car.reservationDate.year == selectedDate!.year &&
                car.reservationDate.month == selectedDate!.month &&
                car.reservationDate.day == selectedDate!.day);

        return matchesText && matchesDate;
      }).toList();
    });
  }

  void openCarDetails(Car car) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Détails Voiture ID: ${car.id}"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Type: ${car.type}"),
              Text("Statut: ${car.status}"),
              Text("Châssis: ${car.chassisNumber}"),
              Text("Modèle: ${car.carModel}"),
              Text("Détails: ${car.carDetails}"),
              if (car.status != 'Non Vendu') ...[
                const Divider(),
                Text("Client: ${car.clientName}"),
                Text("Email: ${car.clientEmail}"),
              ],
              Text("Date: ${car.reservationDate.toLocal()}".split(' ')[0]),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fermer"),
          ),
        ],
      ),
    );
  }

  void clearFilters() {
    setState(() {
      searchQuery = "";
      selectedDate = null;
      filteredCars = allCars;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.status} - ${widget.vehicleType}"),
        backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: clearFilters,
            tooltip: "Réinitialiser les filtres",
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: "Rechercher (Nom, ID, Châssis)...",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      searchQuery = value;
                      filterCars();
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_month),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) {
                      selectedDate = date;
                      filterCars();
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredCars.isEmpty
                ? const Center(child: Text("Aucune voiture trouvée."))
                : ListView.builder(
              itemCount: filteredCars.length,
              itemBuilder: (context, index) {
                final car = filteredCars[index];
                return Card(
                  child: ListTile(
                    title: Text("ID: ${car.id} - ${car.carModel}"),
                    subtitle: Text("Châssis: ${car.chassisNumber}"),
                    onTap: () => openCarDetails(car),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

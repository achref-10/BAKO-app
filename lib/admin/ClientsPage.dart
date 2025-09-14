import 'package:flutter/material.dart';


class ClientsPage extends StatelessWidget {
  const ClientsPage({super.key});

  final List<Map<String, String>> clients = const [
    {
      "nom": "Ali Ben Salah",
      "email": "ali@exemple.com",
      "telephone": "12345678",
    },
    {
      "nom": "Cyrine Najjar",
      "email": "cyrine@exemple.com",
      "telephone": "98765432",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: clients.length,
      itemBuilder: (context, index) {
        final client = clients[index];
        return Card(
          margin: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            title: Text(client["nom"] ?? ""),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Email: ${client["email"]}"),
                Text("Téléphone: ${client["telephone"]}"),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    print("Modifier ${client["nom"]}");
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    print("Supprimer ${client["nom"]}");
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

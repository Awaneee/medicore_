import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MedicationScreen extends StatefulWidget {
  final String patientId;
  const MedicationScreen({super.key, required this.patientId});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final medsStream = firestore
        .collection('patients')
        .doc(widget.patientId)
        .collection('medications')
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medications'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: medsStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final medsDocs = snapshot.data!.docs;

          if (medsDocs.isEmpty) {
            return const Center(child: Text("No medicines."));
          }

          return ListView.builder(
            itemCount: medsDocs.length,
            itemBuilder: (context, index) {
              final medDoc = medsDocs[index];
              final medData = medDoc.data()! as Map<String, dynamic>;

              final taken = medData['taken'] == true;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(medData['name'] ?? 'Unnamed Medicine'),
                  trailing: Switch(
                    value: taken,
                    onChanged: (bool newValue) async {
                      await medDoc.reference.update({'taken': newValue});
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMedicineDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addMedicineDialog() {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Medicine"),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: "Medicine Name",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  await firestore
                      .collection('patients')
                      .doc(widget.patientId)
                      .collection('medications')
                      .add({
                    "name": nameController.text,
                    "taken": false,
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }
}

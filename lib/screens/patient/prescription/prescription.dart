import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PrescriptionScreen extends StatelessWidget {
  final String pid;
  const PrescriptionScreen({super.key, required this.pid});

  @override
  Widget build(BuildContext context) {
    final prescriptionsStream = FirebaseFirestore.instance
        .collection('patients')
        .doc(pid)
        .collection('prescriptions')
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Prescriptions"),
        backgroundColor: const Color.fromARGB(255, 62, 123, 185),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: prescriptionsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No prescriptions found."));
          }

          final prescriptions = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: prescriptions.length,
            itemBuilder: (context, i) {
              final prescData = prescriptions[i].data()! as Map<String, dynamic>;
              final points =
                  (prescData['prescriptionPoints'] as List<dynamic>?)
                          ?.cast<String>() ??
                      [];

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade100.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: points.isEmpty
                      ? [const Text("No details available.")]
                      : points
                          .map(
                            (point) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("• ",
                                      style: TextStyle(fontSize: 20)),
                                  Expanded(
                                    child: Text(point,
                                        style: const TextStyle(fontSize: 16)),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

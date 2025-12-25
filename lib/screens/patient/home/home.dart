import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hackto/screens/chatbot_screen.dart';
import 'package:hackto/screens/patient/chatbot/chatbot.dart';
import 'package:hackto/screens/patient/medication/medication.dart';
import 'package:hackto/screens/patient/prescription/prescription.dart';
import '../appointment/appointment.dart';

class PatientHomeScreen extends StatefulWidget {
  final String patientId;
  final String doctorId;

  const PatientHomeScreen({
    super.key,
    required this.patientId,
    required this.doctorId,
  });

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  int _currentIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardScreen(
        patientId: widget.patientId,
        navigateTo: _navigateToScreen,
      ),
       BookAppointmentPage(patientId: widget.patientId,doctorId: widget.doctorId,), // Index 1
      MedicationScreen(patientId: widget.patientId), // Index 2
      const ChatbotScreen(), // Index 3
      PrescriptionScreen(pid: widget.patientId), // Index 4
    ];
  }

  void _navigateToScreen(int index) {
    // Add bounds checking
    if (index >= 0 && index < _screens.length) {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color.fromARGB(255, 167, 201, 219),
        selectedItemColor: const Color.fromARGB(255, 6, 6, 6),
        unselectedItemColor: const Color.fromARGB(179, 0, 0, 0),
        onTap: _navigateToScreen,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Appointments'),
          // ✅ Removed Treatment item
          BottomNavigationBarItem(
              icon: Icon(Icons.medication), label: 'Medication'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chatbot'),
          BottomNavigationBarItem(
              icon: Icon(Icons.file_copy), label: 'Prescription'),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  final String patientId;
  final Function(int) navigateTo;
  const DashboardScreen(
      {super.key, required this.patientId, required this.navigateTo});

  Widget _quickAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 28, color: Colors.blue.shade700),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              if (subtitle.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _welcomeBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 22, top: 10),
      child: Row(
        children: const [
          Icon(Icons.waving_hand, color: Colors.blue, size: 28),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              "Welcome back!\nHow can we help you today?",
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                  fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _medicationsToTake() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('patients')
          .doc(patientId)
          .collection('medications')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final meds = snapshot.data!.docs;
        if (meds.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "No medications scheduled.",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          );
        }
        final showMeds = meds.take(3).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...showMeds.map((doc) {
              final med = doc.data() as Map<String, dynamic>;
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 13),
                decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Icon(Icons.medication,
                        color: Colors.blue.shade700, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(med['name'] ?? 'Medication',
                            style:
                                const TextStyle(fontWeight: FontWeight.w600))),
                  ],
                ),
              );
            }),
            if (meds.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  "+ ${meds.length - 3} more...",
                  style: TextStyle(color: Colors.blue.shade400, fontSize: 13),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          Row(
            children: const [
              Expanded(
                child: Text("Patient Dashboard",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
              ),
            ],
          ),
          _welcomeBanner(),

          // Quick Actions grid (2x2)
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Quick Actions",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _quickAction(
                      icon: Icons.calendar_today,
                      title: "Book Appointment",
                      subtitle: "Schedule with doctors",
                      onTap: () => navigateTo(1), // ✅ Appointments - Index 1
                    ),
                    _quickAction(
                      icon: Icons.description,
                      title: "Prescriptions",
                      subtitle: "View your medications",
                      onTap: () => navigateTo(4), // ✅ Prescription - Index 4
                    ),
                  ],
                ),
                Row(
                  children: [
                    _quickAction(
                      icon: Icons.chat,
                      title: "Chatbot",
                      subtitle: "Ask health questions",
                      onTap: () => navigateTo(3), // ✅ Chatbot - Index 3
                    ),
                    _quickAction(
                      icon: Icons.medication,
                      title: "Medications",
                      subtitle: "Your medicine list",
                      onTap: () => navigateTo(2), // ✅ Medication - Index 2
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          const Text("Medications To Take",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          const SizedBox(height: 8),
          _medicationsToTake(),
        ],
      ),
    );
  }
}

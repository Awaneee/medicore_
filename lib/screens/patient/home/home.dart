import 'package:flutter/material.dart';
import 'package:hackto/screens/patient/chatbot/chatbot.dart';
import 'package:hackto/screens/patient/medication/medication.dart';
import 'package:hackto/screens/patient/prescription/prescription.dart';
import 'package:hackto/screens/patient/treatment/treatment.dart';
import '../appointment/appointment.dart';

class PatientHomeScreen extends StatefulWidget {
  final String patientId;
  final String doctorId;

  const PatientHomeScreen(
      {super.key, required this.patientId, required this.doctorId});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      DashboardScreen(navigateTo: _navigateToScreen),
      const AppointmentScreen(),
      const TreatmentPlanScreen(),
      MedicationScreen(patientId: widget.patientId),
      const ChatbotScreen(),
      PrescriptionScreen(pid: widget.patientId),
    ]);
  }

  void _navigateToScreen(int index) {
    setState(() => _currentIndex = index);
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
        backgroundColor: Colors.black,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.white70,
        onTap: _navigateToScreen,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Appointments'),
          BottomNavigationBarItem(
              icon: Icon(Icons.healing), label: 'Treatment'),
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
  final Function(int) navigateTo;
  const DashboardScreen({super.key, required this.navigateTo});

  Widget _buildTimelineTile(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(text, style: const TextStyle(fontSize: 16)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Treatment Timeline",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildTimelineTile("Initial Assessment - Jan 15, 2024"),
          _buildTimelineTile("Physical Therapy - Feb 1 to Mar 15"),
          _buildTimelineTile("Medication Review - Mar 22, 2024"),
          _buildTimelineTile("Follow-up Consultation - Apr 5, 2024"),
          const Divider(height: 32),
          const Text("Upcoming Appointments",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            elevation: 4,
            shadowColor: Colors.black12,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: const [
                ListTile(title: Text("Dr. Emily White - Aug 23, 2025")),
                Divider(height: 1),
                ListTile(title: Text("Dr. John Miller - Aug 25, 2025")),
              ],
            ),
          ),
          const Divider(height: 32),
          const Text("Quick Actions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton(
                onPressed: () => navigateTo(1),
                child: const Text("Appointments"),
              ),
              OutlinedButton(
                onPressed: () => navigateTo(5),
                child: const Text("Prescriptions"),
              ),
              OutlinedButton(
                onPressed: () => navigateTo(4),
                child: const Text("Chatbot"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

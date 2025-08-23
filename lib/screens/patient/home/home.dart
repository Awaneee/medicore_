import 'package:flutter/material.dart';
import 'package:hackto/data/repo.dart';
import 'package:hackto/main.dart';
import '../../chatbot_screen.dart';

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
      MedicationTrackerScreen(pid: widget.patientId),
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

// ---------- TREATMENT ----------
class TreatmentPlanScreen extends StatelessWidget {
  const TreatmentPlanScreen({super.key});

  Widget _buildPlanItem(String text, {bool completed = false}) {
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
      child: Row(
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.hourglass_bottom,
            color: completed ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Your Progress: 60%",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildPlanItem("Physiotherapy Sessions", completed: true),
          _buildPlanItem("Medication Adherence", completed: true),
          _buildPlanItem("Follow-up Appointment", completed: false),
          const Divider(height: 32),
          const Text("Supplementary Guide"),
          const SizedBox(height: 10),
          Container(
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
            child: const Text("🏠 Physiotherapy Exercises for Home",
                style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}


// ---------- PRESCRIPTIONS ----------
class PrescriptionScreen extends StatelessWidget {
  final String pid;
  const PrescriptionScreen({super.key, required this.pid});

  @override
  Widget build(BuildContext context) {
    final patient = repo.getPatient(pid);
    if (patient == null) {
      return const Center(child: Text("No patient found"));
    }
    final prescriptions = patient.prescriptions;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: prescriptions.length,
      itemBuilder: (context, i) {
        final presc = prescriptions[i];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ExpansionTile(
            title: Text("Prescription ${i + 1}"),
            children: [
              ListTile(
                title: Text(presc.name),
                subtitle: Text("${presc.dose} • ${presc.frequency}"),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------- APPOINTMENTS ----------
class AppointmentScreen extends StatelessWidget {
  const AppointmentScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text("Appointment Screen Placeholder"));
}

// ---------- MEDICATION TRACKER ----------
class MedicationTrackerScreen extends StatefulWidget {
  final String pid;
  const MedicationTrackerScreen({super.key, required this.pid});

  @override
  State<MedicationTrackerScreen> createState() =>
      _MedicationTrackerScreenState();
}

class _MedicationTrackerScreenState extends State<MedicationTrackerScreen> {
  final Map<String, bool> medStatus = {};

  @override
  void initState() {
    super.initState();
    final patient = repo.getPatient(widget.pid);
    if (patient != null) {
      for (var presc in patient.prescriptions) {
        medStatus[presc.name] = false; // ✅ Track per prescription
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (medStatus.isEmpty) {
      return const Center(child: Text("No medications found"));
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: medStatus.keys.map((med) {
        return Card(
          child: ListTile(
            title: Text(med),
            subtitle: const Text("Tap toggle to mark as taken"),
            trailing: Switch(
              value: medStatus[med]!,
              onChanged: (val) {
                setState(() => medStatus[med] = val);
              },
            ),
          ),
        );
      }).toList(),
    );
  }
}


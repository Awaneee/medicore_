import 'package:flutter/material.dart';
import '../../data/repo.dart';
import '../../widgets/common.dart';
import '../chatbot_screen.dart';

class CaregiverHomeScreen extends StatefulWidget {
  final String caregiverId;
  const CaregiverHomeScreen({super.key, required this.caregiverId});
  @override
  State<CaregiverHomeScreen> createState() => _CaregiverHomeScreenState();
}

class _CaregiverHomeScreenState extends State<CaregiverHomeScreen> {
  int _currentIndex = 0;
  final idCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final docCtrl = TextEditingController();
  final prescPidCtrl = TextEditingController();

  @override
  void dispose() {
    idCtrl.dispose();
    nameCtrl.dispose();
    docCtrl.dispose();
    prescPidCtrl.dispose();
    super.dispose();
  }

  void _addPatient() {
    final id = idCtrl.text.trim();
    final name = nameCtrl.text.trim();
    final doc = docCtrl.text.trim();

    if (id.isEmpty || name.isEmpty || doc.isEmpty) {
      _showMessage('Please fill all fields');
      return;
    }

    if (repo.getPatient(id) != null) {
      _showMessage('Patient ID already exists');
      return;
    }

    // ✅ Make sure the DID exists (create if missing)
    if (repo.getDoctor(doc) == null) {
      repo.addDoctor(Doctor(id: doc, name: 'Doctor $doc'));
    }

    // ✅ Save the PID→DID link in repo
    repo.addPatient(Patient(id: id, name: name, doctorId: doc));

    idCtrl.clear();
    nameCtrl.clear();
    docCtrl.clear();

    _showMessage(
        'Patient added successfully. They can now login with PID & DID.');
    setState(() {});
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Widget _buildManagementScreen() {
    final patients = repo.allPatients.toList();

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        sectionTitle('Add Patient'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                TextField(
                    controller: idCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Patient ID (PID)')),
                TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Name')),
                TextField(
                    controller: docCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Doctor ID (DID)')),
                const SizedBox(height: 8),
                ElevatedButton(
                    onPressed: _addPatient, child: const Text('Add Patient')),
              ],
            ),
          ),
        ),
        sectionTitle('Add Prescription'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                TextField(
                  controller: prescPidCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Enter Patient ID for Prescription',
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    final pid = prescPidCtrl.text.trim();
                    if (pid.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please enter a Patient ID')),
                      );
                      return;
                    }
                    final patient = repo.getPatient(pid);
                    if (patient == null) {
                      _showMessage('Patient ID not found');
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PrescriptionEntryScreen(pid: pid),
                      ),
                    ).then((_) {
                      setState(() {});
                      prescPidCtrl.clear();
                    });
                  },
                  child: const Text('Add Prescription'),
                ),
              ],
            ),
          ),
        ),
        sectionTitle('Patients'),
        ...patients.map((p) => Card(
              child: ListTile(
                title: Text('${p.name} (${p.id})'),
                subtitle: Text(
                    'Doctor: ${p.doctorId} • Rx: ${p.prescriptions.length}'),
              ),
            ))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildManagementScreen(),
      const ChatbotScreen(),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Caregiver Portal')),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Management',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chatbot',
          ),
        ],
      ),
    );
  }
}

class PrescriptionEntryScreen extends StatefulWidget {
  final String pid;
  const PrescriptionEntryScreen({super.key, required this.pid});

  @override
  State<PrescriptionEntryScreen> createState() =>
      _PrescriptionEntryScreenState();
}

class _PrescriptionEntryScreenState extends State<PrescriptionEntryScreen> {
  final nameCtrl = TextEditingController();
  final doseCtrl = TextEditingController();
  final freqCtrl = TextEditingController();

  @override
  void dispose() {
    nameCtrl.dispose();
    doseCtrl.dispose();
    freqCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = nameCtrl.text.trim();
    final dose = doseCtrl.text.trim();
    final freq = freqCtrl.text.trim();

    if (name.isEmpty || dose.isEmpty || freq.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    repo.addPrescription(
      widget.pid,
      Prescription(
          name: name, dose: dose, frequency: freq, reminders: const []),
    );

    Navigator.pop(context); // Go back to CaregiverHome
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Prescription')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Medicine Name')),
            const SizedBox(height: 10),
            TextField(
                controller: doseCtrl,
                decoration: const InputDecoration(labelText: 'Dose')),
            const SizedBox(height: 10),
            TextField(
                controller: freqCtrl,
                decoration: const InputDecoration(labelText: 'Frequency')),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: _submit, child: const Text('Save Prescription')),
          ],
        ),
      ),
    );
  }
}

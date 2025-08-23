import 'package:flutter/material.dart';
import '../../data/repo.dart';
import '../../widgets/common.dart';
import '../chatbot_screen.dart';

class DoctorHomeScreen extends StatefulWidget {
  final String doctorId;
  const DoctorHomeScreen({super.key, required this.doctorId});
  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  int _index = 0;
  @override
  Widget build(BuildContext context) {
    final tabs = [
      _appointments(),
      _availability(),
      const ChatbotScreen(),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Doctor Portal')),
      body: tabs[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.people), label: 'Appts'),
          NavigationDestination(
              icon: Icon(Icons.settings), label: 'Availability'),
          NavigationDestination(icon: Icon(Icons.chat), label: 'Chatbot'),
        ],
      ),
    );
  }

  Widget _appointments() {
    final d = repo.getDoctor(widget.doctorId)!;
    final appts = d.booked;
    return ListView(padding: const EdgeInsets.all(12), children: [
      sectionTitle('Booked Patients'),
      if (appts.isEmpty)
        const Card(child: ListTile(title: Text('No appointments'))),
      ...appts.map((a) => Card(
          child: ListTile(
              title: Text('${dateStr(a.slot)} ${timeStr(a.slot)}'),
              subtitle: Text(
                  'Patient: ${repo.getPatient(a.patientId)?.name ?? a.patientId}'))))
    ]);
  }

  Widget _availability() {
    final slots = repo.generateSlots(days: 7);
    return ListView(padding: const EdgeInsets.all(12), children: [
      sectionTitle('Toggle Unavailable (will hide slots from patients)'),
      ...slots.map((s) => Card(
          child: SwitchListTile(
              title: Text('${dateStr(s)} ${timeStr(s)}'),
              value: repo.isUnavailable(widget.doctorId, s),
              onChanged: (v) {
                if (repo.isBooked(widget.doctorId, s)) return;
                repo.toggleUnavailable(widget.doctorId, s);
                setState(() {});
              })))
    ]);
  }
}

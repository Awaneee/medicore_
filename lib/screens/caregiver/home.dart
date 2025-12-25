import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CaregiverHomeScreen extends StatefulWidget {
  final String caregiverId;
  const CaregiverHomeScreen({super.key, required this.caregiverId});

  @override
  State<CaregiverHomeScreen> createState() => _CaregiverHomeScreenState();
}

class _CaregiverHomeScreenState extends State<CaregiverHomeScreen> {
  final int _currentIndex = 0;
  final idCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final docCtrl = TextEditingController();
  final medPidCtrl = TextEditingController();
  final uploadPidCtrl = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<bool> _patientExists(String id) async {
    final doc = await _firestore.collection('patients').doc(id).get();
    return doc.exists;
  }

  Future<bool> _doctorExists(String id) async {
    final doc = await _firestore.collection('doctors').doc(id).get();
    return doc.exists;
  }

  Future<void> _addDoctor(String id) async {
    await _firestore.collection('doctors').doc(id).set({'name': 'Doctor $id'});
  }

  Future<void> _addPatient(String id, String name, String doctorId) async {
    await _firestore.collection('patients').doc(id).set({
      'name': name,
      'doctorId': doctorId,
    });
  }

  Future<void> handleAddPatient() async {
    final id = idCtrl.text.trim();
    final name = nameCtrl.text.trim();
    final doc = docCtrl.text.trim();

    if (id.isEmpty || name.isEmpty || doc.isEmpty) {
      _showMessage('Please fill all fields');
      return;
    }

    if (await _patientExists(id)) {
      _showMessage('Patient ID already exists');
      return;
    }

    if (!await _doctorExists(doc)) {
      await _addDoctor(doc);
    }

    await _addPatient(id, name, doc);

    idCtrl.clear();
    nameCtrl.clear();
    docCtrl.clear();

    _showMessage(
        'Patient added successfully. They can now login with PID & DID.');
    setState(() {});
  }

  Future<void> _uploadPrescriptionText(BuildContext context) async {
    final pid = uploadPidCtrl.text.trim();
    if (pid.isEmpty) {
      _showMessage('Please enter Patient ID');
      return;
    }
    if (!await _patientExists(pid)) {
      _showMessage('Patient not found');
      return;
    }

    String prescriptionText = '';
    await showDialog(
      context: context,
      builder: (ctx) {
        final textController = TextEditingController();
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Enter Prescription (bullet points separated by new lines)',
            style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 18),
          ),
          content: TextField(
            controller: textController,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: 'Enter prescription bullet points',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color.fromARGB(255, 231, 231, 231)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                prescriptionText = textController.text.trim();
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            )
          ],
        );
      },
    );

    if (prescriptionText.isNotEmpty) {
      List<String> bulletPoints = prescriptionText
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      await _firestore
          .collection('patients')
          .doc(pid)
          .collection('prescriptions')
          .add({
        'createdAt': Timestamp.now(),
        'prescriptionPoints': bulletPoints,
      });
      _showMessage('Prescription uploaded successfully');
      uploadPidCtrl.clear();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF4285F4); // Google blue
    final bgColor = Colors.grey.shade50;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text("Caregiver Portal",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            _section(
              icon: Icons.person_add_alt_1,
              title: "Add Patient",
              description: "Register a new patient with their Doctor ID",
              color: primaryColor,
              children: [
                _input(idCtrl, "Patient ID"),
                _input(nameCtrl, "Patient Name"),
                _input(docCtrl, "Doctor ID"),
                const SizedBox(height: 14),
                _filledButton(
                    "Add Patient", Icons.person_add, handleAddPatient),
              ],
            ),
            const SizedBox(height: 24),
            _section(
              icon: Icons.medical_services_outlined,
              title: "Add Medication",
              description: "Attach medicines for a patient by their ID",
              color: Colors.teal,
              children: [
                _input(medPidCtrl, "Patient ID"),
                const SizedBox(height: 14),
                _filledButton("Add Medication", Icons.medication, () async {
                  final pid = medPidCtrl.text.trim();
                  if (pid.isEmpty) {
                    _showMessage('Please enter a Patient ID');
                    return;
                  }
                  final exists = await _patientExists(pid);
                  if (!exists) {
                    _showMessage('Patient ID not found');
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => MedicationEntryScreen(pid: pid)),
                  ).then((_) {
                    medPidCtrl.clear();
                    setState(() {});
                  });
                }),
              ],
            ),
            const SizedBox(height: 24),
            _section(
              icon: Icons.upload_file,
              title: "Upload Prescription",
              description: "Upload prescription text for a patient",
              color: Colors.deepPurple,
              children: [
                _input(uploadPidCtrl, "Patient ID"),
                const SizedBox(height: 14),
                _filledButton("Upload", Icons.upload,
                    () => _uploadPrescriptionText(context)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _section({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 8, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            CircleAvatar(
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, color: color)),
            const SizedBox(width: 12),
            Expanded(
                child: Text(title,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color))),
          ]),
          const SizedBox(height: 6),
          Text(description,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _input(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade500),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
      ),
    );
  }

  Widget _filledButton(String text, IconData icon, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 2),
          icon: Icon(icon),
          onPressed: onTap,
          label: Text(text, style: const TextStyle(fontSize: 16))),
    );
  }
}

class MedicationEntryScreen extends StatefulWidget {
  final String pid;
  const MedicationEntryScreen({super.key, required this.pid});

  @override
  State<MedicationEntryScreen> createState() => _MedicationEntryScreenState();
}

class _MedicationEntryScreenState extends State<MedicationEntryScreen> {
  final nameCtrl = TextEditingController();
  final doseCtrl = TextEditingController();
  final freqCtrl = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    nameCtrl.dispose();
    doseCtrl.dispose();
    freqCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = nameCtrl.text.trim();
    final dose = doseCtrl.text.trim();
    final freq = freqCtrl.text.trim();

    if (name.isEmpty || dose.isEmpty || freq.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    await _firestore
        .collection('patients')
        .doc(widget.pid)
        .collection('medications')
        .add({
      'name': name,
      'dose': dose,
      'frequency': freq,
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Medication'),
        backgroundColor: Colors.blue.shade700,
      ),
      backgroundColor: Colors.white,
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
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700),
                onPressed: _submit,
                child: const Text('Save Medication')),
          ],
        ),
      ),
    );
  }
}

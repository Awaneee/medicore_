import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../coolors.dart'; // <- assuming your customColorScheme is here

class MedicationScreen extends StatefulWidget {
  final String patientId;
  const MedicationScreen({super.key, required this.patientId});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  DateTime selectedDate = DateTime.now();
  final List<Map<String, dynamic>> medicines = [];

  void _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
    }
  }

  void _addMedicineDialog() {
    final TextEditingController nameController = TextEditingController();
    String frequency = "Once";
    final List<String> times = [];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: customColorScheme.surface,
          title: const Text("Add Medicine"),
          content: StatefulBuilder(
            builder: (context, setInnerState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Medicine Name",
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: frequency,
                      decoration: const InputDecoration(
                        labelText: "Frequency",
                      ),
                      items: ["Once", "Weekly", "Permanent"]
                          .map(
                              (f) => DropdownMenuItem(value: f, child: Text(f)))
                          .toList(),
                      onChanged: (val) {
                        setInnerState(() => frequency = val ?? "Once");
                      },
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: ["Morning", "Afternoon", "Evening", "Night"]
                          .map((time) {
                        final selected = times.contains(time);
                        return ChoiceChip(
                          label: Text(time),
                          selected: selected,
                          onSelected: (val) {
                            setInnerState(() {
                              if (val) {
                                times.add(time);
                              } else {
                                times.remove(time);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: customColorScheme.primary,
                foregroundColor: customColorScheme.onPrimary,
              ),
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  setState(() {
                    medicines.add({
                      "name": nameController.text,
                      "frequency": frequency,
                      "times": List<String>.from(times),
                      "date": selectedDate,
                    });
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

  @override
  Widget build(BuildContext context) {
    final weekDates =
        List.generate(7, (i) => DateTime.now().subtract(Duration(days: i)));

    final todaysMeds = medicines.where((m) {
      if (m["frequency"] == "Once") {
        return DateFormat('yyyy-MM-dd').format(m["date"]) ==
            DateFormat('yyyy-MM-dd').format(selectedDate);
      } else if (m["frequency"] == "Weekly") {
        return m["date"].weekday == selectedDate.weekday;
      } else {
        return true; // permanent → always
      }
    }).toList();

    return Scaffold(
      backgroundColor: customColorScheme.surface,
      appBar: AppBar(
        backgroundColor: customColorScheme.primary,
        title: Text(
          "Medications",
          style: TextStyle(color: customColorScheme.onPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _pickDate,
          ),
        ],
      ),
      body: Column(
        children: [
          // Selected date
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: GestureDetector(
              onTap: _pickDate,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.date_range, color: customColorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat.yMMMMd().format(selectedDate),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Last 7 days quick row
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: weekDates.length,
              itemBuilder: (context, index) {
                final date = weekDates[index];
                final isSelected = date.day == selectedDate.day &&
                    date.month == selectedDate.month &&
                    date.year == selectedDate.year;
                return GestureDetector(
                  onTap: () => setState(() => selectedDate = date),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? customColorScheme.primary
                          : customColorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(DateFormat.E().format(date),
                            style: TextStyle(
                                color: isSelected
                                    ? customColorScheme.onPrimary
                                    : customColorScheme.onSurface)),
                        const SizedBox(height: 4),
                        Text("${date.day}",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? customColorScheme.onPrimary
                                    : customColorScheme.onSurface)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Medicine list
          Expanded(
            child: todaysMeds.isEmpty
                ? const Center(child: Text("No medicines scheduled."))
                : ListView.builder(
                    itemCount: todaysMeds.length,
                    itemBuilder: (context, index) {
                      final med = todaysMeds[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: Icon(Icons.medication,
                              color: customColorScheme.secondary),
                          title: Text(med["name"]),
                          subtitle: Text(
                              "${med["frequency"]} • ${med["times"].join(", ")}"),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: customColorScheme.secondary,
        onPressed: _addMedicineDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

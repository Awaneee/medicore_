import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../coolors.dart';
import '../../../widgets/date_selector.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  DateTime selectedDate = DateTime.now();
  String? selectedSlot;

  @override
  Widget build(BuildContext context) {
    final cs = customColorScheme;
    final dateFormat = DateFormat.yMMMMd();

    final slots = [
      "09:00 AM",
      "10:30 AM",
      "12:00 PM",
      "02:00 PM",
      "03:30 PM",
      "05:00 PM",
    ];

    return Theme(
      data: Theme.of(context).copyWith(colorScheme: customColorScheme),
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          title: const Text("Book Appointment"),
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Reusable DateSelector
              DateSelector(
                initialDate: selectedDate,
                onDateSelected: (date) {
                  setState(() => selectedDate = date);
                },
              ),

              const SizedBox(height: 24),
              Text(
                "Available Slots",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: slots.length,
                  itemBuilder: (context, index) {
                    final slot = slots[index];
                    final isSelected = selectedSlot == slot;
                    return GestureDetector(
                      onTap: () => setState(() => selectedSlot = slot),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? cs.secondary
                              : cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          slot,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isSelected ? cs.onSecondary : cs.onSurface,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Confirm button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedSlot != null
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  "Appointment booked on ${dateFormat.format(selectedDate)} at $selectedSlot"),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Confirm Appointment",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../coolors.dart';

/// Reusable Date Selector widget
class DateSelector extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateSelected;

  const DateSelector({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
  });

  @override
  State<DateSelector> createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  late DateTime selectedDate;
  final dateFormat = DateFormat.yMMMMd();

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(colorScheme: customColorScheme),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
      widget.onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = customColorScheme;
    final size = MediaQuery.of(context).size;

    // Generate last 5 days including today
    final last5Days = List.generate(
      5,
      (i) => DateTime.now().subtract(Duration(days: 4 - i)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Date Picker Card
        InkWell(
          onTap: () => _pickDate(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateFormat.format(selectedDate),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                Icon(Icons.calendar_today, color: cs.primary),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Last 5 days row
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: last5Days.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final day = last5Days[index];
              final isSelected = DateUtils.isSameDay(day, selectedDate);

              return GestureDetector(
                onTap: () {
                  setState(() => selectedDate = day);
                  widget.onDateSelected(day);
                },
                child: Container(
                  width: size.width / 6,
                  decoration: BoxDecoration(
                    color: isSelected ? cs.primary : cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat.E().format(day), // Day name
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? cs.onPrimary : cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${day.day}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? cs.onPrimary : cs.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

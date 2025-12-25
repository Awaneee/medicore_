// // import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart';
// // import '../../../coolors.dart';
// // import '../../../widgets/date_selector.dart';

// // class AppointmentScreen extends StatefulWidget {
// //   const AppointmentScreen({super.key});

// //   @override
// //   State<AppointmentScreen> createState() => _AppointmentScreenState();
// // }

// // class _AppointmentScreenState extends State<AppointmentScreen> {
// //   DateTime selectedDate = DateTime.now();
// //   String? selectedSlot;

// //   @override
// //   Widget build(BuildContext context) {
// //     final cs = customColorScheme;
// //     final dateFormat = DateFormat.yMMMMd();

// //     final slots = [
// //       "09:00 AM",
// //       "10:30 AM",
// //       "12:00 PM",
// //       "02:00 PM",
// //       "03:30 PM",
// //       "05:00 PM",
// //     ];

// //     return Theme(
// //       data: Theme.of(context).copyWith(colorScheme: customColorScheme),
// //       child: Scaffold(
// //         backgroundColor: cs.surface,
// //         appBar: AppBar(
// //           title: const Text("Book Appointment"),
// //           backgroundColor: cs.primary,
// //           foregroundColor: cs.onPrimary,
// //           elevation: 0,
// //           automaticallyImplyLeading: false,
// //         ),
// //         body: Padding(
// //           padding: const EdgeInsets.all(16.0),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               // ✅ Reusable DateSelector
// //               DateSelector(
// //                 initialDate: selectedDate,
// //                 onDateSelected: (date) {
// //                   setState(() => selectedDate = date);
// //                 },
// //               ),

// //               const SizedBox(height: 24),
// //               Text(
// //                 "Available Slots",
// //                 style: TextStyle(
// //                   fontSize: 18,
// //                   fontWeight: FontWeight.w600,
// //                   color: cs.onSurface,
// //                 ),
// //               ),
// //               const SizedBox(height: 12),

// //               Expanded(
// //                 child: GridView.builder(
// //                   padding: const EdgeInsets.only(bottom: 16),
// //                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
// //                     crossAxisCount: 3,
// //                     childAspectRatio: 2.5,
// //                     crossAxisSpacing: 12,
// //                     mainAxisSpacing: 12,
// //                   ),
// //                   itemCount: slots.length,
// //                   itemBuilder: (context, index) {
// //                     final slot = slots[index];
// //                     final isSelected = selectedSlot == slot;
// //                     return GestureDetector(
// //                       onTap: () => setState(() => selectedSlot = slot),
// //                       child: Container(
// //                         alignment: Alignment.center,
// //                         decoration: BoxDecoration(
// //                           color: isSelected
// //                               ? cs.secondary
// //                               : cs.surfaceContainerHighest,
// //                           borderRadius: BorderRadius.circular(10),
// //                         ),
// //                         child: Text(
// //                           slot,
// //                           style: TextStyle(
// //                             fontWeight: FontWeight.w600,
// //                             color: isSelected ? cs.onSecondary : cs.onSurface,
// //                           ),
// //                         ),
// //                       ),
// //                     );
// //                   },
// //                 ),
// //               ),

// //               // Confirm button
// //               SizedBox(
// //                 width: double.infinity,
// //                 child: ElevatedButton(
// //                   onPressed: selectedSlot != null
// //                       ? () {
// //                           ScaffoldMessenger.of(context).showSnackBar(
// //                             SnackBar(
// //                               content: Text(
// //                                   "Appointment booked on ${dateFormat.format(selectedDate)} at $selectedSlot"),
// //                             ),
// //                           );
// //                         }
// //                       : null,
// //                   style: ElevatedButton.styleFrom(
// //                     backgroundColor: cs.primary,
// //                     foregroundColor: cs.onPrimary,
// //                     padding: const EdgeInsets.symmetric(vertical: 16),
// //                     shape: RoundedRectangleBorder(
// //                       borderRadius: BorderRadius.circular(12),
// //                     ),
// //                   ),
// //                   child: const Text(
// //                     "Confirm Appointment",
// //                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart';

// // class BookAppointmentPage extends StatefulWidget {
// //   final String doctorId;
// //   final String patientId;

// //   const BookAppointmentPage({
// //     Key? key,
// //     required this.doctorId,
// //     required this.patientId,
// //   }) : super(key: key);

// //   @override
// //   State<BookAppointmentPage> createState() => _BookAppointmentPageState();
// // }

// // class _BookAppointmentPageState extends State<BookAppointmentPage> {
// //   DateTime selectedDate = DateTime.now();
// //   String? selectedSlot;
// //   bool _isBooking = false;
// //   List<String> bookedSlots = [];

// //   // Doctor working hours → 9 AM – 5 PM
// //   final List<String> allSlots = [
// //     '9:00 AM',
// //     '10:00 AM',
// //     '11:00 AM',
// //     '12:00 PM',
// //     '1:00 PM',
// //     '2:00 PM',
// //     '3:00 PM',
// //     '4:00 PM',
// //   ];

// //   @override
// //   void initState() {
// //     super.initState();
// //     _fetchBookedSlots();
// //   }

// //   Future<void> _fetchBookedSlots() async {
// //     final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);

// //     final snapshot = await FirebaseFirestore.instance
// //         .collection('doctors')
// //         .doc(widget.doctorId)
// //         .collection('appointments')
// //         .where('date', isEqualTo: dateStr)
// //         .get();

// //     setState(() {
// //       bookedSlots = snapshot.docs
// //           .map((doc) => DateFormat('h:mm a')
// //               .format((doc['slotStart'] as Timestamp).toDate()))
// //           .toList();
// //     });
// //   }

// //   Future<void> _bookAppointment() async {
// //     if (selectedSlot == null) {
// //       ScaffoldMessenger.of(context)
// //           .showSnackBar(const SnackBar(content: Text("Please select a slot")));
// //       return;
// //     }

// //     setState(() => _isBooking = true);

// //     try {
// //       int hour = int.parse(selectedSlot!.split(':')[0]);
// //       bool isPM = selectedSlot!.contains('PM');
// //       if (isPM && hour != 12) hour += 12;
// //       if (!isPM && hour == 12) hour = 0;

// //       final slotStart = DateTime(
// //         selectedDate.year,
// //         selectedDate.month,
// //         selectedDate.day,
// //         hour,
// //       );
// //       final slotEnd = slotStart.add(const Duration(hours: 1));

// //       final appointment = {
// //         'doctorId': widget.doctorId,
// //         'patientId': widget.patientId,
// //         'slotStart': Timestamp.fromDate(slotStart),
// //         'slotEnd': Timestamp.fromDate(slotEnd),
// //         'status': 'booked',
// //         'date': DateFormat('yyyy-MM-dd').format(selectedDate),
// //         'bookedAt': Timestamp.now(),
// //       };

// //       final docRef = FirebaseFirestore.instance
// //           .collection('doctors')
// //           .doc(widget.doctorId)
// //           .collection('appointments')
// //           .doc();

// //       await docRef.set(appointment);

// //       await FirebaseFirestore.instance
// //           .collection('patients')
// //           .doc(widget.patientId)
// //           .collection('appointments')
// //           .doc(docRef.id)
// //           .set(appointment);

// //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
// //           content: Text("✅ Appointment booked successfully!")));

// //       setState(() {
// //         _isBooking = false;
// //         selectedSlot = null;
// //       });

// //       _fetchBookedSlots();
// //     } catch (e) {
// //       ScaffoldMessenger.of(context)
// //           .showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
// //       setState(() => _isBooking = false);
// //     }
// //   }

// //   Future<void> _pickDate() async {
// //     final date = await showDatePicker(
// //       context: context,
// //       firstDate: DateTime.now(),
// //       lastDate: DateTime.now().add(const Duration(days: 30)),
// //       initialDate: selectedDate,
// //     );

// //     if (date != null) {
// //       setState(() {
// //         selectedDate = date;
// //         selectedSlot = null;
// //       });
// //       _fetchBookedSlots();
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     const blueColor = Color.fromARGB(255, 50, 145, 200);

// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text("Book Appointment"),
// //         backgroundColor: blueColor,
// //       ),
// //       backgroundColor: Colors.white,
// //       body: Padding(
// //         padding: const EdgeInsets.all(20),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.center,
// //           children: [
// //             Text(
// //               "Select Date",
// //               style: const TextStyle(
// //                 fontSize: 20,
// //                 fontWeight: FontWeight.bold,
// //                 color: blueColor,
// //               ),
// //             ),
// //             const SizedBox(height: 10),
// //             ElevatedButton.icon(
// //               onPressed: _pickDate,
// //               icon: const Icon(Icons.calendar_today, color: Colors.white),
// //               label: Text(
// //                 DateFormat('EEE, MMM d, yyyy').format(selectedDate),
// //                 style: const TextStyle(color: Colors.white),
// //               ),
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: blueColor,
// //                 padding:
// //                     const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
// //               ),
// //             ),
// //             const SizedBox(height: 20),
// //             Text(
// //               "Available Slots",
// //               style: const TextStyle(
// //                 fontSize: 20,
// //                 fontWeight: FontWeight.bold,
// //                 color: blueColor,
// //               ),
// //             ),
// //             const SizedBox(height: 10),

// //             // Slots Grid
// //             Expanded(
// //               child: GridView.builder(
// //                 padding: const EdgeInsets.symmetric(vertical: 10),
// //                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
// //                   crossAxisCount: 2,
// //                   mainAxisSpacing: 12,
// //                   crossAxisSpacing: 12,
// //                   childAspectRatio: 3.0,
// //                 ),
// //                 itemCount: allSlots.length,
// //                 itemBuilder: (context, index) {
// //                   final slot = allSlots[index];
// //                   final isBooked = bookedSlots.contains(slot);
// //                   final isSelected = slot == selectedSlot;

// //                   return GestureDetector(
// //                     onTap: isBooked
// //                         ? null
// //                         : () {
// //                             setState(() {
// //                               selectedSlot = slot;
// //                             });
// //                           },
// //                     child: Container(
// //                       decoration: BoxDecoration(
// //                         color: isBooked
// //                             ? Colors.grey.shade300
// //                             : isSelected
// //                                 ? blueColor
// //                                 : Colors.white,
// //                         borderRadius: BorderRadius.circular(12),
// //                         border: Border.all(
// //                             color:
// //                                 isSelected ? blueColor : Colors.grey.shade300),
// //                         boxShadow: [
// //                           BoxShadow(
// //                             color: Colors.grey.shade200,
// //                             spreadRadius: 1,
// //                             blurRadius: 4,
// //                           ),
// //                         ],
// //                       ),
// //                       alignment: Alignment.center,
// //                       child: Text(
// //                         slot,
// //                         style: TextStyle(
// //                           color: isBooked
// //                               ? Colors.black54
// //                               : isSelected
// //                                   ? Colors.white
// //                                   : blueColor,
// //                           fontWeight: FontWeight.w600,
// //                         ),
// //                       ),
// //                     ),
// //                   );
// //                 },
// //               ),
// //             ),

// //             _isBooking
// //                 ? const CircularProgressIndicator()
// //                 : ElevatedButton.icon(
// //                     onPressed: _bookAppointment,
// //                     icon: const Icon(Icons.check_circle_outline,
// //                         color: Colors.white),
// //                     label: const Text(
// //                       "Confirm Appointment",
// //                       style: TextStyle(color: Colors.white),
// //                     ),
// //                     style: ElevatedButton.styleFrom(
// //                       backgroundColor: blueColor,
// //                       padding: const EdgeInsets.symmetric(
// //                           horizontal: 50, vertical: 15),
// //                       textStyle: const TextStyle(
// //                           fontSize: 16, fontWeight: FontWeight.bold),
// //                     ),
// //                   ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:hackto/widgets/voicewidget.dart';
// import 'package:intl/intl.dart';

// class BookAppointmentPage extends StatefulWidget {
//   final String doctorId;
//   final String patientId;

//   const BookAppointmentPage({
//     Key? key,
//     required this.doctorId,
//     required this.patientId,
//   }) : super(key: key);

//   @override
//   State<BookAppointmentPage> createState() => _BookAppointmentPageState();
// }

// class _BookAppointmentPageState extends State<BookAppointmentPage> {
//   DateTime selectedDate = DateTime.now();
//   String? selectedSlot;
//   bool _isBooking = false;
//   List<String> bookedSlots = [];

//   // Doctor working hours → 9 AM – 5 PM
//   final List<String> allSlots = [
//     '9:00 AM',
//     '10:00 AM',
//     '11:00 AM',
//     '12:00 PM',
//     '1:00 PM',
//     '2:00 PM',
//     '3:00 PM',
//     '4:00 PM',
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _fetchBookedSlots();
//   }

//   Future<void> _fetchBookedSlots() async {
//     final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);

//     final snapshot = await FirebaseFirestore.instance
//         .collection('doctors')
//         .doc(widget.doctorId)
//         .collection('appointments')
//         .where('date', isEqualTo: dateStr)
//         .get();

//     setState(() {
//       bookedSlots = snapshot.docs
//           .map((doc) => DateFormat('h:mm a')
//               .format((doc['slotStart'] as Timestamp).toDate()))
//           .toList();
//     });
//   }

//   Future<void> _bookAppointment() async {
//     if (selectedSlot == null) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text("Please select a slot")));
//       return;
//     }

//     setState(() => _isBooking = true);

//     try {
//       int hour = int.parse(selectedSlot!.split(':')[0]);
//       bool isPM = selectedSlot!.contains('PM');
//       if (isPM && hour != 12) hour += 12;
//       if (!isPM && hour == 12) hour = 0;

//       final slotStart = DateTime(
//         selectedDate.year,
//         selectedDate.month,
//         selectedDate.day,
//         hour,
//       );
//       final slotEnd = slotStart.add(const Duration(hours: 1));

//       final appointment = {
//         'doctorId': widget.doctorId,
//         'patientId': widget.patientId,
//         'slotStart': Timestamp.fromDate(slotStart),
//         'slotEnd': Timestamp.fromDate(slotEnd),
//         'status': 'booked',
//         'date': DateFormat('yyyy-MM-dd').format(selectedDate),
//         'bookedAt': Timestamp.now(),
//       };

//       final docRef = FirebaseFirestore.instance
//           .collection('doctors')
//           .doc(widget.doctorId)
//           .collection('appointments')
//           .doc();

//       await docRef.set(appointment);

//       await FirebaseFirestore.instance
//           .collection('patients')
//           .doc(widget.patientId)
//           .collection('appointments')
//           .doc(docRef.id)
//           .set(appointment);

//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//           content: Text("✅ Appointment booked successfully!")));

//       setState(() {
//         _isBooking = false;
//         selectedSlot = null;
//       });

//       _fetchBookedSlots();
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
//       setState(() => _isBooking = false);
//     }
//   }

//   Future<void> _pickDate() async {
//     final date = await showDatePicker(
//       context: context,
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(const Duration(days: 30)),
//       initialDate: selectedDate,
//     );

//     if (date != null) {
//       setState(() {
//         selectedDate = date;
//         selectedSlot = null;
//       });
//       _fetchBookedSlots();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     const blueColor = Color.fromARGB(255, 50, 145, 200);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Book Appointment"),
//         backgroundColor: blueColor,
//       ),
//       backgroundColor: Colors.white,
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             // ✅ Voice Booking Widget at the top
//             const VoiceBookingWidget(),
//             const SizedBox(height: 20),

//             Text(
//               "Select Date",
//               style: const TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: blueColor,
//               ),
//             ),
//             const SizedBox(height: 10),
//             ElevatedButton.icon(
//               onPressed: _pickDate,
//               icon: const Icon(Icons.calendar_today, color: Colors.white),
//               label: Text(
//                 DateFormat('EEE, MMM d, yyyy').format(selectedDate),
//                 style: const TextStyle(color: Colors.white),
//               ),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: blueColor,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               "Available Slots",
//               style: const TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: blueColor,
//               ),
//             ),
//             const SizedBox(height: 10),

//             Expanded(
//               child: GridView.builder(
//                 padding: const EdgeInsets.symmetric(vertical: 10),
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   mainAxisSpacing: 12,
//                   crossAxisSpacing: 12,
//                   childAspectRatio: 3.0,
//                 ),
//                 itemCount: allSlots.length,
//                 itemBuilder: (context, index) {
//                   final slot = allSlots[index];
//                   final isBooked = bookedSlots.contains(slot);
//                   final isSelected = slot == selectedSlot;

//                   return GestureDetector(
//                     onTap: isBooked
//                         ? null
//                         : () {
//                             setState(() {
//                               selectedSlot = slot;
//                             });
//                           },
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: isBooked
//                             ? Colors.grey.shade300
//                             : isSelected
//                                 ? blueColor
//                                 : Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(
//                             color:
//                                 isSelected ? blueColor : Colors.grey.shade300),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.grey.shade200,
//                             spreadRadius: 1,
//                             blurRadius: 4,
//                           ),
//                         ],
//                       ),
//                       alignment: Alignment.center,
//                       child: Text(
//                         slot,
//                         style: TextStyle(
//                           color: isBooked
//                               ? Colors.black54
//                               : isSelected
//                                   ? Colors.white
//                                   : blueColor,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),

//             _isBooking
//                 ? const CircularProgressIndicator()
//                 : ElevatedButton.icon(
//                     onPressed: _bookAppointment,
//                     icon: const Icon(Icons.check_circle_outline,
//                         color: Colors.white),
//                     label: const Text(
//                       "Confirm Appointment",
//                       style: TextStyle(color: Colors.white),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: blueColor,
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 50, vertical: 15),
//                       textStyle: const TextStyle(
//                           fontSize: 16, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:hackto/widgets/voicewidget.dart';

// class BookAppointmentPage extends StatefulWidget {
//   final String doctorId;
//   final String patientId;

//   const BookAppointmentPage({
//     Key? key,
//     required this.doctorId,
//     required this.patientId,
//   }) : super(key: key);

//   @override
//   State<BookAppointmentPage> createState() => _BookAppointmentPageState();
// }

// class _BookAppointmentPageState extends State<BookAppointmentPage> {
//   DateTime selectedDate = DateTime.now();
//   String? selectedSlot;
//   bool _isBooking = false;
//   List<String> bookedSlots = [];

//   final List<String> allSlots = [
//     '9:00 AM',
//     '10:00 AM',
//     '11:00 AM',
//     '12:00 PM',
//     '1:00 PM',
//     '2:00 PM',
//     '3:00 PM',
//     '4:00 PM',
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _fetchBookedSlots();
//   }

//   Future<void> _fetchBookedSlots() async {
//     final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
//     final snapshot = await FirebaseFirestore.instance
//         .collection('doctors')
//         .doc(widget.doctorId)
//         .collection('appointments')
//         .where('date', isEqualTo: dateStr)
//         .get();

//     setState(() {
//       bookedSlots = snapshot.docs
//           .map((doc) => DateFormat('h:mm a')
//               .format((doc['slotStart'] as Timestamp).toDate()))
//           .toList();
//     });
//   }

//   Future<void> _bookAppointment() async {
//     if (selectedSlot == null) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text("Please select a slot")));
//       return;
//     }

//     setState(() => _isBooking = true);

//     try {
//       int hour = int.parse(selectedSlot!.split(':')[0]);
//       bool isPM = selectedSlot!.contains('PM');
//       if (isPM && hour != 12) hour += 12;
//       if (!isPM && hour == 12) hour = 0;

//       final slotStart = DateTime(
//         selectedDate.year,
//         selectedDate.month,
//         selectedDate.day,
//         hour,
//       );
//       final slotEnd = slotStart.add(const Duration(hours: 1));

//       final appointment = {
//         'doctorId': widget.doctorId,
//         'patientId': widget.patientId,
//         'slotStart': Timestamp.fromDate(slotStart),
//         'slotEnd': Timestamp.fromDate(slotEnd),
//         'status': 'booked',
//         'date': DateFormat('yyyy-MM-dd').format(selectedDate),
//         'bookedAt': Timestamp.now(),
//       };

//       final docRef = FirebaseFirestore.instance
//           .collection('doctors')
//           .doc(widget.doctorId)
//           .collection('appointments')
//           .doc();

//       await docRef.set(appointment);
//       await FirebaseFirestore.instance
//           .collection('patients')
//           .doc(widget.patientId)
//           .collection('appointments')
//           .doc(docRef.id)
//           .set(appointment);

//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//           content: Text("✅ Appointment booked successfully!")));

//       setState(() {
//         _isBooking = false;
//         selectedSlot = null;
//       });

//       _fetchBookedSlots();
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
//       setState(() => _isBooking = false);
//     }
//   }

//   Future<void> _pickDate() async {
//     final date = await showDatePicker(
//       context: context,
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(const Duration(days: 30)),
//       initialDate: selectedDate,
//     );

//     if (date != null) {
//       setState(() {
//         selectedDate = date;
//         selectedSlot = null;
//       });
//       _fetchBookedSlots();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     const blueColor = Color.fromARGB(255, 50, 145, 200);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Book Appointment"),
//         backgroundColor: blueColor,
//       ),
//       backgroundColor: Colors.white,
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               const VoiceBookingWidget(),
//               const SizedBox(height: 25),
//               Text(
//                 "Select Date",
//                 style: const TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: blueColor,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               ElevatedButton.icon(
//                 onPressed: _pickDate,
//                 icon: const Icon(Icons.calendar_today, color: Colors.white),
//                 label: Text(
//                   DateFormat('EEE, MMM d, yyyy').format(selectedDate),
//                   style: const TextStyle(color: Colors.white),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: blueColor,
//                   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 "Available Slots",
//                 style: const TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: blueColor,
//                 ),
//               ),
//               const SizedBox(height: 10),

//               GridView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   mainAxisSpacing: 12,
//                   crossAxisSpacing: 12,
//                   childAspectRatio: 3.0,
//                 ),
//                 itemCount: allSlots.length,
//                 itemBuilder: (context, index) {
//                   final slot = allSlots[index];
//                   final isBooked = bookedSlots.contains(slot);
//                   final isSelected = slot == selectedSlot;

//                   return GestureDetector(
//                     onTap: isBooked
//                         ? null
//                         : () {
//                             setState(() {
//                               selectedSlot = slot;
//                             });
//                           },
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: isBooked
//                             ? Colors.grey.shade300
//                             : isSelected
//                                 ? blueColor
//                                 : Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(
//                             color:
//                                 isSelected ? blueColor : Colors.grey.shade300),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.grey.shade200,
//                             spreadRadius: 1,
//                             blurRadius: 4,
//                           ),
//                         ],
//                       ),
//                       alignment: Alignment.center,
//                       child: Text(
//                         slot,
//                         style: TextStyle(
//                           color: isBooked
//                               ? Colors.black54
//                               : isSelected
//                                   ? Colors.white
//                                   : blueColor,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//               const SizedBox(height: 25),
//               _isBooking
//                   ? const CircularProgressIndicator()
//                   : ElevatedButton.icon(
//                       onPressed: _bookAppointment,
//                       icon: const Icon(Icons.check_circle_outline,
//                           color: Colors.white),
//                       label: const Text(
//                         "Confirm Appointment",
//                         style: TextStyle(color: Colors.white),
//                       ),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: blueColor,
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 50, vertical: 15),
//                         textStyle: const TextStyle(
//                             fontSize: 16, fontWeight: FontWeight.bold),
//                       ),
//                     ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:hackto/widgets/voicewidget.dart';
// import 'package:intl/intl.dart';

// class BookAppointmentPage extends StatefulWidget {
//   final String doctorId;
//   final String patientId;

//   BookAppointmentPage({required this.doctorId, required this.patientId});

//   @override
//   State<BookAppointmentPage> createState() => _BookAppointmentPageState();
// }

// class _BookAppointmentPageState extends State<BookAppointmentPage> {
//   DateTime selectedDate = DateTime.now();
//   String? selectedSlot;
//   List<String> bookedSlots = [];
//   bool booking = false;

//   List<String> slots = [
//     "9:00 AM",
//     "10:00 AM",
//     "11:00 AM",
//     "12:00 PM",
//     "1:00 PM",
//     "2:00 PM",
//     "3:00 PM",
//     "4:00 PM",
//   ];

//   @override
//   void initState() {
//     super.initState();
//     fetchBookedSlots();
//   }

//   Future<void> fetchBookedSlots() async {
//     final s = await FirebaseFirestore.instance
//         .collection("doctors")
//         .doc(widget.doctorId)
//         .collection("appointments")
//         .where("date", isEqualTo: DateFormat("yyyy-MM-dd").format(selectedDate))
//         .get();

//     setState(() {
//       bookedSlots = s.docs
//           .map((d) => DateFormat('h:mm a')
//               .format((d['slotStart'] as Timestamp).toDate()))
//           .toList();
//     });
//   }

//   ////////////////////////////////////////////////////////////////////////////
//   // 🔥 AUTO BOOKING USING VOICE
//   ////////////////////////////////////////////////////////////////////////////

//   Future<void> autoBook(String? date, String? time) async {
//     if (date == null) {
//       date = DateFormat("yyyy-MM-dd")
//           .format(DateTime.now().add(Duration(days: 1)));
//     }

//     selectedDate = DateTime.parse(date);
//     await fetchBookedSlots();

//     if (time == null) {
//       time = slots.firstWhere((s) => !bookedSlots.contains(s),
//           orElse: () => slots.first);
//     }

//     selectedSlot = time;
//     bookNow(); // call manual booking method
//     ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("🎉 Voice Booking Done for $date at $time")));
//   }

//   ////////////////////////////////////////////////////////////////////////////
//   // 📌 MANUAL BOOKING (unchanged)
//   ////////////////////////////////////////////////////////////////////////////

//   Future<void> bookNow() async {
//     if (selectedSlot == null) return;

//     booking = true;
//     setState(() {});

//     try {
//       int hour = int.parse(selectedSlot!.split(':')[0]);
//       bool pm = selectedSlot!.contains("PM");
//       if (pm && hour != 12) hour += 12;
//       if (!pm && hour == 12) hour = 0;

//       DateTime start = DateTime(
//           selectedDate.year, selectedDate.month, selectedDate.day, hour);
//       DateTime end = start.add(Duration(hours: 1));

//       final data = {
//         "doctorId": widget.doctorId,
//         "patientId": widget.patientId,
//         "slotStart": Timestamp.fromDate(start),
//         "slotEnd": Timestamp.fromDate(end),
//         "date": DateFormat("yyyy-MM-dd").format(selectedDate),
//         "status": "booked",
//         "bookedAt": Timestamp.now()
//       };

//       var ref = FirebaseFirestore.instance
//           .collection("doctors")
//           .doc(widget.doctorId)
//           .collection("appointments")
//           .doc();
//       await ref.set(data);
//       FirebaseFirestore.instance
//           .collection("patients")
//           .doc(widget.patientId)
//           .collection("appointments")
//           .doc(ref.id)
//           .set(data);

//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text("✔ Appointment Booked")));

//       booking = false;
//       selectedSlot = null;
//       setState(() {});
//       fetchBookedSlots();
//     } catch (e) {
//       booking = false;
//       setState(() {});
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text("Error: $e")));
//     }
//   }

//   ////////////////////////////////////////////////////////////////////////////

//   @override
//   Widget build(context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Book Appointment")),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(20),
//         child: Column(children: [
//           // 🔥 Voice Booking Here
//           VoiceBookingWidget(
//             onExtracted: (d, t) => autoBook(d, t), // <-- Hooked Here
//           ),

//           SizedBox(height: 15),

//           Text("Manual Date Selection",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//           // Manual still works
//           Text("${DateFormat('EEE, MMM d, yyyy').format(selectedDate)}"),

//           SizedBox(height: 10),

//           Wrap(
//               spacing: 10,
//               children: slots.map((s) {
//                 bool unavailable = bookedSlots.contains(s);
//                 bool sel = s == selectedSlot;
//                 return ChoiceChip(
//                   label: Text(s),
//                   selected: sel,
//                   onSelected: unavailable
//                       ? null
//                       : (_) => setState(() => selectedSlot = s),
//                   disabledColor: Colors.grey,
//                   selectedColor: Colors.blue,
//                 );
//               }).toList()),

//           SizedBox(height: 20),

//           booking
//               ? CircularProgressIndicator()
//               : ElevatedButton(
//                   onPressed: bookNow,
//                   child: Text("Book Appointment"),
//                 ),
//         ]),
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:hackto/widgets/voicewidget.dart';
// import 'package:intl/intl.dart';

// class BookAppointmentPage extends StatefulWidget {
//   final String doctorId;
//   final String patientId;

//   BookAppointmentPage({required this.doctorId, required this.patientId});

//   @override
//   State<BookAppointmentPage> createState() => _BookAppointmentPageState();
// }

// class _BookAppointmentPageState extends State<BookAppointmentPage> {
//   DateTime selectedDate = DateTime.now();
//   String? selectedSlot;
//   List<String> booked = [];
//   bool loading = false;

//   final slots = [
//     "9:00 AM","10:00 AM","11:00 AM","12:00 PM",
//     "1:00 PM","2:00 PM","3:00 PM","4:00 PM",
//   ];

//   @override
//   void initState() { super.initState(); fetchBooked(); }

//   Future<void> fetchBooked() async {
//     final snap = await FirebaseFirestore.instance
//         .collection("doctors").doc(widget.doctorId)
//         .collection("appointments")
//         .where("date", isEqualTo: DateFormat("yyyy-MM-dd").format(selectedDate))
//         .get();

//     setState(() {
//       booked = snap.docs.map((d)=>
//         DateFormat('h:mm a').format((d['slotStart'] as Timestamp).toDate())
//       ).toList();
//     });
//   }

//   // 🔥 AUTO BOOK VIA VOICE
//   Future<void> autoBook(String? date, String? time) async {
//     print("VOICE >> date=$date  time=$time");

//     if (date==null) {
//       date = DateFormat("yyyy-MM-dd").format(DateTime.now().add(Duration(days: 1)));
//       ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("📅 No date detected → Auto set to tomorrow")));
//     }

//     selectedDate = DateTime.parse(date);
//     await fetchBooked();

//     if (time==null) {
//       time = slots.firstWhere((s)=>!booked.contains(s), orElse: ()=>slots.first);
//       ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("⏰ No time detected → Assigned first free slot")));
//     }

//     selectedSlot = time;
//     await bookManual();

//     ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("🎉 Booked: $date at $time by voice")));
//   }

//   // 📌 MANUAL BOOKING (unchanged)
//   Future<void> bookManual() async {
//     if (selectedSlot==null) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Select a slot")));
//       return;
//     }

//     setState(()=>loading=true);

//     try {
//       int hour = int.parse(selectedSlot!.split(':')[0]);
//       bool pm = selectedSlot!.contains("PM");
//       if (pm && hour!=12) hour+=12;
//       if (!pm && hour==12) hour=0;

//       DateTime start = DateTime(selectedDate.year,selectedDate.month,selectedDate.day,hour);
//       DateTime end = start.add(Duration(hours:1));

//       final data = {
//         "doctorId":widget.doctorId,"patientId":widget.patientId,
//         "slotStart":Timestamp.fromDate(start),"slotEnd":Timestamp.fromDate(end),
//         "status":"booked",
//         "date":DateFormat("yyyy-MM-dd").format(selectedDate),
//         "bookedAt":Timestamp.now()
//       };

//       var doc = FirebaseFirestore.instance
//           .collection("doctors").doc(widget.doctorId)
//           .collection("appointments").doc();

//       await doc.set(data);
//       FirebaseFirestore.instance.collection("patients")
//         .doc(widget.patientId).collection("appointments")
//         .doc(doc.id).set(data);

//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("✔ Appointment booked")));

//     } catch(e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ $e")));
//     }

//     setState(()=>loading=false);
//     selectedSlot=null;
//     fetchBooked();
//   }

//   @override
//   Widget build(context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Book Appointment"), backgroundColor: Colors.teal),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(20),
//         child: Column(children:[

//           // 🎤 ENABLES AUTO BOOKING
//           VoiceBookingWidget(
//             onExtracted:(d,t)=> autoBook(d,t),
//           ),

//           SizedBox(height:20),
//           Text("Manual Date Selection", style:TextStyle(fontSize:18,fontWeight:FontWeight.bold)),
//           Text(DateFormat("EEE, MMM d yyyy").format(selectedDate)),

//           SizedBox(height:10),

//           Wrap(
//             spacing:10, runSpacing:10,
//             children: slots.map((s){
//               bool taken=booked.contains(s);
//               bool sel=s==selectedSlot;
//               return ChoiceChip(
//                 label:Text(s),
//                 selected:sel,
//                 selectedColor:Color.fromARGB(255, 62, 128, 172),
//                 labelStyle:TextStyle(color:sel?Colors.white:Colors.black),
//                 onSelected:taken?null:(_)=>setState(()=>selectedSlot=s),
//               );
//             }).toList(),
//           ),

//           SizedBox(height:20),
//           loading?CircularProgressIndicator():
//           ElevatedButton(
//             onPressed:bookManual,
//             style:ElevatedButton.styleFrom(backgroundColor:Colors.teal),
//             child:Text("Book Appointment")
//           ),

//         ]),
//       ),
//     );
//   }
// }
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:hackto/widgets/voicewidget.dart';
// import 'package:intl/intl.dart';

// class BookAppointmentPage extends StatefulWidget {
//   final String doctorId;
//   final String patientId;

//   const BookAppointmentPage({
//     super.key,
//     required this.doctorId,
//     required this.patientId,
//   });

//   @override
//   State<BookAppointmentPage> createState()=>_BookAppointmentPageState();
// }

// class _BookAppointmentPageState extends State<BookAppointmentPage>{
//   DateTime selectedDate=DateTime.now();
//   String? selectedSlot;
//   List<String> booked=[];
//   String message=""; Color msgColor=Colors.transparent;

//   List<String> slots=[
//     "9:00 AM","10:00 AM","11:00 AM","12:00 PM",
//     "1:00 PM","2:00 PM","3:00 PM","4:00 PM"
//   ];

//   @override initState(){super.initState(); load();}

//   Future load() async{
//     String d=DateFormat("yyyy-MM-dd").format(selectedDate);
//     final snap=await FirebaseFirestore.instance
//         .collection("doctors").doc(widget.doctorId)
//         .collection("appointments").where("date",isEqualTo:d).get();

//     setState(()=> booked=snap.docs.map((e)=>
//         DateFormat("h:mm a").format((e["slotStart"]as Timestamp).toDate())
//     ).toList());
//   }

//   Future autoBook(String? date,String? time) async {
//     setState(()=>msg("Processing voice booking...",Colors.blue));

//     if(date==null){
//       date=DateFormat("yyyy-MM-dd").format(DateTime.now().add(Duration(days:1)));
//       msg("⚠ No date detected → booking tomorrow",Colors.orange);
//     }

//     selectedDate=DateTime.parse(date);
//     await load();

//     if(time==null){
//       time=slots.firstWhere((s)=>!booked.contains(s),orElse:()=>slots.first);
//       msg("⚠ No time detected → first free slot selected",Colors.orange);
//     }

//     selectedSlot=time;
//     book();
//   }

//   void msg(String t, Color c){
//     setState((){message=t; msgColor=c;});
//   }

//   Future book() async {
//     try{
//       int h=int.parse(selectedSlot!.split(":")[0]);
//       bool pm=selectedSlot!.contains("PM");
//       if(pm&&h!=12)h+=12;
//       if(!pm&&h==12)h=0;

//       DateTime s=DateTime(selectedDate.year,selectedDate.month,selectedDate.day,h);
//       DateTime e=s.add(Duration(hours:1));

//       final data={
//         "doctorId":widget.doctorId,"patientId":widget.patientId,
//         "slotStart":Timestamp.fromDate(s),"slotEnd":Timestamp.fromDate(e),
//         "date":DateFormat("yyyy-MM-dd").format(selectedDate),
//         "status":"booked","bookedAt":Timestamp.now()
//       };

//       final ref=FirebaseFirestore.instance.collection("doctors")
//           .doc(widget.doctorId).collection("appointments").doc();

//       await ref.set(data);

//       await FirebaseFirestore.instance.collection("patients")
//           .doc(widget.patientId).collection("appointments")
//           .doc(ref.id).set(data);

//       msg("🟢 Booked: ${DateFormat('MMM d, yyyy').format(selectedDate)} at $selectedSlot",Colors.green);

//     }catch(e){
//       msg("❌ Failed: $e",Colors.red);
//     }
//   }

//   @override
//   Widget build(context){
//     return Scaffold(
//       appBar:AppBar(title:Text("Book Appointment")),
//       body:SingleChildScrollView(
//         padding:EdgeInsets.all(20),
//         child:Column(children:[

//           /// 🔥 VOICE BOOKING
//           VoiceBookingWidget(onExtracted:(d,t)=>autoBook(d,t)),

//           if(message.isNotEmpty)...[
//             SizedBox(height:10),
//             Container(
//               padding:EdgeInsets.all(10),
//               decoration:BoxDecoration(
//                 color:msgColor.withOpacity(.2),
//                 borderRadius:BorderRadius.circular(8),
//               ),
//               child:Text(message,style:TextStyle(
//                 color:msgColor,fontWeight:FontWeight.bold,fontSize:16),
//                 textAlign:TextAlign.center),
//             )
//           ],

//           SizedBox(height:25),
//           Text("OR Manual Booking ↓",style:TextStyle(fontWeight:FontWeight.bold)),

//           SizedBox(height:10),
//           Text("${DateFormat('EEE, MMM d').format(selectedDate)}"),

//           GridView.builder(
//             shrinkWrap:true,physics:NeverScrollableScrollPhysics(),
//             itemCount:slots.length,
//             gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount:2,childAspectRatio:3),
//             itemBuilder:(c,i){
//               String s=slots[i];
//               bool taken=booked.contains(s);
//               bool sel=selectedSlot==s;

//               return GestureDetector(
//                 onTap:taken?null:()=>setState(()=>selectedSlot=s),
//                 child:Container(
//                   margin:EdgeInsets.all(6),
//                   decoration:BoxDecoration(
//                     color:taken?Colors.grey.shade300:sel?const Color.fromARGB(255, 58, 152, 224):Colors.white,
//                     borderRadius:BorderRadius.circular(8),
//                   ),
//                   alignment:Alignment.center, child:Text(s),
//                 ),
//               );
//             }),

//           ElevatedButton(
//             onPressed:book,
//             child:Text("Confirm Manually"),
//           ),

//         ]),
//       ),
//     );
//   }
// }
// FULL REPLACEMENT — PASTE COMPLETELY.

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:hackto/widgets/voicewidget.dart';
// import 'package:intl/intl.dart';

// class BookAppointmentPage extends StatefulWidget {
//   final String doctorId, patientId;
//   const BookAppointmentPage({super.key,required this.doctorId,required this.patientId});

//   @override State<BookAppointmentPage> createState()=>_BookAppointmentPageState();
// }

// class _BookAppointmentPageState extends State<BookAppointmentPage>{
//   DateTime selectedDate = DateTime.now();
//   String? detectedDate, detectedTime;
//   List<String> booked=[];
//   String? selectedSlot;

//   List<String> slots=[
//     "9:00 AM","10:00 AM","11:00 AM","12:00 PM",
//     "1:00 PM","2:00 PM","3:00 PM","4:00 PM"
//   ];

//   @override initState(){super.initState();_load();}

//   Future _load() async {
//     final day = DateFormat("yyyy-MM-dd").format(selectedDate);
//     final snap = await FirebaseFirestore.instance
//         .collection("doctors").doc(widget.doctorId)
//         .collection("appointments").where("date",isEqualTo:day).get();

//     setState(() =>
//       booked = snap.docs.map((e)=>
//         DateFormat("h:mm a").format((e["slotStart"]as Timestamp).toDate())
//       ).toList());
//   }

//   Future voiceConfirm() async {
//     String date = detectedDate ?? DateFormat("yyyy-MM-dd").format(DateTime.now().add(Duration(days:1)));
//     String time = detectedTime ??
//       slots.firstWhere((s)=>!booked.contains(s),orElse:()=>slots.first);

//     _book(date,time);
//   }

//   Future _book(String date,String time) async {
//     try{
//       selectedDate = DateTime.parse(date);
//       selectedSlot = time;

//       int h = int.parse(time.split(":")[0]);
//       bool pm=time.contains("PM");
//       if(pm&&h!=12)h+=12;
//       if(!pm&&h==12)h=0;

//       DateTime st = DateTime(selectedDate.year,selectedDate.month,selectedDate.day,h);
//       DateTime en = st.add(Duration(hours:1));

//       final data={
//         "doctorId":widget.doctorId,"patientId":widget.patientId,
//         "slotStart":Timestamp.fromDate(st),"slotEnd":Timestamp.fromDate(en),
//         "date":date,"status":"booked","bookedAt":Timestamp.now()
//       };

//       final ref=FirebaseFirestore.instance.collection("doctors")
//           .doc(widget.doctorId).collection("appointments").doc();
//       await ref.set(data);

//       await FirebaseFirestore.instance.collection("patients")
//           .doc(widget.patientId).collection("appointments")
//           .doc(ref.id).set(data);

//       _toast("🟢 Appointment Booked for $time on ${DateFormat('MMM d yyyy').format(selectedDate)}",Colors.green);

//       _load();

//     }catch(e){ _toast("❌ Failed: $e",Colors.red); }
//   }

//   void _toast(msg,color){
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content:Text(msg),backgroundColor:color));
//   }

//   @override Widget build(context){
//     return Scaffold(
//       appBar:AppBar(title:Text("Book Appointment")),
//       body:SingleChildScrollView(
//       padding:EdgeInsets.all(18),
//       child:Column(children:[

//        /// VOICE WIDGET
//        VoiceBookingWidget(onExtracted:(d,t){
//         detectedDate=d; detectedTime=t;
//        }),

//        if(detectedDate!=null||detectedTime!=null)...[
//          SizedBox(height:12),
//          ElevatedButton(
//            onPressed:voiceConfirm,
//            child:Text("📢 Confirm Voice Booking"),
//          )
//        ],

//        SizedBox(height:20),
//        Text("Or Book Manually",style:TextStyle(fontWeight:FontWeight.bold)),

//        SizedBox(height:10),
//        ElevatedButton(
//          onPressed:() async{
//            DateTime? pick=await showDatePicker(
//              context:context,initialDate:selectedDate,
//              firstDate:DateTime.now(),lastDate:DateTime.now().add(Duration(days:365)));
//            if(pick!=null){selectedDate=pick;_load();setState((){});}
//          },
//          child:Text(DateFormat('EEE, MMM d yyyy').format(selectedDate)),
//        ),

//        GridView.builder(
//          shrinkWrap:true,physics:NeverScrollableScrollPhysics(),
//          itemCount:slots.length,
//          gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2,childAspectRatio:3),
//          itemBuilder:(c,i){
//            String s=slots[i];
//            bool taken=booked.contains(s);
//            return GestureDetector(
//              onTap:taken?null:()=>setState(()=>selectedSlot=s),
//              child:Container(
//                margin:EdgeInsets.all(6),
//                decoration:BoxDecoration(
//                  color:taken?Colors.grey.shade300:
//                        selectedSlot==s?Colors.blue:Colors.white,
//                  borderRadius:BorderRadius.circular(8),
//                ),
//                alignment:Alignment.center,child:Text(s),
//              ));
//        }),

//        SizedBox(height:8),
//        ElevatedButton(
//          onPressed:(){
//            if(selectedSlot==null){_toast("Select time first",Colors.red);return;}
//            _book(DateFormat("yyyy-MM-dd").format(selectedDate),selectedSlot!);
//          },
//          child:Text("Confirm Manually"),
//        )

//       ])));
//     }
//   }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hackto/widgets/voicewidget.dart';
import 'package:intl/intl.dart';

class BookAppointmentPage extends StatefulWidget {
  final String doctorId, patientId;
  const BookAppointmentPage(
      {super.key, required this.doctorId, required this.patientId});

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  DateTime selectedDate = DateTime.now();
  String? detectedDate, detectedTime;
  List<String> booked = [];
  String? selectedSlot;
  String? bannerMsg;
  Color bannerColor = Colors.transparent;

  List<String> slots = [
    "9:00 AM",
    "10:00 AM",
    "11:00 AM",
    "12:00 PM",
    "1:00 PM",
    "2:00 PM",
    "3:00 PM",
    "4:00 PM"
  ];

  @override
  void initState() {
    super.initState();
    load();
  }

  // Load booked slots from Firebase
  Future load() async {
    final d = DateFormat("yyyy-MM-dd").format(selectedDate);
    final snap = await FirebaseFirestore.instance
        .collection("doctors")
        .doc(widget.doctorId)
        .collection("appointments")
        .where("date", isEqualTo: d)
        .get();

    setState(() {
      booked = snap.docs
          .map((e) => DateFormat("h:mm a")
              .format((e["slotStart"] as Timestamp).toDate()))
          .toList();
    });
  }

  // Confirm Voice Booking -> if time/date NULL use next-day/first-slot
  Future voiceConfirm() async {
    String date = detectedDate ??
        DateFormat("yyyy-MM-dd")
            .format(DateTime.now().add(const Duration(days: 1)));

    String time = detectedTime ??
        slots.firstWhere((s) => !booked.contains(s), orElse: () => slots.first);

    setState(() {
      selectedDate = DateTime.parse(date);
      selectedSlot = time;
    });

    _book(date, time);
  }

  // Book appointment in Firebase
  Future _book(String date, String time) async {
    try {
      int h = int.parse(time.split(":")[0]);
      bool pm = time.contains("PM");
      if (pm && h != 12) h += 12;
      if (!pm && h == 12) h = 0;

      DateTime st =
          DateTime(selectedDate.year, selectedDate.month, selectedDate.day, h);
      DateTime en = st.add(const Duration(hours: 1));

      final data = {
        "doctorId": widget.doctorId,
        "patientId": widget.patientId,
        "slotStart": Timestamp.fromDate(st),
        "slotEnd": Timestamp.fromDate(en),
        "date": date,
        "status": "booked",
        "bookedAt": Timestamp.now()
      };

      final ref = FirebaseFirestore.instance
          .collection("doctors")
          .doc(widget.doctorId)
          .collection("appointments")
          .doc();

      await ref.set(data);
      await FirebaseFirestore.instance
          .collection("patients")
          .doc(widget.patientId)
          .collection("appointments")
          .doc(ref.id)
          .set(data);

      setState(() {
        bannerMsg =
            "🟢 Appointment Booked — $time, ${DateFormat('MMM d yyyy').format(selectedDate)}";
        bannerColor = Colors.green;
      });

      load();
    } catch (e) {
      setState(() {
        bannerMsg = "❌ Failed: $e";
        bannerColor = Colors.red;
      });
    }
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Book Appointment")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // 🔹 Voice Widget
          VoiceBookingWidget(onExtracted: (d, t) {
            setState(() {
              detectedDate = d;
              detectedTime = t;
            });
          }),

          // 🔹 Show extracted result + button
          if (detectedDate != null || detectedTime != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green)),
              child: Column(children: [
                const Text("📌 Voice Detected:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text("Date → ${detectedDate ?? "Next Day (Auto)"}"),
                Text("Time → ${detectedTime ?? "First Available (Auto)"}"),
              ]),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: voiceConfirm,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: const Text("📢 Confirm Voice Booking"),
            )
          ],

          if (bannerMsg != null) ...[
            const SizedBox(height: 15),
            Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: bannerColor.withOpacity(.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: bannerColor)),
                child: Text(bannerMsg!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: bannerColor, fontWeight: FontWeight.bold)))
          ],

          const SizedBox(height: 25),
          const Text("Or Book Manually",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          // 🔹 Date Picker
          ElevatedButton(
            onPressed: () async {
              DateTime? d = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );

              if (d != null) {
                selectedDate = d;
                selectedSlot = null;
                load();
                setState(() {});
              }
            },
            child: Text(DateFormat("EEE, MMM d yyyy").format(selectedDate)),
          ),

          const SizedBox(height: 10),

          // 🔹 Grid of slots
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: slots.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 3),
            itemBuilder: (c, i) {
              String s = slots[i];
              bool taken = booked.contains(s);

              return GestureDetector(
                onTap: taken ? null : () => setState(() => selectedSlot = s),
                child: Container(
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: taken
                        ? Colors.grey.shade300
                        : (selectedSlot == s)
                            ? Colors.blue
                            : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    s,
                    style: TextStyle(
                        color: taken ? Colors.black54 : Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              if (selectedSlot == null) {
                setState(() {
                  bannerMsg = "❌ Select a slot first";
                  bannerColor = Colors.red;
                });
                return;
              }
              _book(
                  DateFormat("yyyy-MM-dd").format(selectedDate), selectedSlot!);
            },
            child: const Text("Confirm Manually"),
          )
        ]),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class VoiceBookingWidget extends StatefulWidget {
//   const VoiceBookingWidget({Key? key}) : super(key: key);

//   @override
//   _VoiceBookingWidgetState createState() => _VoiceBookingWidgetState();
// }

// class _VoiceBookingWidgetState extends State<VoiceBookingWidget>
//     with SingleTickerProviderStateMixin {
//   late stt.SpeechToText _speech;
//   bool _isListening = false;
//   bool _isProcessing = false;
//   String _spokenText = "Tap the mic and say your appointment request...";
//   String? _resultText;
//   String _statusText = "Idle 🎤";

//   late AnimationController _animationController;

//   @override
//   void initState() {
//     super.initState();
//     try {
//       _speech = stt.SpeechToText();
//     } catch (e) {
//       print("❌ Speech initialization error: $e");
//     }
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 800),
//     );
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   // 🎤 Start listening to voice
//   Future<void> _startListening() async {
//     try {
//       bool available = await _speech.initialize();
//       if (available) {
//         setState(() {
//           _isListening = true;
//           _statusText = "Listening...";
//           _spokenText = "";
//           _resultText = null;
//         });
//         _animationController.repeat(reverse: true);

//         _speech.listen(
//           onResult: (val) {
//             setState(() {
//               _spokenText = val.recognizedWords;
//             });

//             // Automatically stop when final result is detected
//             if (val.finalResult) {
//               _stopListening(sendImmediately: true);
//             }
//           },
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("⚠️ Speech recognition not available")),
//         );
//       }
//     } catch (e) {
//       print("❌ Error starting listening: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error: $e")),
//       );
//     }
//   }

//   // 🛑 Stop listening
//   Future<void> _stopListening({bool sendImmediately = false}) async {
//     try {
//       await _speech.stop();
//     } catch (_) {}
//     _animationController.stop();

//     setState(() {
//       _isListening = false;
//       _statusText = "Done 🎤";
//     });

//     if (sendImmediately && _spokenText.isNotEmpty) {
//       await _sendToBackend();
//     }
//   }

//   // 🌐 Send recognized text to backend
//   Future<void> _sendToBackend() async {
//     setState(() {
//       _isProcessing = true;
//       _resultText = null;
//       _statusText = "Processing...";
//     });

//     try {
//       // 🧩 Use 10.0.2.2 for Android emulator, or replace with local IP if on device
//       final url = Uri.parse('http://10.0.2.2:8000/book_appointment');
//       print("🎤 Sending text: $_spokenText");
//       print("➡️ POST to backend: $url");

//       final response = await http.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({"input": _spokenText}),
//       );

//       print("📨 Response status: ${response.statusCode}");
//       print("📦 Response body: ${response.body}");

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);

//         setState(() {
//           _resultText = data["extracted_time"] ??
//               data["result"] ??
//               data["error"] ??
//               "No valid response received.";
//           _statusText = "✅ Response received!";
//         });

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("✅ Response: $_resultText")),
//         );
//       } else {
//         setState(() {
//           _resultText = "Error: ${response.body}";
//           _statusText = "❌ Error from backend";
//         });
//       }
//     } catch (e) {
//       print("❌ Error sending to backend: $e");
//       setState(() {
//         _resultText = "⚠️ Failed to connect: $e";
//         _statusText = "Connection failed";
//       });
//     } finally {
//       setState(() => _isProcessing = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final themeColor = Colors.teal;

//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 16),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.shade300,
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           const Text(
//             "🎙️ Voice Appointment Assistant",
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             _statusText,
//             style: const TextStyle(fontSize: 16, color: Colors.black54),
//           ),
//           const SizedBox(height: 10),

//           // 🗣 Recognized text
//           Text(
//             _spokenText.isEmpty
//                 ? "Say something like 'Book my appointment at 3 PM tomorrow'"
//                 : _spokenText,
//             style: TextStyle(
//               fontSize: 16,
//               fontStyle: FontStyle.italic,
//               color: _isListening ? themeColor : Colors.black87,
//             ),
//             textAlign: TextAlign.center,
//           ),

//           const SizedBox(height: 20),

//           // 🎤 Mic button
//           GestureDetector(
//             onTap: _isListening ? _stopListening : _startListening,
//             child: ScaleTransition(
//               scale: Tween(begin: 1.0, end: 1.2).animate(
//                 CurvedAnimation(
//                   parent: _animationController,
//                   curve: Curves.easeInOut,
//                 ),
//               ),
//               child: CircleAvatar(
//                 radius: 45,
//                 backgroundColor: _isListening ? Colors.redAccent : themeColor,
//                 child: Icon(
//                   _isListening ? Icons.stop_rounded : Icons.mic_rounded,
//                   size: 40,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),

//           const SizedBox(height: 25),

//           // 🌐 Processing loader / result
//           if (_isProcessing)
//             const Column(
//               children: [
//                 CircularProgressIndicator(),
//                 SizedBox(height: 8),
//                 Text("Processing your request...",
//                     style: TextStyle(fontSize: 15)),
//               ],
//             )
//           else if (_resultText != null)
//             Container(
//               margin: const EdgeInsets.only(top: 10),
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: themeColor.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Text(
//                 "🕒 Extracted Slot:\n$_resultText",
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'dart:async';

// class VoiceBookingWidget extends StatefulWidget {
//   const VoiceBookingWidget({Key? key}) : super(key: key);

//   @override
//   _VoiceBookingWidgetState createState() => _VoiceBookingWidgetState();
// }

// class _VoiceBookingWidgetState extends State<VoiceBookingWidget>
//     with SingleTickerProviderStateMixin {
//   late stt.SpeechToText _speech;
//   bool _isListening = false;
//   bool _isProcessing = false;

//   String _spokenText = "";
//   String? _resultText;
//   String _status = "Idle 🕓";
//   String _subStatus = "Tap the mic to start speaking";

//   late AnimationController _animCtrl;

//   @override
//   void initState() {
//     super.initState();
//     try {
//       _speech = stt.SpeechToText();
//     } catch (e) {
//       _updateStatus("❌ Error initializing speech", e.toString());
//     }

//     _animCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 700),
//     );
//   }

//   void _updateStatus(String main, [String? sub]) {
//     setState(() {
//       _status = main;
//       if (sub != null) _subStatus = sub;
//     });
//   }

//   @override
//   void dispose() {
//     _animCtrl.dispose();
//     super.dispose();
//   }

//   Future<void> _startListening() async {
//     try {
//       bool available = await _speech.initialize();
//       if (!available) {
//         _updateStatus("⚠️ Mic unavailable", "Speech recognition not ready");
//         return;
//       }

//       _updateStatus("🎤 Listening...", "Speak your appointment request");
//       setState(() {
//         _isListening = true;
//         _spokenText = "";
//         _resultText = null;
//       });

//       _animCtrl.repeat(reverse: true);
//       _speech.listen(
//         onResult: (val) {
//           setState(() {
//             _spokenText = val.recognizedWords;
//           });

//           if (val.finalResult) {
//             _stopListening(sendImmediately: true);
//           }
//         },
//       );
//     } catch (e) {
//       _updateStatus("❌ Listening error", e.toString());
//     }
//   }

//   Future<void> _stopListening({bool sendImmediately = false}) async {
//     try {
//       await _speech.stop();
//     } catch (_) {}
//     _animCtrl.stop();
//     setState(() => _isListening = false);
//     _updateStatus("🛑 Done listening", "Preparing to send to backend...");

//     if (sendImmediately && _spokenText.isNotEmpty) {
//       await _sendToBackend();
//     }
//   }
// Future<void> _sendToBackend() async {
//   setState(() => _isProcessing = true);
//   _updateStatus("🌐 Sending to backend", "Please wait...");

//   try {
//     final url = Uri.parse('http://10.0.2.2:8000/book_appointment');
//     final body = json.encode({"input": _spokenText});

//     _updateStatus("📤 Sending Request", body);

//     final response = await http
//         .post(
//           url,
//           headers: {'Content-Type': 'application/json'},
//           body: body,
//         )
//         .timeout(const Duration(seconds: 10)); // ⏳ ADDED TIMEOUT

//     _updateStatus("📩 Response Received",
//         "Status: ${response.statusCode}\n${response.body}");

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);

//       setState(() {
//         _resultText = data["extracted_time"] ??
//             "No date/time extracted from backend";
//       });

//       _updateStatus("✅ Success", "Backend processed successfully!");
//     } else {
//       _updateStatus("❌ Server Error", response.body);
//       _resultText = "Server Error: ${response.body}";
//     }
//   } on TimeoutException {
//     _updateStatus("⏳ Timeout", "Backend did not respond (Check 10.0.2.2)");
//     _resultText = "Timeout — backend unreachable.";
//   } catch (e) {
//     _updateStatus("⚠️ Connection Error", e.toString());
//     _resultText = "Failed to connect to backend:\n$e";
//   } finally {
//     setState(() => _isProcessing = false);
//   }
// }

//   // Future<void> _sendToBackend() async {
//   //   setState(() => _isProcessing = true);
//   //   _updateStatus("🌐 Sending to backend", "Please wait...");

//   //   try {
//   //     final url = Uri.parse('http://10.0.2.2:8000/book_appointment');
//   //     final body = json.encode({"input": _spokenText});

//   //     _updateStatus("📤 Sending Request", body);
//   //     final response = await http.post(url,
//   //         headers: {'Content-Type': 'application/json'}, body: body);

//   //     _updateStatus("📩 Response Received",
//   //         "Status: ${response.statusCode}\n${response.body}");

//   //     if (response.statusCode == 200) {
//   //       final data = json.decode(response.body);
//   //       setState(() {
//   //         _resultText = data["extracted_time"] ??
//   //             data["result"] ??
//   //             data["error"] ??
//   //             "No recognizable time found.";
//   //       });
//   //       _updateStatus("✅ Success", "Backend processed successfully!");
//   //     } else {
//   //       _updateStatus("❌ Server Error", response.body);
//   //       _resultText = "Error: ${response.body}";
//   //     }
//   //   } catch (e) {
//   //     _updateStatus("⚠️ Connection Error", e.toString());
//   //     _resultText = "Failed to connect to backend:\n$e";
//   //   } finally {
//   //     setState(() => _isProcessing = false);
//   //   }
//   // }

//   @override
//   Widget build(BuildContext context) {
//     final themeColor = Colors.teal;

//     return Container(
//       width: double.infinity,
//       margin: const EdgeInsets.symmetric(vertical: 16),
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.shade300,
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           const Text(
//             "🎙️ Voice Appointment Assistant",
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 10),

//           // 🔍 Status Panel
//           AnimatedContainer(
//             duration: const Duration(milliseconds: 300),
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: _isListening
//                   ? Colors.greenAccent.withOpacity(0.2)
//                   : _isProcessing
//                       ? Colors.orangeAccent.withOpacity(0.2)
//                       : Colors.blueGrey.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Column(
//               children: [
//                 Text(
//                   _status,
//                   style: const TextStyle(
//                       fontSize: 16, fontWeight: FontWeight.w600),
//                 ),
//                 const SizedBox(height: 5),
//                 Text(
//                   _subStatus,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(fontSize: 14, color: Colors.black54),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 15),

//           // 👂 Display recognized text live
//           if (_spokenText.isNotEmpty)
//             Text(
//               "You said:\n$_spokenText",
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 16,
//                 color: _isListening ? Colors.green : Colors.black87,
//                 fontStyle: FontStyle.italic,
//               ),
//             )
//           else
//             const Text(
//               "Say something like: ‘Book my appointment at 3 PM tomorrow’",
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 15, color: Colors.black54),
//             ),

//           const SizedBox(height: 25),

//           // 🎤 Mic button
//           GestureDetector(
//             onTap: _isListening ? _stopListening : _startListening,
//             child: ScaleTransition(
//               scale: Tween(begin: 1.0, end: 1.2).animate(CurvedAnimation(
//                 parent: _animCtrl,
//                 curve: Curves.easeInOut,
//               )),
//               child: CircleAvatar(
//                 radius: 45,
//                 backgroundColor:
//                     _isListening ? Colors.redAccent : themeColor,
//                 child: Icon(
//                   _isListening ? Icons.stop_rounded : Icons.mic_rounded,
//                   size: 42,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),

//           const SizedBox(height: 20),

//           // 🔁 Show backend result or loader
//           if (_isProcessing)
//             const Column(
//               children: [
//                 CircularProgressIndicator(),
//                 SizedBox(height: 8),
//                 Text("Processing your request...",
//                     style: TextStyle(fontSize: 15)),
//               ],
//             )
//           else if (_resultText != null)
//             Container(
//               margin: const EdgeInsets.only(top: 12),
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.teal.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Text(
//                 "🕒 Extracted Slot:\n$_resultText",
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'dart:async';

// class VoiceBookingWidget extends StatefulWidget {
//   const VoiceBookingWidget({Key? key}) : super(key: key);

//   @override
//   _VoiceBookingWidgetState createState() => _VoiceBookingWidgetState();
// }

// class _VoiceBookingWidgetState extends State<VoiceBookingWidget>
//     with SingleTickerProviderStateMixin {
//   late stt.SpeechToText _speech;
//   bool _isListening = false;
//   bool _isProcessing = false;

//   String _spokenText = "";
//   String? _resultText;
//   String _status = "Idle 🕓";
//   String _subStatus = "Tap the mic to start speaking";

//   late AnimationController _animCtrl;

//   @override
//   void initState() {
//     super.initState();
//     print("DEBUG: initState() called");

//     try {
//       _speech = stt.SpeechToText();
//       print("DEBUG: SpeechToText initialized");
//     } catch (e) {
//       print("DEBUG: SpeechToText init error: $e");
//       _updateStatus("❌ Error initializing speech", e.toString());
//     }

//     _animCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 700),
//     );
//   }

//   void _updateStatus(String main, [String? sub]) {
//     setState(() {
//       _status = main;
//       if (sub != null) _subStatus = sub;
//     });
//   }

//   @override
//   void dispose() {
//     print("DEBUG: dispose() called");
//     _animCtrl.dispose();
//     super.dispose();
//   }

//   // 🚀 START LISTENING
//   Future<void> _startListening() async {
//     print("DEBUG: _startListening() called");

//     try {
//       bool available = await _speech.initialize();
//       print("DEBUG: Speech available = $available");

//       if (!available) {
//         _updateStatus("⚠️ Mic unavailable", "Speech recognition not ready");
//         print("DEBUG: Mic unavailable");
//         return;
//       }

//       _updateStatus("🎤 Listening...", "Speak your appointment request");
//       setState(() {
//         _isListening = true;
//         _spokenText = "";
//         _resultText = null;
//       });

//       _animCtrl.repeat(reverse: true);

//       print("DEBUG: Starting _speech.listen()");
//       _speech.listen(
//         onResult: (val) {
//           print("DEBUG: onResult called");
//           print("DEBUG: recognizedWords = ${val.recognizedWords}");
//           print("DEBUG: finalResult = ${val.finalResult}");

//           setState(() {
//             _spokenText = val.recognizedWords;
//           });

//           if (val.finalResult) {
//             print("DEBUG: finalResult detected → stopping...");
//             _stopListening(sendImmediately: true);
//           }
//         },
//       );
//     } catch (e) {
//       print("DEBUG: Error in _startListening: $e");
//       _updateStatus("❌ Listening error", e.toString());
//     }
//   }

//   // 🚀 STOP LISTENING
//   Future<void> _stopListening({bool sendImmediately = false}) async {
//     print("DEBUG: _stopListening() called -> sendImmediately=$sendImmediately");

//     try {
//       await _speech.stop();
//       print("DEBUG: speech.stop() completed");
//     } catch (e) {
//       print("DEBUG: error in stop(): $e");
//     }

//     _animCtrl.stop();
//     setState(() => _isListening = false);
//     _updateStatus("🛑 Done listening", "Preparing to send to backend...");

//     print("DEBUG: Final spokenText = $_spokenText");

//     if (sendImmediately && _spokenText.isNotEmpty) {
//       print("DEBUG: Calling _sendToBackend()");
//       await _sendToBackend();
//     } else {
//       print("DEBUG: NOT sending to backend (empty or not final)");
//     }
//   }

//   // 🚀 SEND TO BACKEND
//   Future<void> _sendToBackend() async {
//     print("DEBUG: _sendToBackend() CALLED");
//     print("DEBUG: Sending text = $_spokenText");

//     setState(() => _isProcessing = true);
//     _updateStatus("🌐 Sending to backend", "Please wait...");

//     try {
//       final url = Uri.parse('http://10.0.2.2:8000/book_appointment');
//       print("DEBUG: Backend URL = $url");

//       final body = json.encode({"input": _spokenText});
//       print("DEBUG: Request Body = $body");

//       final response = await http
//           .post(url, headers: {'Content-Type': 'application/json'}, body: body)
//           .timeout(const Duration(seconds: 10));

//       print("DEBUG: Response status = ${response.statusCode}");
//       print("DEBUG: Response body = ${response.body}");

//       _updateStatus("📩 Response Received",
//           "Status: ${response.statusCode}\n${response.body}");

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);

//         setState(() {
//           _resultText = data["extracted_time"] ?? "No extracted time";
//         });

//         _updateStatus("✅ Success", "Backend processed successfully!");
//       } else {
//         _resultText = "Server Error: ${response.body}";
//         _updateStatus("❌ Server Error", response.body);
//       }
//     } on TimeoutException {
//       print("DEBUG: TIMEOUT while calling backend");
//       _updateStatus("⏳ Timeout", "Backend did not respond");
//       _resultText = "Timeout — backend unreachable.";
//     } catch (e) {
//       print("DEBUG: Exception while calling backend: $e");
//       _updateStatus("⚠️ Connection Error", e.toString());
//       _resultText = "Failed to connect:\n$e";
//     } finally {
//       setState(() => _isProcessing = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final themeColor = Colors.teal;

//     return Container(
//       width: double.infinity,
//       margin: const EdgeInsets.symmetric(vertical: 16),
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.shade300,
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           const Text(
//             "🎙️ Voice Appointment Assistant",
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 10),

//           // STATUS PANEL
//           AnimatedContainer(
//             duration: const Duration(milliseconds: 300),
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: _isListening
//                   ? Colors.greenAccent.withOpacity(0.2)
//                   : _isProcessing
//                       ? Colors.orangeAccent.withOpacity(0.2)
//                       : Colors.blueGrey.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Column(
//               children: [
//                 Text(_status,
//                     style: const TextStyle(
//                         fontSize: 16, fontWeight: FontWeight.w600)),
//                 const SizedBox(height: 5),
//                 Text(_subStatus,
//                     style:
//                         const TextStyle(fontSize: 14, color: Colors.black54)),
//               ],
//             ),
//           ),
//           const SizedBox(height: 15),

//           // TEXT THAT USER SPOKE
//           if (_spokenText.isNotEmpty)
//             Text(
//               "You said:\n$_spokenText",
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 16,
//                 color: _isListening ? Colors.green : Colors.black87,
//                 fontStyle: FontStyle.italic,
//               ),
//             )
//           else
//             const Text(
//               "Say: ‘Book my appointment at 3 PM tomorrow’",
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 15, color: Colors.black54),
//             ),

//           const SizedBox(height: 25),

//           // MIC BUTTON
//           GestureDetector(
//             onTap: _isListening ? _stopListening : _startListening,
//             child: ScaleTransition(
//               scale: Tween(begin: 1.0, end: 1.2).animate(CurvedAnimation(
//                 parent: _animCtrl,
//                 curve: Curves.easeInOut,
//               )),
//               child: CircleAvatar(
//                 radius: 45,
//                 backgroundColor:
//                     _isListening ? Colors.redAccent : themeColor,
//                 child: Icon(
//                   _isListening ? Icons.stop_rounded : Icons.mic_rounded,
//                   size: 42,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),

//           const SizedBox(height: 20),

//           // RESULT BOX
//           if (_isProcessing)
//             const Column(
//               children: [
//                 CircularProgressIndicator(),
//                 SizedBox(height: 8),
//                 Text("Processing your request...",
//                     style: TextStyle(fontSize: 15)),
//               ],
//             )
//           else if (_resultText != null)
//             Container(
//               margin: const EdgeInsets.only(top: 12),
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.teal.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Text(
//                 "🕒 Extracted Slot:\n$_resultText",
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'dart:async';

// class VoiceBookingWidget extends StatefulWidget {
//   const VoiceBookingWidget({Key? key}) : super(key: key);

//   @override
//   _VoiceBookingWidgetState createState() => _VoiceBookingWidgetState();
// }

// class _VoiceBookingWidgetState extends State<VoiceBookingWidget>
//     with SingleTickerProviderStateMixin {
//   late stt.SpeechToText _speech;
//   bool _isListening = false;
//   bool _isProcessing = false;

//   String _spokenText = "";
//   String? _resultText;
//   String _status = "Idle 🕓";
//   String _subStatus = "Tap the mic to start speaking";

//   late AnimationController _animCtrl;

//   @override
//   void initState() {
//     super.initState();
//     print("DEBUG: initState() called");

//     try {
//       _speech = stt.SpeechToText();
//       print("DEBUG: SpeechToText initialized");
//     } catch (e) {
//       print("DEBUG: SpeechToText init error: $e");
//       _updateStatus("❌ Error initializing speech", e.toString());
//     }

//     _animCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 700),
//     );
//   }

//   void _updateStatus(String main, [String? sub]) {
//     setState(() {
//       _status = main;
//       if (sub != null) _subStatus = sub;
//     });
//   }

//   @override
//   void dispose() {
//     print("DEBUG: dispose() called");
//     _animCtrl.dispose();
//     super.dispose();
//   }

//   // 🚀 START LISTENING
//   Future<void> _startListening() async {
//     print("DEBUG: _startListening() called");

//     try {
//       bool available = await _speech.initialize();
//       print("DEBUG: Speech available = $available");

//       if (!available) {
//         _updateStatus("⚠️ Mic unavailable", "Speech recognition not ready");
//         print("DEBUG: Mic unavailable");
//         return;
//       }

//       _updateStatus("🎤 Listening...", "Speak your appointment request");
//       setState(() {
//         _isListening = true;
//         _spokenText = "";
//         _resultText = null;
//       });

//       _animCtrl.repeat(reverse: true);

//       print("DEBUG: Starting _speech.listen()");
//       _speech.listen(
//         onResult: (val) {
//           print("DEBUG: onResult called");
//           print("DEBUG: recognizedWords = ${val.recognizedWords}");
//           print("DEBUG: finalResult = ${val.finalResult}");

//           setState(() {
//             _spokenText = val.recognizedWords;
//           });

//           if (val.finalResult) {
//             print("DEBUG: finalResult detected → stopping...");
//             _stopListening(sendImmediately: true);
//           }
//         },
//       );
//     } catch (e) {
//       print("DEBUG: Error in _startListening: $e");
//       _updateStatus("❌ Listening error", e.toString());
//     }
//   }

//   // 🚀 STOP LISTENING
//   Future<void> _stopListening({bool sendImmediately = false}) async {
//     print("DEBUG: _stopListening() called -> sendImmediately=$sendImmediately");

//     try {
//       await _speech.stop();
//       print("DEBUG: speech.stop() completed");
//     } catch (e) {
//       print("DEBUG: error in stop(): $e");
//     }

//     _animCtrl.stop();
//     setState(() => _isListening = false);

//     // Clean UI message
//     _updateStatus("🛑 Done listening", "Processing your voice...");

//     print("DEBUG: Final spokenText = $_spokenText");

//     if (sendImmediately && _spokenText.isNotEmpty) {
//       print("DEBUG: Calling _sendToBackend()");
//       await _sendToBackend();
//     } else {
//       print("DEBUG: NOT sending to backend (empty or not final)");
//       _updateStatus("Idle 🕓", "Tap the mic to start speaking");
//     }
//   }

//   // 🚀 SEND TO BACKEND
//   Future<void> _sendToBackend() async {
//     print("DEBUG: _sendToBackend() CALLED");
//     print("DEBUG: Sending text = $_spokenText");

//     setState(() => _isProcessing = true);
//     _updateStatus("🌐 Sending to backend", "Please wait...");

//     try {
//       final url = Uri.parse('http://10.0.2.2:8000/book_appointment');
//       print("DEBUG: Backend URL = $url");

//       final body = json.encode({"input": _spokenText});
//       print("DEBUG: Request Body = $body");

//       final response = await http
//           .post(url, headers: {'Content-Type': 'application/json'}, body: body)
//           .timeout(const Duration(seconds: 10));

//       print("DEBUG: Response status = ${response.statusCode}");
//       print("DEBUG: Response body = ${response.body}");

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);

//         setState(() {
//           _resultText = data["extracted_time"] ?? "No extracted time";
//         });

//         _updateStatus("✅ Success", "Backend processed successfully!");
//       } else {
//         print("DEBUG: SERVER ERROR");
//         _updateStatus("❌ Server Error", response.body);
//         _resultText = "Server Error: ${response.body}";

//         _updateStatus("Idle 🕓", "Tap the mic to try again");
//       }
//     } on TimeoutException {
//       print("DEBUG: TIMEOUT while calling backend");

//       _updateStatus("⏳ Timeout", "Backend did not respond");
//       _resultText = "Timeout — backend unreachable.";

//       _updateStatus("Idle 🕓", "Tap the mic to try again");
//     } catch (e) {
//       print("DEBUG: Exception: $e");

//       _updateStatus("⚠️ Connection Error", e.toString());
//       _resultText = "Failed to connect:\n$e";

//       _updateStatus("Idle 🕓", "Tap the mic to try again");
//     } finally {
//       setState(() => _isProcessing = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final themeColor = Colors.teal;

//     return Container(
//       width: double.infinity,
//       margin: const EdgeInsets.symmetric(vertical: 16),
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.shade300,
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           const Text(
//             "🎙️ Voice Appointment Assistant",
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 10),
//           AnimatedContainer(
//             duration: const Duration(milliseconds: 300),
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: _isListening
//                   ? Colors.greenAccent.withOpacity(0.2)
//                   : _isProcessing
//                       ? Colors.orangeAccent.withOpacity(0.2)
//                       : Colors.blueGrey.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Column(
//               children: [
//                 Text(_status,
//                     style: const TextStyle(
//                         fontSize: 16, fontWeight: FontWeight.w600)),
//                 const SizedBox(height: 5),
//                 Text(_subStatus,
//                     textAlign: TextAlign.center,
//                     style:
//                         const TextStyle(fontSize: 14, color: Colors.black54)),
//               ],
//             ),
//           ),
//           const SizedBox(height: 15),
//           if (_spokenText.isNotEmpty)
//             Text(
//               "You said:\n$_spokenText",
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 16,
//                 color: _isListening ? Colors.green : Colors.black87,
//                 fontStyle: FontStyle.italic,
//               ),
//             )
//           else
//             const Text(
//               "Say: ‘Book my appointment at 3 PM tomorrow’",
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 15, color: Colors.black54),
//             ),
//           const SizedBox(height: 25),
//           GestureDetector(
//             onTap: _isListening ? _stopListening : _startListening,
//             child: ScaleTransition(
//               scale: Tween(begin: 1.0, end: 1.2).animate(CurvedAnimation(
//                 parent: _animCtrl,
//                 curve: Curves.easeInOut,
//               )),
//               child: CircleAvatar(
//                 radius: 45,
//                 backgroundColor: _isListening ? Colors.redAccent : themeColor,
//                 child: Icon(
//                   _isListening ? Icons.stop_rounded : Icons.mic_rounded,
//                   size: 42,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),
//           if (_isProcessing)
//             const Column(
//               children: [
//                 CircularProgressIndicator(),
//                 SizedBox(height: 8),
//                 Text("Processing your request...",
//                     style: TextStyle(fontSize: 15)),
//               ],
//             )
//           else if (_resultText != null)
//             Container(
//               margin: const EdgeInsets.only(top: 12),
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.teal.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Text(
//                 "🕒 Extracted Slot:\n$_resultText",
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:intl/intl.dart';
// import 'dart:convert';

// //////////////////////////////////////////////////////////////////////////////
// // 🔹 MONTH MAP FOR EASY DATE PARSING
// //////////////////////////////////////////////////////////////////////////////

// const Map<String, int> _monthMap = {
//   "january": 1, "jan": 1,
//   "february": 2, "feb": 2,
//   "march": 3, "mar": 3,
//   "april": 4, "apr": 4,
//   "may": 5,
//   "june": 6, "jun": 6,
//   "july": 7, "jul": 7,
//   "august": 8, "aug": 8,
//   "september": 9, "sept": 9, "sep": 9,
//   "october": 10, "oct": 10,
//   "november": 11, "nov": 11,
//   "december": 12, "dec": 12,
// };

// //////////////////////////////////////////////////////////////////////////////
// // 🔹 TIME EXTRACTION
// //////////////////////////////////////////////////////////////////////////////

// String? extractTime(String text) {
//   // Normalise weird AM/PM variants to simple am/pm
//   String t = text.toLowerCase();
//   t = t
//       .replaceAll("a.m.", "am")
//       .replaceAll("a. m.", "am")
//       .replaceAll("a m", "am")
//       .replaceAll("p.m.", "pm")
//       .replaceAll("p. m.", "pm")
//       .replaceAll("p m", "pm");

//   final RegExp timeRegex =
//       RegExp(r'\b\d{1,2}(:\d{2})?\s*(am|pm)\b', caseSensitive: false);

//   final match = timeRegex.firstMatch(t);
//   if (match == null) return null;

//   String result = match.group(0)!.trim().toUpperCase(); // "3 PM" | "3:00 PM"
//   return result;
// }

// //////////////////////////////////////////////////////////////////////////////
// // 🔹 DATE EXTRACTION
// //////////////////////////////////////////////////////////////////////////////

// String? extractDate(String text) {
//   String t = text.toLowerCase().replaceAll(",", "").trim();
//   final DateTime now = DateTime.now();

//   // Relative dates
//   if (t.contains("today")) {
//     return DateFormat("yyyy-MM-dd").format(now);
//   }
//   if (t.contains("tomorrow")) {
//     return DateFormat("yyyy-MM-dd").format(now.add(const Duration(days: 1)));
//   }

//   // Pattern 1: "29 november 2025" or "29 nov 2025" or without year
//   final RegExp dayMonthYear = RegExp(
//     r'\b(\d{1,2})\s+([a-z]+)\s*(\d{2,4})?\b',
//   );

//   final match1 = dayMonthYear.firstMatch(t);
//   if (match1 != null) {
//     final String dayStr = match1.group(1)!;
//     final String monthStr = match1.group(2)!;
//     String? yearStr = match1.group(3);

//     int? month = _monthMap[monthStr];
//     if (month == null && monthStr.length > 3) {
//       month = _monthMap[monthStr.substring(0, 3)];
//     }

//     if (month != null) {
//       final int day = int.tryParse(dayStr) ?? now.day;
//       int year;
//       if (yearStr == null) {
//         year = now.year;
//       } else {
//         year = int.tryParse(yearStr) ?? now.year;
//         if (year < 100) {
//           // Treat "25" as 2025 for example
//           year += 2000;
//         }
//       }

//       final DateTime parsed = DateTime(year, month, day);
//       return DateFormat("yyyy-MM-dd").format(parsed);
//     }
//   }

//   // Pattern 2: Numeric dates "29/11/2025" or "29-11-25"
//   final RegExp numeric = RegExp(r'\b(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{2,4})\b');
//   final match2 = numeric.firstMatch(t);
//   if (match2 != null) {
//     final int day = int.parse(match2.group(1)!);
//     final int month = int.parse(match2.group(2)!);
//     int year = int.parse(match2.group(3)!);
//     if (year < 100) year += 2000;

//     final DateTime parsed = DateTime(year, month, day);
//     return DateFormat("yyyy-MM-dd").format(parsed);
//   }

//   return null;
// }

// //////////////////////////////////////////////////////////////////////////////
// // 🎙 MAIN WIDGET
// //////////////////////////////////////////////////////////////////////////////

// class VoiceBookingWidget extends StatefulWidget {
//   const VoiceBookingWidget({Key? key}) : super(key: key);

//   @override
//   State<VoiceBookingWidget> createState() => _VoiceBookingWidgetState();
// }

// class _VoiceBookingWidgetState extends State<VoiceBookingWidget>
//     with SingleTickerProviderStateMixin {
//   late stt.SpeechToText _speech;
//   late AnimationController _anim;

//   bool _isListening = false;
//   bool _isProcessing = false;

//   String _liveSpeech = "";
//   String _jsonResult = "";

//   @override
//   void initState() {
//     super.initState();
//     _speech = stt.SpeechToText();
//     _anim = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 600),
//     );
//   }

//   @override
//   void dispose() {
//     _anim.dispose();
//     super.dispose();
//   }

//   ////////////////////////////////////////////////////////////////////////////
//   // 🎧 START LISTENING
//   ////////////////////////////////////////////////////////////////////////////

//   Future<void> _startListening() async {
//     final bool available = await _speech.initialize();
//     if (!available) return;

//     setState(() {
//       _isListening = true;
//       _liveSpeech = "";
//       _jsonResult = "";
//     });

//     _anim.repeat(reverse: true);

//     _speech.listen(
//       onResult: (res) {
//         setState(() {
//           _liveSpeech = res.recognizedWords;
//         });

//         if (res.finalResult) {
//           _stopListening();
//         }
//       },
//     );
//   }

//   ////////////////////////////////////////////////////////////////////////////
//   // 🛑 STOP LISTENING & PROCESS
//   ////////////////////////////////////////////////////////////////////////////

//   Future<void> _stopListening() async {
//     await _speech.stop();
//     _anim.stop();

//     setState(() {
//       _isListening = false;
//       _isProcessing = true;
//     });

//     // Small delay just so UI can update smoothly
//     Future.delayed(const Duration(milliseconds: 150), _processSpeech);
//   }

//   void _processSpeech() {
//     final String? date = extractDate(_liveSpeech);
//     final String? time = extractTime(_liveSpeech);

//     final Map<String, dynamic> data = {
//       "date": date,
//       "time": time,
//     };

//     setState(() {
//       _jsonResult = jsonEncode(data);
//       _isProcessing = false;
//     });

//     // Debug log
//     print("🎯 Extracted from speech: $_liveSpeech");
//     print("📦 JSON: $_jsonResult");
//   }

//   ////////////////////////////////////////////////////////////////////////////
//   // 🖼️ UI
//   ////////////////////////////////////////////////////////////////////////////

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: [
//           BoxShadow(color: Colors.grey.shade300, blurRadius: 10),
//         ],
//       ),
//       child: Column(
//         children: [
//           const Text(
//             "🎙 Voice Appointment Assistant",
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 12),

//           const Text("Live Speech:",
//               style: TextStyle(fontWeight: FontWeight.bold)),
//           Container(
//             margin: const EdgeInsets.only(top: 8),
//             padding: const EdgeInsets.all(10),
//             width: double.infinity,
//             decoration: BoxDecoration(
//               color: Colors.blue.shade50,
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Text(
//               _liveSpeech.isEmpty ? "Start speaking..." : _liveSpeech,
//               style: const TextStyle(fontSize: 16),
//             ),
//           ),

//           const SizedBox(height: 20),

//           GestureDetector(
//             onTap: _isListening ? _stopListening : _startListening,
//             child: CircleAvatar(
//               radius: 45,
//               backgroundColor: _isListening ? Colors.red : Colors.teal,
//               child: Icon(
//                 _isListening ? Icons.stop : Icons.mic,
//                 size: 42,
//                 color: Colors.white,
//               ),
//             ),
//           ),

//           const SizedBox(height: 20),

//           if (_isProcessing) ...[
//             const CircularProgressIndicator(),
//             const SizedBox(height: 8),
//             const Text("Extracting date & time..."),
//           ],

//           if (_jsonResult.isNotEmpty)
//             Container(
//               margin: const EdgeInsets.only(top: 12),
//               padding: const EdgeInsets.all(14),
//               decoration: BoxDecoration(
//                 color: Colors.green.shade50,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Text(
//                 "📦 Extracted JSON:\n$_jsonResult",
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                     fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:intl/intl.dart';
// import 'dart:convert';

// //////////////////////////////////////////////////////////////////////////////
// // 🧠 DATE + TIME EXTRACTION ENGINE
// //////////////////////////////////////////////////////////////////////////////

// Map<String, int> months = {
//   "january": 1, "jan": 1,
//   "february": 2, "feb": 2,
//   "march": 3, "mar": 3,
//   "april": 4, "apr": 4,
//   "may": 5,
//   "june": 6, "jun": 6,
//   "july": 7, "jul": 7,
//   "august": 8, "aug": 8,
//   "september": 9, "sept": 9, "sep": 9,
//   "october": 10, "oct": 10,
//   "november": 11, "nov": 11,
//   "december": 12, "dec": 12,
// };

// String? extractTime(String text) {
//   text = text.toLowerCase()
//       .replaceAll("a.m.", "am")
//       .replaceAll("p.m.", "pm")
//       .replaceAll("a. m.", "am")
//       .replaceAll("p. m.", "pm")
//       .replaceAll("a m", "am")
//       .replaceAll("p m", "pm");

//   final m = RegExp(r'\b\d{1,2}(:\d{2})?\s*(am|pm)\b').firstMatch(text);
//   return m != null ? m.group(0)!.toUpperCase() : null;
// }

// String? extractDate(String text) {
//   text = text.toLowerCase().replaceAll(",", "").trim();
//   DateTime now = DateTime.now();

//   if (text.contains("today")) return DateFormat("yyyy-MM-dd").format(now);
//   if (text.contains("tomorrow")) return DateFormat("yyyy-MM-dd").format(now.add(Duration(days: 1)));

//   final m1 = RegExp(r'\b(\d{1,2})\s+([a-z]+)\s*(\d{2,4})?\b').firstMatch(text);
//   if (m1 != null) {
//     int day = int.parse(m1.group(1)!);
//     String monthWord = m1.group(2)!;
//     int year = m1.group(3) != null ? int.parse(m1.group(3)!) : now.year;

//     int? month = months[monthWord] ?? months[monthWord.substring(0, 3)];
//     if (month != null) return DateFormat("yyyy-MM-dd").format(DateTime(year, month, day));
//   }

//   final m2 = RegExp(r'\b(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{2,4})\b').firstMatch(text);
//   if (m2 != null) {
//     int d = int.parse(m2.group(1)!);
//     int m = int.parse(m2.group(2)!);
//     int y = int.parse(m2.group(3)!);
//     if (y < 100) y += 2000;
//     return DateFormat("yyyy-MM-dd").format(DateTime(y, m, d));
//   }

//   return null;
// }

// //////////////////////////////////////////////////////////////////////////////

// class VoiceBookingWidget extends StatefulWidget {
//   final Function(String? date, String? time)? onExtracted; // Added callback

//   const VoiceBookingWidget({Key? key, this.onExtracted}) : super(key: key);

//   @override
//   State<VoiceBookingWidget> createState() => _VoiceBookingWidgetState();
// }

// class _VoiceBookingWidgetState extends State<VoiceBookingWidget> {
//   late stt.SpeechToText speech;
//   String spokenLive = "";
//   String extractedJson = "";
//   bool listening = false;
//   bool processing = false;

//   @override
//   void initState() {
//     super.initState();
//     speech = stt.SpeechToText();
//   }

//   void startListen() async {
//     bool ok = await speech.initialize();
//     if (!ok) return;

//     setState(() {
//       listening = true;
//       spokenLive = "";
//       extractedJson = "";
//     });

//     speech.listen(onResult: (r) {
//       setState(() => spokenLive = r.recognizedWords);

//       if (r.finalResult) stopListen();
//     });
//   }

//   void stopListen() async {
//     speech.stop();
//     setState(() => listening = false);
//     Future.delayed(Duration(milliseconds: 300), processSpeech);
//   }

//   void processSpeech() {
//     setState(() => processing = true);

//     String? date = extractDate(spokenLive);
//     String? time = extractTime(spokenLive);

//     extractedJson = jsonEncode({"date": date, "time": time});
//     processing = false;

//     widget.onExtracted?.call(date, time); // 🔥 SEND to appointment page

//     setState(() {});
//   }

//   @override
//   Widget build(context) {
//     return Column(children: [
//       Text("🎙 Voice Input:", style: TextStyle(fontWeight: FontWeight.bold)),
//       Container(
//         padding: EdgeInsets.all(10),
//         width: double.infinity,
//         decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)),
//         child: Text(spokenLive.isEmpty ? "Say something..." : spokenLive),
//       ),
//       SizedBox(height: 10),

//       GestureDetector(
//         onTap: listening ? stopListen : startListen,
//         child: CircleAvatar(
//           radius: 40,
//           backgroundColor: listening ? Colors.red : Colors.green,
//           child: Icon(listening ? Icons.stop : Icons.mic, color: Colors.white, size: 35),
//         ),
//       ),

//       if (extractedJson.isNotEmpty) ...[
//         SizedBox(height: 12),
//         Text("📦 Extracted JSON:\n$extractedJson", textAlign: TextAlign.center),
//       ]
//     ]);
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:intl/intl.dart';
// import 'dart:convert';

// /// MONTH MAP FOR VOICE DATE EXTRACTION
// Map<String, int> months = {
//   "january": 1,"jan": 1,"february": 2,"feb": 2,"march": 3,"mar": 3,
//   "april": 4,"apr": 4,"may": 5,"june": 6,"jun": 6,"july": 7,"jul": 7,
//   "august": 8,"aug": 8,"september": 9,"sept": 9,"sep": 9,
//   "october": 10,"oct": 10,"november": 11,"nov": 11,"december": 12,"dec": 12,
// };

// /// TIME EXTRACTION
// String? extractTime(String text) {
//   text = text.toLowerCase()
//       .replaceAll("a.m.", "am").replaceAll("p.m.", "pm")
//       .replaceAll("a m", "am").replaceAll("p m", "pm");

//   final m = RegExp(r'\b\d{1,2}(:\d{2})?\s*(am|pm)\b').firstMatch(text);
//   return m != null ? m.group(0)!.toUpperCase() : null;
// }

// /// DATE EXTRACTION
// String? extractDate(String text) {
//   text = text.toLowerCase().replaceAll(",", "");
//   final now = DateTime.now();

//   if(text.contains("today")) return DateFormat("yyyy-MM-dd").format(now);
//   if(text.contains("tomorrow")) return DateFormat("yyyy-MM-dd").format(now.add(Duration(days:1)));

//   final m1 = RegExp(r'(\d{1,2})\s+([a-z]+)\s*(\d{2,4})?').firstMatch(text);
//   if(m1 != null){
//     int d = int.parse(m1.group(1)!);
//     String monString = m1.group(2)!;
//     int y = m1.group(3) != null ? int.parse(m1.group(3)!) : now.year;
//     int? m = months[monString] ?? months[monString.substring(0,3)];
//     if(m != null) return "$y-${m.toString().padLeft(2,'0')}-${d.toString().padLeft(2,'0')}";
//   }

//   final m2 = RegExp(r'(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{2,4})').firstMatch(text);
//   if(m2 != null){
//     int d = int.parse(m2.group(1)!);
//     int m = int.parse(m2.group(2)!);
//     int y = int.parse(m2.group(3)!);
//     if(y < 100) y+=2000;
//     return "$y-${m.toString().padLeft(2,'0')}-${d.toString().padLeft(2,'0')}";
//   }

//   return null;
// }


// //////////////////////// UI WIDGET ////////////////////////////

// class VoiceBookingWidget extends StatefulWidget {
//   final Function(String? date, String? time)? onExtracted;
//   const VoiceBookingWidget({super.key, this.onExtracted});

//   @override
//   State<VoiceBookingWidget> createState() => _VoiceBookingWidgetState();
// }

// class _VoiceBookingWidgetState extends State<VoiceBookingWidget> {
//   late stt.SpeechToText speech;
//   bool listening = false;
//   String textPreview="", jsonResult="";

//   @override
//   void initState(){
//     speech=stt.SpeechToText();
//     super.initState();
//   }

//   void start() async {
//     if(!await speech.initialize()) return;
//     setState(()=>listening=true);
//     speech.listen(onResult:(r){
//       setState(()=>textPreview=r.recognizedWords);
//       if(r.finalResult) stop();
//     });
//   }

//   void stop(){
//     speech.stop();
//     setState(()=>listening=false);
//     Future.delayed(Duration(milliseconds:200), _process);
//   }

//   void _process(){
//     String? d=extractDate(textPreview);
//     String? t=extractTime(textPreview);

//     jsonResult=jsonEncode({"date":d,"time":t});
//     widget.onExtracted?.call(d,t);

//     print("\n🎤 RAW = $textPreview");
//     print("📅 DATE = $d");
//     print("⏰ TIME = $t\n");

//     setState((){});
//   }

//   @override
//   Widget build(context){
//     return Column(
//       children:[
//         Text("🎙 Speak Appointment:",style:TextStyle(fontWeight:FontWeight.bold)),
//         Container(
//           padding:EdgeInsets.all(10),
//           width:double.infinity,
//           decoration:BoxDecoration(color:Colors.blue.shade50,borderRadius:BorderRadius.circular(10)),
//           child:Text(textPreview.isEmpty?"Tap & Speak...":textPreview),
//         ),

//         SizedBox(height:10),
//         GestureDetector(
//           onTap: listening?stop:start,
//           child: CircleAvatar(
//             radius:40,
//             backgroundColor:listening?Colors.red:Colors.teal,
//             child:Icon(listening?Icons.stop:Icons.mic,size:36,color:Colors.white),
//           ),
//         ),

//         if(jsonResult.isNotEmpty)...[
//           SizedBox(height:10),
//           Text("📦 Extracted → $jsonResult",textAlign:TextAlign.center)
//         ],
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:intl/intl.dart';

/// MONTH MAP FOR VOICE DATE EXTRACTION
Map<String, int> months = {
  "january":1,"jan":1,"february":2,"feb":2,"march":3,"mar":3,
  "april":4,"apr":4,"may":5,"june":6,"jun":6,"july":7,"jul":7,
  "august":8,"aug":8,"september":9,"sept":9,"sep":9,
  "october":10,"oct":10,"november":11,"nov":11,"december":12,"dec":12,
};

/// TIME EXTRACTION
String? extractTime(String text){
  text=text.toLowerCase()
    .replaceAll("a.m.","am").replaceAll("p.m.","pm")
    .replaceAll("a m","am").replaceAll("p m","pm");

  final m=RegExp(r'\b\d{1,2}(:\d{2})?\s*(am|pm)\b').firstMatch(text);
  return m?.group(0)!.toUpperCase();
}

/// DATE EXTRACTION
String? extractDate(String text){
  text=text.toLowerCase().replaceAll(",","");
  final now=DateTime.now();

  if(text.contains("today")) return DateFormat("yyyy-MM-dd").format(now);
  if(text.contains("tomorrow")) return DateFormat("yyyy-MM-dd").format(now.add(Duration(days:1)));

  final m1=RegExp(r'(\d{1,2})\s+([a-z]+)\s*(\d{2,4})?').firstMatch(text);
  if(m1!=null){
    int d=int.parse(m1.group(1)!);
    String mon=m1.group(2)!;
    int y=m1.group(3)!=null?int.parse(m1.group(3)!):now.year;
    if(y<100)y+=2000; if(y<1000)y+=2000;
    int? m=months[mon]??months[mon.substring(0,3)];
    if(m!=null) return "$y-${m.toString().padLeft(2,'0')}-${d.toString().padLeft(2,'0')}";
  }

  return null;
}

/// UI WIDGET /////////////////////////////////////////////////

class VoiceBookingWidget extends StatefulWidget {
  final Function(String? date,String? time)? onExtracted;
  const VoiceBookingWidget({super.key,this.onExtracted});

  @override State<VoiceBookingWidget> createState()=>_VoiceBookingWidgetState();
}

class _VoiceBookingWidgetState extends State<VoiceBookingWidget>{
  late stt.SpeechToText speech;
  bool listening=false;
  String preview="", result="";

  @override void initState(){speech=stt.SpeechToText();super.initState();}

  void start() async {
    if(!await speech.initialize())return;
    setState(()=>listening=true);
    speech.listen(onResult:(r){
      setState(()=>preview=r.recognizedWords);
      if(r.finalResult)stop();
    });
  }

  void stop(){
    speech.stop(); setState(()=>listening=false);
    Future.delayed(Duration(milliseconds:200), process);
  }

  void process(){
    String? d=extractDate(preview);
    String? t=extractTime(preview);
    result="DATE=$d | TIME=$t";

    widget.onExtracted?.call(d,t);
    setState((){}); 
  }

  @override Widget build(context){
    return Column(children:[

      Text("🎙 Speak Appointment:",style:TextStyle(fontWeight:FontWeight.bold)),

      Container(
        padding:EdgeInsets.all(10),width:double.infinity,
        decoration:BoxDecoration(color:Colors.blue.shade50,borderRadius:BorderRadius.circular(10)),
        child:Text(preview.isEmpty?"Tap Mic & Speak":preview),
      ),
      SizedBox(height:10),

      GestureDetector(
        onTap:listening?stop:start,
        child:CircleAvatar(
          radius:40,
          backgroundColor:listening?Colors.red:Colors.teal,
          child:Icon(listening?Icons.stop:Icons.mic,size:35,color:Colors.white),
        )),

      if(result.isNotEmpty)...[
        SizedBox(height:10),
        Text("📦 Extracted → $result",textAlign:TextAlign.center),
      ]

    ]);
  }
}

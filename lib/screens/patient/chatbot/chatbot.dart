// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class ChatbotScreen extends StatefulWidget {
//   const ChatbotScreen({super.key});

//   @override
//   State<ChatbotScreen> createState() => _ChatbotScreenState();
// }

// class _ChatbotScreenState extends State<ChatbotScreen> {
//   final TextEditingController _controller = TextEditingController();
//   final List<_ChatMessage> _messages = [];
//   bool _isLoading = false;

//   Future<String> _fetchResponse(String userMessage) async {
//     final url = Uri.parse('https://chatbot.sugarsangini.in/api/chat');
//     try {
//       final response = await http.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'message': userMessage}),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         // Adjust this depending on the exact API response structure
//         return data['response'] ?? 'Sorry, no response available.';
//       } else {
//         return 'Failed to get response from server.';
//       }
//     } catch (e) {
//       return 'Error: Unable to contact server.';
//     }
//   }

//   void _sendMessage() async {
//     final message = _controller.text.trim();
//     if (message.isEmpty) return;

//     setState(() {
//       _messages.add(_ChatMessage(text: message, isUser: true));
//       _isLoading = true;
//     });

//     _controller.clear();

//     final botResponse = await _fetchResponse(message);

//     setState(() {
//       _messages.add(_ChatMessage(text: botResponse, isUser: false));
//       _isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Chatbot')),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               padding: const EdgeInsets.all(12),
//               itemCount: _messages.length,
//               itemBuilder: (context, index) {
//                 final msg = _messages[index];
//                 return Align(
//                   alignment:
//                       msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
//                   child: Container(
//                     margin: const EdgeInsets.symmetric(vertical: 4),
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: msg.isUser ? Colors.blueAccent : Colors.grey[300],
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       msg.text,
//                       style: TextStyle(
//                         color: msg.isUser ? Colors.white : Colors.black87,
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           if (_isLoading)
//             const Padding(
//               padding: EdgeInsets.symmetric(vertical: 8),
//               child: CircularProgressIndicator(),
//             ),
//           const Divider(height: 1),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _controller,
//                     textInputAction: TextInputAction.send,
//                     onSubmitted: (_) => _sendMessage(),
//                     decoration: const InputDecoration.collapsed(
//                       hintText: 'Ask me a question...',
//                     ),
//                     enabled: !_isLoading,
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send),
//                   onPressed: _isLoading ? null : _sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _ChatMessage {
//   final String text;
//   final bool isUser;
//   _ChatMessage({required this.text, required this.isUser});
// }

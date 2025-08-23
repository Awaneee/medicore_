import 'package:flutter/material.dart';
import 'package:hackto/data/huggingface_service.dart';
import 'package:hackto/coolors.dart' as coolors;

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? sentiment;
  final double? confidence;
  final List<dynamic>? sentimentBreakdown; // list of {label, score}

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.sentiment,
    this.confidence,
    this.sentimentBreakdown,
  });
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add(ChatMessage(
        text: "Hello! I'm your Reuth Hospital AI assistant. I can help you with appointments, health questions, and provide emotional support. How are you feeling today?",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    _messageController.clear();

    // Add user message
    setState(() {
      _messages.add(ChatMessage(
        text: userMessage,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      // Analyze sentiment
      final sentimentResult = await HuggingFaceService.analyzeSentiment(userMessage);

      // Effective values used for response generation
      String effectiveSentiment = 'neutral';
      double effectiveConfidence = 0.0;

      // What we show in UI (null means: don't show chip)
      String? displaySentiment;
      double? displayConfidence;

      List<dynamic>? breakdown;
      if (sentimentResult['success'] == true) {
        effectiveSentiment = (sentimentResult['sentiment'] ?? 'neutral') as String;
        effectiveConfidence = (sentimentResult['confidence'] ?? 0.0) as double;
        displaySentiment = effectiveSentiment;
        displayConfidence = effectiveConfidence;
        breakdown = (sentimentResult['all_results'] as List?)?.cast<dynamic>();
      } else {
        // Notify user that sentiment failed (so they know why the chip/details aren't shown)
        final err = (sentimentResult['error'] ?? 'Sentiment analysis failed') as String;
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sentiment: $err')),
        );
      }

      // Generate response
      final response = await HuggingFaceService.generateChatbotResponse(
        userMessage,
        effectiveSentiment,
        effectiveConfidence,
      );

      // Add bot response
      setState(() {
        _messages.add(ChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
          sentiment: displaySentiment,
          confidence: displayConfidence,
          sentimentBreakdown: breakdown,
        ));
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: "I apologize, but I'm having trouble connecting right now. Please try again in a moment.",
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildMessage(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: coolors.customColorScheme.primary,
              child: const Icon(Icons.medical_services, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser ? coolors.customColorScheme.primary : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  if (!message.isUser && message.sentiment != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getSentimentColor(message.sentiment!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Detected: ${message.sentiment} (${(message.confidence! * 100).toStringAsFixed(1)}%)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (message.sentimentBreakdown != null) ...[
                      const SizedBox(height: 6),
                      ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        childrenPadding: EdgeInsets.zero,
                        title: const Text(
                          'View sentiment details',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                        initiallyExpanded: false,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final item in message.sentimentBreakdown!)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        margin: const EdgeInsets.only(right: 6),
                                        decoration: BoxDecoration(
                                          color: _getSentimentColor(item['label']?.toString() ?? ''),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      Text(
                                        '${(item['label'] ?? '').toString()}: ${(((item['score'] ?? 0.0) as num) * 100).toStringAsFixed(1)}%',
                                        style: const TextStyle(fontSize: 12, color: Colors.black87),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person, color: Colors.grey, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  Color _getSentimentColor(String sentiment) {
    switch (sentiment.toLowerCase()) {
      case 'positive':
      case 'joy':
        return Colors.green;
      case 'negative':
      case 'sadness':
        return Colors.blue;
      case 'anger':
        return Colors.red;
      case 'fear':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Healthcare Assistant'),
        backgroundColor: coolors.customColorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          if (_isLoading)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: coolors.customColorScheme.primary,
                    child: const Icon(Icons.medical_services, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 12),
                  const Text('Analyzing your message...'),
                  const SizedBox(width: 12),
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 12),
                FloatingActionButton(
                  onPressed: _isLoading ? null : _sendMessage,
                  backgroundColor: coolors.customColorScheme.primary,
                  mini: true,
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

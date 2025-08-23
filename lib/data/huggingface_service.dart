import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';

class HuggingFaceService {
  // Read from --dart-define=HF_API_KEY=...
  static const String _hfApiKey = String.fromEnvironment('HF_API_KEY');
  static const String _modelName = 'Anshu1234567890/results';
  static const String _baseUrl = 'https://api-inference.huggingface.co/models';
  
  // Add your Gemini API key here
  static const String _geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
  
  static final _systemInstruction = '''
You are a medical assistant bot for Reuth Hospital, designed to help patients, doctors, and caregivers with hospital-related queries.
Your role is to respond to user queries with accurate and helpful answers related to:
- Medical conditions and symptoms
- Hospital services and departments
- Appointment scheduling and procedures
- Medication information and management
- Treatment plans and recovery
- Emergency procedures
- General health guidance

IMPORTANT RULES:
1. ONLY respond to medical, healthcare, or hospital-related queries
2. If a user asks about topics unrelated to healthcare/hospital (like sports, entertainment, politics, etc.), respond with: "I'm sorry, but I can only assist with medical and hospital-related queries. Please consult our staff for other matters or ask me about your health concerns."
3. Always consider the user's emotional state (sentiment) when crafting responses
4. Be empathetic and supportive, especially for users showing negative emotions
5. For serious medical emergencies, always advise contacting emergency services immediately
6. Never provide specific medical diagnoses - always recommend consulting with healthcare professionals

Remember to be compassionate and professional in all interactions.
''';

  static Future<Map<String, dynamic>> analyzeSentiment(String text) async {
    final url = Uri.parse('$_baseUrl/$_modelName');
    
    try {
      // Ensure HF key is present
      if (_hfApiKey.isEmpty) {
        // ignore: avoid_print
        print('[Sentiment] Missing HF_API_KEY; sentiment disabled');
        return {
          'success': false,
          'error': 'Missing HF_API_KEY',
        };
      }

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_hfApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'inputs': text,
        }),
      );

      if (response.statusCode == 200) {
        // Debug: raw HF response
        // ignore: avoid_print
        print('[Sentiment] Raw HF response: ${response.body}');
        final List<dynamic> result = jsonDecode(response.body);
        if (result.isNotEmpty && result[0] is List) {
          // Handle the sentiment analysis response
          final sentiments = result[0] as List;
          
          // Find the highest confidence sentiment
          Map<String, dynamic> bestSentiment = sentiments[0];
          for (var sentiment in sentiments) {
            if (sentiment['score'] > bestSentiment['score']) {
              bestSentiment = sentiment;
            }
          }
          
          // Debug: parsed sentiments
          // ignore: avoid_print
          print('[Sentiment] Parsed: ${sentiments.toString()}');

          return {
            'success': true,
            'sentiment': bestSentiment['label'],
            'confidence': bestSentiment['score'],
            'all_results': sentiments,
          };
        }
      } else if (response.statusCode == 503) {
        return {
          'success': false,
          'error': 'Model is loading, please try again in a few seconds',
        };
      } else {
        // ignore: avoid_print
        print('[Sentiment] HTTP ${response.statusCode}: ${response.body}');
        return {
          'success': false,
          'error': 'Failed to analyze sentiment: ${response.statusCode}',
        };
      }
    } catch (e) {
      // ignore: avoid_print
      print('[Sentiment] Error: ${e.toString()}');
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
    
    return {
      'success': false,
      'error': 'Unexpected response format',
    };
  }

  static Future<String> generateChatbotResponse(String userMessage, String sentiment, double confidence) async {
    try {
      // Ensure Gemini key is provided via --dart-define=GEMINI_API_KEY=...
      if (_geminiApiKey.isEmpty) {
        // Debug: missing key
        // ignore: avoid_print
        print('[Chatbot] Using Fallback (missing GEMINI_API_KEY)');
        return '[Fallback] ${_getFallbackResponse(
          userMessage,
          sentiment,
          confidence,
        )}';
      }
      // Initialize Gemini model
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _geminiApiKey,
        systemInstruction: Content.system(_systemInstruction),
      );

      // Create sentiment context for Gemini
      String sentimentContext = _getSentimentContext(sentiment, confidence);
      
      // Create the prompt with sentiment information
      final prompt = '''
User's emotional state: $sentimentContext
User message: "$userMessage"

Please respond appropriately considering the user's emotional state. If this query is not related to medical, healthcare, or hospital matters, politely decline and redirect to healthcare topics.
''';

      // Generate response using Gemini
      final content = [Content.text(prompt)];
      // Debug: using Gemini
      // ignore: avoid_print
      print('[Chatbot] Using Gemini');
      final response = await model.generateContent(content);
      final text = response.text;
      if (text != null && text.trim().isNotEmpty) {
        return '[Gemini] $text';
      }
      // If Gemini returns empty, fall back
      // ignore: avoid_print
      print('[Chatbot] Gemini returned empty, switching to Fallback');
      return '[Fallback] ${_getFallbackResponse(userMessage, sentiment, confidence)}';
      
    } catch (e) {
      // Fallback to simple response if Gemini fails
      // ignore: avoid_print
      print('[Chatbot] Using Fallback (Gemini error): ${e.toString()}');
      return '[Fallback] ${_getFallbackResponse(userMessage, sentiment, confidence)}';
    }
  }

  static String _getFallbackResponse(String userMessage, String sentiment, double confidence) {
    String emotionalContext = _getEmotionalContext(sentiment, confidence);
    final text = userMessage.toLowerCase();

    // Broaden medical detection and only block when clearly non-medical
    final medicalKeywords = [
      'pain','hurt','sick','ill','fever','temperature','headache','migraine','cough','cold','flu','sore throat','breath','breathing','asthma',
      'chest','pressure','injury','fracture','wound','bleeding','burn','cut','rash','infection','diarrhea','vomit','nausea','covid','covid-19',
      'appointment','book','schedule','doctor','nurse','physician','specialist','cardiologist','neurologist','orthopedic','physiotherapy','therapy',
      'medicine','medication','tablet','pill','capsule','dose','dosage','prescription','side effect','antibiotic','paracetamol','ibuprofen',
      'treatment','surgery','operation','procedure','scan','mri','ct','x-ray','ultrasound','test','lab','report','results','blood','sugar',
      'hospital','ward','clinic','rehab','rehabilitation','discharge','admission','emergency','ambulance','pharmacy','vitals','pressure','bp'
    ];
    final nonMedicalKeywords = [
      'movie','music','song','cricket','football','game','gaming','politics','election','stock','crypto','bitcoin','recipe','travel','tourism'
    ];

    final looksMedical = medicalKeywords.any((k) => text.contains(k));
    final clearlyNonMedical = nonMedicalKeywords.any((k) => text.contains(k));

    if (clearlyNonMedical && !looksMedical) {
      return "I'm sorry, but I can only assist with medical and hospital-related queries. Please consult our staff for other matters or ask me about your health concerns.";
    }

    // Medical query responses
    if (text.contains('chest pain') || text.contains('severe chest') || (text.contains('chest') && text.contains('pain'))) {
      return "Chest pain can be serious. $emotionalContext If this is severe, with shortness of breath, sweating, or radiating pain, please call emergency services or go to the ER immediately. If it's mild, I can help you contact a doctor for urgent advice.";
    }

    if (text.contains('pain') || text.contains('hurt') || text.contains('sick')) {
      return "I understand you're experiencing discomfort. $emotionalContext Please describe your symptoms in detail so we can better assist you. Would you like me to help you schedule an appointment with a doctor?";
    }
    
    if (text.contains('fever') || text.contains('temperature')) {
      return "Fever noted. $emotionalContext Please monitor your temperature, stay hydrated, and rest. If your fever is above 38.5°C (101.3°F) for more than 24 hours or accompanied by severe symptoms, consider visiting our clinic. Would you like me to help you book an appointment or connect with a nurse?";
    }

    if (text.contains('headache') || text.contains('migraine')) {
      return "Headaches can have many causes. $emotionalContext Try rest, hydration, and over-the-counter pain relief if appropriate. If it's the worst headache of your life, with neck stiffness, confusion, or vision changes, seek urgent care. Shall I help you schedule a consultation?";
    }

    if (text.contains('cough') || text.contains('sore throat') || text.contains('cold') || text.contains('flu')) {
      return "Respiratory symptoms noted. $emotionalContext Consider fluids, rest, and symptomatic relief. If you have high fever, shortness of breath, or symptoms persisting beyond a week, please see a doctor. I can help you book an appointment.";
    }

    if (text.contains('appointment') || text.contains('schedule') || text.contains('book')) {
      return "I'd be happy to help you with scheduling. $emotionalContext What type of appointment would you like to book - with a doctor, specialist, or for a specific treatment?";
    }
    
    if (text.contains('emergency') || text.contains('urgent')) {
      return "If this is a medical emergency, please call emergency services immediately or visit the nearest emergency room. $emotionalContext For non-emergency urgent care, I can help you find the appropriate department.";
    }
    
    if (looksMedical) {
      return "Hello! I'm your Reuth Hospital healthcare assistant. $emotionalContext I can help with symptoms, medications, appointments, and tests. Please tell me more about your concern.";
    }

    return "I'm here to help with medical and hospital queries. $emotionalContext Could you please describe your health concern or the service you need (e.g., appointment, medication, test, symptoms)?";
  }

  static String _getSentimentContext(String sentiment, double confidence) {
    if (confidence > 0.7) {
      switch (sentiment.toLowerCase()) {
        case 'positive':
        case 'joy':
          return "The user seems to be in a positive mood (${(confidence * 100).toStringAsFixed(1)}% confidence).";
        case 'negative':
        case 'sadness':
          return "The user appears to be feeling sad or concerned (${(confidence * 100).toStringAsFixed(1)}% confidence).";
        case 'anger':
          return "The user seems frustrated or angry (${(confidence * 100).toStringAsFixed(1)}% confidence).";
        case 'fear':
          return "The user appears to be worried or anxious (${(confidence * 100).toStringAsFixed(1)}% confidence).";
        default:
          return "The user's emotional state is neutral (${(confidence * 100).toStringAsFixed(1)}% confidence).";
      }
    }
    return "The user's emotional state is unclear.";
  }
  
  static String _getEmotionalContext(String sentiment, double confidence) {
    if (confidence > 0.8) {
      switch (sentiment.toLowerCase()) {
        case 'positive':
        case 'joy':
          return "I can tell you're feeling positive about this.";
        case 'negative':
        case 'sadness':
          return "I understand this might be concerning for you.";
        case 'anger':
          return "I can sense your frustration, and I want to help resolve this.";
        case 'fear':
          return "I understand you might be worried, and that's completely normal.";
        default:
          return "I'm here to support you.";
      }
    }
    return "I'm here to help you.";
  }
}

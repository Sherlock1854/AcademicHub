// lib/services/gemini_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  // 1) Your API key from Google Cloud → see steps below
  static const _apiKey = 'AIzaSyDwWVp-zyUVLUNmrWb6aEMRvTAW_pK7KUk';

  // 2) Gemini Developer REST endpoint for generateContent
  static const _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/'
      'gemini-2.5-flash:generateContent';

  /// Send [prompt] to Gemini-2.5-Flash and return its reply.
  Future<String> ask(String prompt) async {
    final uri = Uri.parse('$_endpoint?key=$_apiKey');

    final body = {
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      // optional: steer randomness/length
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 512,
      },
    };

    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (resp.statusCode != 200) {
      throw Exception('Gemini API error ${resp.statusCode}: ${resp.body}');
    }

    final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
    final candidates = decoded['candidates'] as List<dynamic>;
    final first = candidates.first as Map<String, dynamic>;
    final content = (first['content'] as Map<String, dynamic>)['parts']
    as List<dynamic>;
    return (content.first as Map<String, dynamic>)['text'] as String;
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const _apiKey = 'AIzaSyDwWVp-zyUVLUNmrWb6aEMRvTAW_pK7KUk';
  static const _endpoint =
      'https://generativelanguage.googleapis.com/v1beta'
      '/models/gemini-2.5-flash:generateContent';

  /// Send text-only prompt to Gemini and return the reply.
  Future<String> askText(String prompt) async {
    final uri = Uri.parse('$_endpoint?key=$_apiKey');
    final body = {
      'contents': [
        {
          'parts': [
            { 'text': prompt }
          ]
        }
      ],
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
    final candidates = decoded['candidates'] as List<dynamic>? ?? [];
    if (candidates.isEmpty) {
      throw Exception('Gemini returned no candidates');
    }

    final first = candidates.first as Map<String, dynamic>;

    // Try direct 'parts'
    var parts = first['parts'] as List<dynamic>?;
    // Fallback to content.parts
    if (parts == null) {
      final content = first['content'] as Map<String, dynamic>?;
      parts = content?['parts'] as List<dynamic>?;
    }

    if (parts == null || parts.isEmpty) {
      throw Exception('No parts in Gemini response');
    }

    final p0 = parts.first;
    if (p0 is String) {
      return p0;
    } else if (p0 is Map<String, dynamic> && p0['text'] is String) {
      return p0['text'] as String;
    } else {
      return p0.toString();
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const _endpoint =
      'https://us-central1-aiplatform.googleapis.com'
      '/v1/projects/academichub-c1068/locations/us-central1'
      '/publishers/google/models/chat-bison-001:predict';
  final _apiKey = 'AIzaSyBOoWYP2bDaZ4deMMb2GdJoipXtNb7zKig';

  /// Send user [prompt] to Gemini and get the bot’s reply.
  Future<String> ask(String prompt) async {
    final url = '$_endpoint?key=$_apiKey';

    final resp = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'instances': [
          {'content': prompt}
        ],
        // Optionally, you can add parameters here, e.g. temperature
        'parameters': {
          'temperature': 0.7,
          'maxOutputTokens': 512,
        },
      }),
    );
    if (resp.statusCode != 200) {
      throw Exception('Gemini error: ${resp.statusCode} ${resp.body}');
    }
    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    final preds = body['predictions'] as List<dynamic>;
    final first = preds.first as Map<String, dynamic>;
    return first['content'] as String;
  }
}

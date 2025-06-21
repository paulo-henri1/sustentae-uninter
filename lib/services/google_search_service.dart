import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article_model.dart';

class GoogleSearchService {
  static const String _apiKey = "AIzaSyA6NJnl5HvXcWk8voHrXFGXYcOd533t8QQ";
  static const String _searchEngineId = "87f5ffc65c73546b8";

  Future<List<Article>> fetchArticles() async {
    const String query = "Sustentabilidade no dia a dia";

    final Uri uri = Uri.https(
      'www.googleapis.com',
      '/customsearch/v1',
      {
        'key': _apiKey,
        'cx': _searchEngineId,
        'q': query,
        'sort': 'date',
        'lr': 'lang_pt',
        'hl': 'pt',
      },
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data.containsKey('items')) {
        final List<dynamic> items = data['items'];
        return items.map((item) => Article.fromJson(item)).toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Falha ao carregar artigos: ${response.body}');
    }
  }
}
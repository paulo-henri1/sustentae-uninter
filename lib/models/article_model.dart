class Article {
  final String title;
  final String link;
  final String snippet;

  Article({required this.title, required this.link, required this.snippet});

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? 'Sem Título',
      link: json['link'] ?? '',
      snippet: json['snippet'] ?? 'Sem descrição disponível.',
    );
  }
}
class Movie {
  final int id;
  final String title;
  final String posterPath;
  final String overview;

  Movie({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.overview,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0, // nullの場合、デフォルト値として'0'を設定
      title: json['title'] ?? 'No Title',
      posterPath: json['posterPath'] ?? '',
      overview: json['overview'] ?? '',
    );
  }
}

class Movie {
  final String title;
  final String posterPath;
  final String overview;

  Movie({required this.title, required this.posterPath, required this.overview});

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['title'] ?? '제목 없음', // null일 경우 '제목 없음'으로 처리
      posterPath: json['posterPath'] ?? '', // null일 경우 빈 문자열로 처리
      overview: json['overview'] ?? '', // null일 경우 빈 문자열로 처리
    );
  }
}

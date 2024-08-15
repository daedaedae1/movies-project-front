class Movie {
  final int id;
  final String title;
  final String posterPath;
  final String overview;

  Movie({
    required this.id, // id 필드 추가
    required this.title,
    required this.posterPath,
    required this.overview,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0, // null일 경우 기본값으로 0 처리
      title: json['title'] ?? '제목 없음', // null일 경우 '제목 없음' 처리
      posterPath: json['posterPath'] ?? '', // null일 경우 빈 문자열로 처리
      overview: json['overview'] ?? '', // null일 경우 빈 문자열로 처리
    );
  }
}

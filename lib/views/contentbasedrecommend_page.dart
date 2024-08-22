import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math'; // 랜덤 기능을 위한 import
import '../model/movie.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ContentBasedRecommendPage extends StatefulWidget {
  final int userId;

  ContentBasedRecommendPage({required this.userId});

  @override
  _ContentBasedRecommendPageState createState() => _ContentBasedRecommendPageState();
}

class _ContentBasedRecommendPageState extends State<ContentBasedRecommendPage> {
  List<Movie> _recommendedMovies = [];
  List<Movie> _displayedMovies = []; // 랜덤하게 선택된 5개의 영화
  bool _isFetching = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchRecommendedMovies();
  }

  Future<void> _fetchRecommendedMovies() async {
    if (_isFetching) return;

    setState(() {
      _isFetching = true;
      _hasError = false;
    });

    try {
      final url = Uri.parse('http://localhost:8080/movies/recommend/content?userId=${widget.userId}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(utf8.decode(response.bodyBytes));
        final List<Movie> movies = jsonResponse.map<Movie>((jsonItem) => Movie.fromJson(jsonItem)).toList();

        setState(() {
          _recommendedMovies = movies;
          _displayedMovies = _getRandomMovies(_recommendedMovies, 5); // 랜덤으로 5개 영화 선택
        });
      } else {
        throw Exception('おすすめ映画の取得に失敗しました。: ${response.statusCode}');
      }
    } catch (e) {
      print('おすすめ映画を取得中にエラーが発生しました。: $e');
      setState(() {
        _hasError = true;
      });
    } finally {
      setState(() {
        _isFetching = false;
      });
    }
  }

  // 랜덤하게 n개의 영화를 선택하는 함수
  List<Movie> _getRandomMovies(List<Movie> movies, int n) {
    final random = Random();
    // 리스트를 무작위로 섞고, 앞의 n개를 선택
    movies.shuffle(random);
    return movies.take(n).toList();
  }

  Widget _buildMovieCard(Movie movie) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: CachedNetworkImage(
                  imageUrl: movie.posterPath,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                  fit: BoxFit.fill,
                  width: 120,
                  height: 170,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        movie.title,
                        style: TextStyle(
                          fontSize: 19.0,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 5.0),
                      Text(
                        movie.overview,
                        maxLines: 3,
                        style: TextStyle(
                          fontSize: 15.0,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('視聴履歴からの推薦'),
      ),
      body: _isFetching
          ? Center(child: CircularProgressIndicator())
          : _hasError
          ? Center(
        child: Text(
          '映画推薦を取得する際にエラーが発生しました。',
          style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.normal,
              color: Colors.grey[700]),
        ),
      )
          : _displayedMovies.isEmpty
          ? Center(
        child: Text(
          '視聴履歴を登録してください！',
          style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.normal,
              color: Colors.grey[700]),
        ),
      )
          : ListView.builder(
        itemCount: _displayedMovies.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildMovieCard(_displayedMovies[index]);
        },
      ),
    );

  }
}

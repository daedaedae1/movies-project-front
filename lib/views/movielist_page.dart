import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../model/movie.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MovieList extends StatefulWidget {
  @override
  _MovieListState createState() => _MovieListState();
}

class _MovieListState extends State<MovieList> {
  List<Movie> _movies = [];
  List<int> _viewedMovies = [];
  int _currentPage = 0;
  bool _isFetching = false;
  bool _isSearchActive = false;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMovies();
    _fetchViewedMovies();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _fetchMovies({String? query}) async {
    if (_isFetching) return;

    _isFetching = true;

    try {
      final url = query == null
          ? Uri.parse('http://localhost:8080/movies/get?page=$_currentPage')
          : Uri.parse('http://localhost:8080/movies/search?query=$query&page=$_currentPage');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic> jsonList = jsonResponse['content'] as List<dynamic>;
        final List<Movie> movies = jsonList.map<Movie>((jsonItem) => Movie.fromJson(jsonItem)).toList();

        setState(() {
          _movies.addAll(movies);
          _currentPage++;
        });
      } else {
        throw Exception('映画リストを取得する際に失敗しました。: ${response.statusCode}');
      }
    } catch (e) {
      print('映画リストを取得中にエラーが発生しました。: $e');
    } finally {
      _isFetching = false;
    }
  }

  Future<void> _fetchViewedMovies() async {
    final prefs = await SharedPreferences.getInstance();
    final userid = prefs.getInt('userIdNumeric');

    if (userid == null) return;

    var url = Uri.parse('http://localhost:8080/viewing_history/$userid');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> viewedMoviesJson = json.decode(utf8.decode(response.bodyBytes));
      setState(() {
        _viewedMovies = viewedMoviesJson.map<int>((jsonItem) => jsonItem['movieId'] as int).toList();
      });
    } else {
      throw Exception('視聴履歴を取得する際に失敗しました。: ${response.statusCode}');
    }
  }

  Future<void> _recordViewingHistory(Movie movie) async {
    final prefs = await SharedPreferences.getInstance();
    final userid = prefs.getInt('userIdNumeric');
    if (userid == null) return;

    var url = Uri.parse('http://localhost:8080/viewing_history'); // サーバーアドレスを変更

    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode({
        'userId': userid,
        'movieId': movie.id,
      }),
    );

    if (response.statusCode == 200) {
      print('視聴履歴の保存が完了しました。');
      await _fetchViewedMovies();  // 視聴履歴を再取得
    } else {
      throw Exception('視聴履歴の保存に失敗しました。: ${response.statusCode}');
    }
  }

  Future<void> _deleteViewingHistory(Movie movie) async {
    final prefs = await SharedPreferences.getInstance();
    final userid = prefs.getInt('userIdNumeric');
    if (userid == null) return;

    var url = Uri.parse('http://localhost:8080/viewing_history?userId=$userid&movieId=${movie.id}');

    var response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode == 204) {
      print('視聴履歴の削除が完了しました。');
      await _fetchViewedMovies();  // 視聴履歴を再取得
    } else {
      throw Exception('視聴履歴の削除に失敗しました。: ${response.statusCode}');
    }
  }

  void _onSearch() {
    final query = _searchController.text;
    if (query.isNotEmpty) {
      _movies.clear();
      _currentPage = 0;
      _isSearchActive = true;
      _fetchMovies(query: query).then((_) {
        _scrollController.animateTo(
          0.0,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    } else {
      _movies.clear();
      _currentPage = 0;
      _isSearchActive = false;
      _fetchMovies().then((_) {
        _scrollController.animateTo(
          0.0,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _onScroll() {
    if (!_isFetching && _scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (_isSearchActive) {
        _fetchMovies(query: _searchController.text);
      } else {
        _fetchMovies();
      }
    }
  }

  Widget _buildMovieCard(Movie movie) {
    bool hasViewed = _viewedMovies.contains(movie.id);

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
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: hasViewed
                  ? TextButton(
                onPressed: () => _deleteViewingHistory(movie),
                child: Text(
                    'キャンセル',
                    style: TextStyle(fontSize: 15.0)
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                ),
              )
                  : TextButton(
                onPressed: () => _recordViewingHistory(movie),
                child: Text(
                    '視聴',
                    style: TextStyle(fontSize: 15.0)
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('映画一覧'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: _onSearch,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(15.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: '検索ワードを入力してください。',
              ),
              onSubmitted: (query) => _onSearch(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _movies.length,
              itemBuilder: (BuildContext context, int index) {
                return _buildMovieCard(_movies[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

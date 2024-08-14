import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/Movie.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MovieList extends StatefulWidget {
  @override
  _MovieListState createState() => _MovieListState();
}

class _MovieListState extends State<MovieList> {
  List<Movie> _movies = [];
  int _currentPage = 0;
  bool _isFetching = false;
  bool _isSearchActive = false;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMovies();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _fetchMovies({String? query}) async {
    if (_isFetching) return;

    _isFetching = true;

    final url = query == null
        ? Uri.parse('http://localhost:8080/movies/get?page=$_currentPage')
        : Uri.parse('http://localhost:8080/movies/search?query=$query&page=$_currentPage');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      // 정상적 응답의 처리
      final responseBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> jsonResponse = json.decode(responseBody);

      final List<dynamic> jsonList = jsonResponse['content'] as List<dynamic>;

      final List<Movie> movies = jsonList.map<Movie>((jsonItem) => Movie.fromJson(jsonItem)).toList();
      setState(() {
        _movies.addAll(movies);
        _currentPage++;
      });
    } else {
      throw Exception('Failed to load movies');
    }

    _isFetching = false;
  }

  void _onSearch() {
    final query = _searchController.text;
    if (query.isNotEmpty) {
      // 검색어가 있을 경우
      _movies.clear();
      _currentPage = 0;
      _isSearchActive = true;
      _fetchMovies(query: query).then((_) {
        // 검색 결과가 로드된 후 스크롤을 맨 위로 올림
        _scrollController.animateTo(
          0.0, // 스크롤 위치를 0으로 설정하여 맨 위로 이동
          duration: Duration(milliseconds: 300), // 스크롤 이동에 걸리는 시간
          curve: Curves.easeOut, // 이동 애니메이션 효과
        );
      });
    } else {
      // 검색어가 비어있을 경우
      _movies.clear();
      _currentPage = 0;
      _isSearchActive = false;
      _fetchMovies().then((_) {
        // 검색 결과가 로드된 후 스크롤을 맨 위로 올림
        _scrollController.animateTo(
          0.0,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _onScroll() {
    // 스크롤이 맨 아래에 도달했고, 현재 다른 데이터를 불러오고 있지 않을 때
    if (!_isFetching && _scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      // 검색이 활성화된 상태라면, 현재 검색어로 추가 영화를 검색
      if (_isSearchActive) {
        _fetchMovies(query: _searchController.text); // 검색어를 인자로 넘김.
      } else {
        // 검색이 활성화되지 않았다면, 일반 영화 목록을 계속 불러옴
        _fetchMovies();
      }
    }
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
        title: Text('영화 목록'),
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
            padding: EdgeInsets.all(10.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: '검색어를 입력하세요',
              ),
              onSubmitted: (query) => _onSearch(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _movies.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      // 영화 상세 정보 페이지로 이동하는 로직을 여기에 추가
                    },
                    child: Row(
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4.0),
                          child: CachedNetworkImage(
                            imageUrl: _movies[index].posterPath,
                            placeholder: (context, url) => CircularProgressIndicator(),
                            errorWidget: (context, url, error) => Icon(Icons.error),
                            fit: BoxFit.cover,
                            width: 100,
                            height: 150,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  _movies[index].title,
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 5.0),
                                Text(
                                  _movies[index].overview,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:io';
import 'dart:ui';
import 'package:Mirarr/functions/fetch_popular_movies.dart';
import 'package:Mirarr/functions/fetch_trending_movies.dart';
import 'package:Mirarr/moviesPage/functions/on_tap_movie.dart';
import 'package:Mirarr/moviesPage/functions/on_tap_movie_desktop.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:Mirarr/moviesPage/UI/customMovieWidget.dart';
import 'package:Mirarr/moviesPage/models/movie.dart';
import 'package:Mirarr/widgets/bottom_bar.dart';
import 'dart:async';

class MovieSearchScreen extends StatefulWidget {
  static final GlobalKey<_MovieSearchScreenState> movieSearchKey =
      GlobalKey<_MovieSearchScreenState>();

  const MovieSearchScreen({super.key});
  @override
  _MovieSearchScreenState createState() => _MovieSearchScreenState();
}

class _MovieSearchScreenState extends State<MovieSearchScreen> {
  final apiKey = dotenv.env['TMDB_API_KEY'];

  List<Movie> trendingMovies = [];
  List<Movie> popularMovies = [];

  Future<void> _fetchTrendingMovies() async {
    try {
      final movies = await fetchTrendingMovies();
      setState(() {
        trendingMovies = movies;
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _fetchPopularMovies() async {
    try {
      final movies = await fetchPopularMovies();
      setState(() {
        popularMovies = movies;
      });
    } catch (e) {
      // Handle error
    }
  }

  void handleNetworkError(ClientException e) {
    if (e.message.contains('No address associated with hostname')) {
      // Handle case where there's no internet connection
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('No Internet Connection'),
            content:
                const Text('Please connect to the internet and try again.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      // Handle other network-related errors
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            titleTextStyle:
                const TextStyle(color: Colors.orangeAccent, fontSize: 20),
            contentTextStyle:
                const TextStyle(color: Colors.orange, fontSize: 16),
            title: const Text('Network Error'),
            content: const Text(
                'An error occurred while fetching data. Please try again later.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  checkInternetAndFetchData();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    checkInternetAndFetchData();
  }

  Future<void> checkInternetAndFetchData() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // No internet connection
      handleNetworkError(ClientException('No internet connection'));
    } else {
      // Internet connection available, fetch data
      _fetchTrendingMovies();
      _fetchPopularMovies();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text(
            'Movies',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Column(
          children: [
            Expanded(
                child: Card(
              shadowColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: SingleChildScrollView(
                child: Container(
                  color: Colors.black,
                  child: Column(
                    children: <Widget>[
                      const Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(15, 15, 0, 0),
                            child: Text(
                              textAlign: TextAlign.left,
                              'Trending Movies',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: 320, // Set the height for the movie cards
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(
                            dragDevices: {
                              PointerDeviceKind.touch,
                              PointerDeviceKind.mouse,
                              PointerDeviceKind.trackpad,
                            },
                          ),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: trendingMovies.length,
                            itemBuilder: (context, index) {
                              final movie = trendingMovies[index];
                              return GestureDetector(
                                onTap: () => Platform.isAndroid ||
                                        Platform.isIOS
                                    ? onTapMovie(movie.title, movie.id, context)
                                    : onTapMovieDesktop(
                                        movie.title, movie.id, context),
                                child: CustomMovieWidget(
                                  movie: movie,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(15, 15, 0, 0),
                            child: Text(
                              'Popular Movies',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 320, // Set the height for the movie cards
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(
                            dragDevices: {
                              PointerDeviceKind.touch,
                              PointerDeviceKind.mouse,
                              PointerDeviceKind.trackpad,
                            },
                          ),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: popularMovies.length,
                            itemBuilder: (context, index) {
                              final movie = popularMovies[index];
                              return GestureDetector(
                                onTap: () => Platform.isAndroid ||
                                        Platform.isIOS
                                    ? onTapMovie(movie.title, movie.id, context)
                                    : onTapMovieDesktop(
                                        movie.title, movie.id, context),
                                child: CustomMovieWidget(
                                  movie: movie,
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )),
          ],
        ),
        bottomNavigationBar: const BottomBar());
  }
}

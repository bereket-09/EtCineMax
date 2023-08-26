// ignore_for_file: avoid_unnecessary_containers

import '/provider/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/api/endpoints.dart';
import '/widgets/movie_widgets.dart';
import '/models/genres.dart';

class GenreMovies extends StatelessWidget {
  final Genres genres;
  const GenreMovies({Key? key, required this.genres}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${genres.genreName!} movies',
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        child: ParticularGenreMovies(
          includeAdult: Provider.of<SettingsProvider>(context).isAdult,
          genreId: genres.genreID!,
          api: Endpoints.getMoviesForGenre(genres.genreID!, 1),
          watchRegion: Provider.of<SettingsProvider>(context).defaultCountry,
        ),
      ),
    );
  }
}

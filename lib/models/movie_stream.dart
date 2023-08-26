class MovieStream {
  MovieStream(
      {required this.currentPage,
      required this.hasNextPage,
      required this.results});

  int? currentPage;
  bool? hasNextPage;
  List<MovieResults>? results;

  MovieStream.fromJson(Map<String, dynamic> json) {
    currentPage = json['currentPage'];
    hasNextPage = json['hasNextPage'];
    if (json['results'] != null) {
      results = [];
      json['results'].forEach((v) {
        results!.add(MovieResults.fromJson(v));
      });
    }
  }
}

class MovieResults {
  MovieResults(
      {required this.id,
      required this.image,
      required this.releaseDate,
      required this.title,
      required this.type,
      required this.url});

  String? id;
  String? title;
  String? url;
  String? image;
  String? releaseDate;
  String? type;

  MovieResults.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    url = json['url'];
    image = json['image'];
    releaseDate = json['releaseDate'];
    type = json['type'];
  }
}

class MovieInfo {
  MovieInfo();

  String? id;
  String? title;
  String? url;
  String? type;
  String? releaseDate;
  List<MovieEpisodes>? episodes;

  MovieInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    url = json['url'];
    type = json['type'];
    releaseDate = json['releaseDate'];
    if (json['episodes'] != null) {
      episodes = [];
      json['episodes'].forEach((v) {
        episodes!.add(MovieEpisodes.fromJson(v));
      });
    }
  }
}

class MovieEpisodes {
  MovieEpisodes();

  String? id;
  String? title;
  String? url;

  MovieEpisodes.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    url = json['url'];
  }
}

class MovieVideoSources {
  MovieVideoSources();

  List<MovieVideoLinks>? videoLinks;
  List<MovieVideoSubtitles>? videoSubtitles;

  MovieVideoSources.fromJson(Map<String, dynamic> json) {
    if (json['sources'] != null) {
      videoLinks = [];
      json['sources'].forEach((v) {
        videoLinks!.add(MovieVideoLinks.fromJson(v));
      });
    }
    if (json['subtitles'] != null) {
      videoSubtitles = [];
      json['subtitles'].forEach((v) {
        videoSubtitles!.add(MovieVideoSubtitles.fromJson(v));
      });
    }
  }
}

class MovieVideoLinks {
  MovieVideoLinks();

  String? url;
  String? quality;
  bool? isM3U8;

  MovieVideoLinks.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    quality = json['quality'];
    isM3U8 = json['isM3U8'];
  }
}

class MovieVideoSubtitles {
  String? url;
  String? language;

  MovieVideoSubtitles.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    language = json['lang'];
  }
}

import 'package:better_player/better_player.dart';
import 'package:cinemax/constants/app_constants.dart';
import 'package:cinemax/controllers/recently_watched_database_controller.dart';
import 'package:cinemax/models/recently_watched.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/recently_watched_provider.dart';

class PlayerOne extends StatefulWidget {
  const PlayerOne(
      {required this.sources,
      required this.subs,
      required this.colors,
      required this.videoProperties,
      this.movieMetadata,
      this.tvMetadata,
      required this.mediaType,
      Key? key})
      : super(key: key);
  final Map<String, String> sources;
  final List<BetterPlayerSubtitlesSource> subs;
  final List<Color> colors;
  final List videoProperties;
  final List? movieMetadata;
  final List? tvMetadata;
  final MediaType? mediaType;

  @override
  State<PlayerOne> createState() => _PlayerOneState();
}

class _PlayerOneState extends State<PlayerOne> with WidgetsBindingObserver {
  late BetterPlayerController _betterPlayerController;
  late BetterPlayerControlsConfiguration betterPlayerControlsConfiguration;
  late BetterPlayerBufferingConfiguration betterPlayerBufferingConfiguration;
  RecentlyWatchedMoviesController recentlyWatchedMoviesController =
      RecentlyWatchedMoviesController();
  RecentlyWatchedEpisodeController recentlyWatchedEpisodeController =
      RecentlyWatchedEpisodeController();
  late int duration;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    betterPlayerBufferingConfiguration = BetterPlayerBufferingConfiguration(
      maxBufferMs: widget.videoProperties.first,
      minBufferMs: 15000,
    );
    betterPlayerControlsConfiguration = BetterPlayerControlsConfiguration(
      enableFullscreen: true,
      backgroundColor: widget.colors.elementAt(1).withOpacity(0.6),
      progressBarBackgroundColor: Colors.white,
      pauseIcon: Icons.pause_outlined,
      pipMenuIcon: Icons.picture_in_picture_sharp,
      playIcon: Icons.play_arrow_sharp,
      showControlsOnInitialize: false,
      loadingColor: widget.colors.first,
      iconsColor: widget.colors.first,
      backwardSkipTimeInMilliseconds:
          Duration(seconds: widget.videoProperties.elementAt(1)).inMilliseconds,
      forwardSkipTimeInMilliseconds:
          Duration(seconds: widget.videoProperties.elementAt(1)).inMilliseconds,
      progressBarPlayedColor: widget.colors.first,
      progressBarBufferedColor: Colors.black45,
    );

    BetterPlayerConfiguration betterPlayerConfiguration =
        BetterPlayerConfiguration(
            autoDetectFullscreenDeviceOrientation: true,
            fullScreenByDefault: widget.videoProperties.elementAt(3),
            autoPlay: true,
            fit: BoxFit.contain,
            autoDispose: true,
            controlsConfiguration: betterPlayerControlsConfiguration,
            showPlaceholderUntilPlay: true,
            subtitlesConfiguration: const BetterPlayerSubtitlesConfiguration(
                backgroundColor: Colors.black45,
                fontFamily: 'Poppins',
                fontColor: Colors.white,
                outlineEnabled: false,
                fontSize: 17));

    String keyToFind = widget.videoProperties.elementAt(2) == 0
        ? 'auto'
        : widget.videoProperties.elementAt(2).toString();
    String? link;

    if (widget.sources.entries
        .where((entry) => entry.key == keyToFind)
        .isNotEmpty) {
      link = widget.sources.entries
          .where((entry) => entry.key == keyToFind)
          .map((entry) => entry.value)
          .first;
    } else {
      link = widget.sources.values.first;
    }

    BetterPlayerDataSource dataSource =
        BetterPlayerDataSource(BetterPlayerDataSourceType.network, link,
            resolutions: widget.sources,
            subtitles: widget.subs,
            cacheConfiguration: const BetterPlayerCacheConfiguration(
              useCache: true,
              preCacheSize: 471859200 * 471859200,
              maxCacheSize: 1073741824 * 1073741824,
              maxCacheFileSize: 471859200 * 471859200,

              ///Android only option to use cached video between app sessions
              key: "testCacheKey",
            ),
            bufferingConfiguration: betterPlayerBufferingConfiguration);
    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
    _betterPlayerController.setupDataSource(dataSource).then((value) {
      _betterPlayerController.videoPlayerController!.seekTo(Duration(
          seconds: widget.mediaType == MediaType.movie
              ? widget.movieMetadata!.elementAt(5)
              : widget.tvMetadata!.elementAt(8)));
      duration = _betterPlayerController
          .videoPlayerController!.value.duration!.inSeconds;
    });
  }

  Future<void> insertRecentMovieData() async {
    int elapsed = await _betterPlayerController.videoPlayerController!.position
        .then((value) => value!.inSeconds);

    int remaining = duration - elapsed;
    String dt = DateTime.now().toString();

    var isBookmarked = await recentlyWatchedMoviesController
        .contain(widget.movieMetadata!.elementAt(0));
    dynamic prv;
    if (mounted) {
      prv = Provider.of<RecentProvider>(context, listen: false);
    }

    RecentMovie rMov = RecentMovie(
        dateTime: dt,
        elapsed: elapsed,
        id: widget.movieMetadata!.elementAt(0),
        posterPath: widget.movieMetadata!.elementAt(2),
        releaseYear: widget.movieMetadata!.elementAt(4),
        remaining: remaining,
        title: widget.movieMetadata!.elementAt(1),
        backdropPath: widget.movieMetadata!.elementAt(3));

    double precentage = (elapsed / duration) * 100;

    if (!isBookmarked) {
      prv.addMovie(rMov);
    } else {
      if (precentage <= 90) {
        prv.updateMovie(rMov, widget.movieMetadata!.elementAt(0));
      } else {
        prv.deleteMovie(widget.movieMetadata!.elementAt(0));
      }
    }
  }

  Future<void> insertRecentEpisodeData() async {
    int elapsed = await _betterPlayerController.videoPlayerController!.position
        .then((value) => value!.inSeconds);

    int remaining = duration - elapsed;
    String dt = DateTime.now().toString();

    var isBookmarked = await recentlyWatchedEpisodeController
        .contain(widget.tvMetadata!.elementAt(0));

    dynamic prv;
    if (mounted) {
      prv = Provider.of<RecentProvider>(context, listen: false);
    }

    RecentEpisode rEpisode = RecentEpisode(
        dateTime: dt,
        elapsed: elapsed,
        id: widget.tvMetadata!.elementAt(0),
        posterPath: widget.tvMetadata!.elementAt(7),
        totalSeasons: widget.tvMetadata!.elementAt(5),
        remaining: remaining,
        seriesName: widget.tvMetadata!.elementAt(1),
        backdropPath: widget.tvMetadata!.elementAt(6),
        episodeName: widget.tvMetadata!.elementAt(2),
        episodeNum: widget.tvMetadata!.elementAt(3),
        seasonNum: widget.tvMetadata!.elementAt(4));

    double precentage = (elapsed / duration) * 100;
    if (!isBookmarked) {
      prv.addEpisode(rEpisode);
    } else {
      if (precentage <= 95) {
        prv.updateEpisode(rEpisode, widget.tvMetadata!.elementAt(0),
            widget.tvMetadata!.elementAt(3), widget.tvMetadata!.elementAt(4));
      } else {
        prv.deleteEpisode(widget.tvMetadata!.elementAt(0),
            widget.tvMetadata!.elementAt(3), widget.tvMetadata!.elementAt(4));
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final isInBackground = (state == AppLifecycleState.paused) ||
        (state == AppLifecycleState.inactive);
    if (isInBackground) {
      if (_betterPlayerController.isVideoInitialized()!) {
        widget.mediaType == MediaType.movie
            ? insertRecentMovieData()
            : insertRecentEpisodeData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // print(widget.movieMetadata!.elementAt(0));
    return WillPopScope(
      onWillPop: () async {
        if (_betterPlayerController.isVideoInitialized()!) {
          widget.mediaType == MediaType.movie
              ? insertRecentMovieData()
              : insertRecentEpisodeData();
        }
        return true;
      },
      child: Scaffold(
        body: Center(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            child: BetterPlayer(
              controller: _betterPlayerController,
            ),
          ),
        ),
      ),
    );
  }
}

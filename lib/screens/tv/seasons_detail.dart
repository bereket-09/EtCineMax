import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../provider/settings_provider.dart';
import '../../widgets/common_widgets.dart';
import '/api/endpoints.dart';
import '/constants/api_constants.dart';
import '../../constants/app_constants.dart';
import '/models/tv.dart';
import '/widgets/tv_widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';
import '/widgets/movie_widgets.dart';

class SeasonsDetail extends StatefulWidget {
  final Seasons seasons;
  final String heroId;
  final int? tvId;
  final String? seriesName;
  final TVDetails tvDetails;

  const SeasonsDetail({
    Key? key,
    required this.seasons,
    required this.heroId,
    required this.tvDetails,
    this.seriesName,
    this.tvId,
  }) : super(key: key);

  @override
  SeasonsDetailState createState() => SeasonsDetailState();
}

class SeasonsDetailState extends State<SeasonsDetail>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<SeasonsDetail> {
  late TabController tabController;
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
    mixpanelUpload(context);
  }

  void mixpanelUpload(BuildContext context) {
    final mixpanel =
        Provider.of<SettingsProvider>(context, listen: false).mixpanel;
    mixpanel.track('Most viewed season details', properties: {
      'TV series name': '${widget.seriesName}',
      'TV series season number': '${widget.seasons.seasonNumber}',
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return Scaffold(
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            elevation: 1,
            shadowColor: isDark ? Colors.white : Colors.black,
            forceElevated: true,
            backgroundColor: isDark ? Colors.black : Colors.white,
            leading: SABTN(
              onBack: () {
                Navigator.pop(context);
              },
            ),
            title: SABT(
                child: Text(
              widget.seasons.airDate == null || widget.seasons.airDate == ""
                  ? widget.seasons.name!
                  : '${widget.seasons.name!} (${DateTime.parse(widget.seasons.airDate!).year})',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
              ),
            )),
            expandedHeight: 315,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Column(
                children: [
                  TVSeasonDetailQuickInfo(
                      tvSeries: widget.tvDetails,
                      heroId: widget.heroId,
                      season: widget.seasons),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate.fixed(
              [
                TVSeasonAbout(
                  season: widget.seasons,
                  tvDetails: widget.tvDetails,
                  seriesName: widget.seriesName,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class TVSeasonDetailQuickInfo extends StatelessWidget {
  const TVSeasonDetailQuickInfo({
    Key? key,
    required this.tvSeries,
    required this.heroId,
    required this.season,
  }) : super(key: key);

  final TVDetails tvSeries;
  final Seasons season;
  final String heroId;

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    return SizedBox(
      height: 310,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: AlignmentDirectional.bottomCenter,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Stack(
              alignment: AlignmentDirectional.bottomCenter,
              children: [
                ShaderMask(
                  shaderCallback: (rect) {
                    return const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black,
                        Colors.black,
                        Colors.black,
                        Colors.transparent
                      ],
                    ).createShader(
                        Rect.fromLTRB(0, 0, rect.width, rect.height));
                  },
                  blendMode: BlendMode.dstIn,
                  child: Container(
                    decoration: const BoxDecoration(
                      border:
                          Border(bottom: BorderSide(color: Colors.transparent)),
                    ),
                    child: SizedBox(
                      height: 220,
                      child: Stack(
                        children: [
                          PageView.builder(
                            itemBuilder: (context, index) {
                              return tvSeries.backdropPath == null
                                  ? Image.asset(
                                      'assets/images/na_logo.png',
                                      fit: BoxFit.cover,
                                    )
                                  : CachedNetworkImage(
                                      cacheManager: cacheProp(),
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          Image.asset(
                                        'assets/images/loading_5.gif',
                                        fit: BoxFit.cover,
                                      ),
                                      imageUrl:
                                          '${TMDB_BASE_IMAGE_URL}original/${tvSeries.backdropPath!}',
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                        'assets/images/na_logo.png',
                                        fit: BoxFit.cover,
                                      ),
                                    );
                            },
                          ),
                          Positioned(
                            top: -10,
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: SafeArea(
                              child: Container(
                                alignment: Alignment.topRight,
                                child: const TopButton(
                                  buttonText: 'Open show',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // poster and title movie details
          Positioned(
              bottom: 0.0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(children: [
                  // poster
                  Hero(
                    tag: heroId,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 94,
                              height: 140,
                              child: season.posterPath == null
                                  ? Image.asset(
                                      'assets/images/na_logo.png',
                                      fit: BoxFit.cover,
                                    )
                                  : CachedNetworkImage(
                                      cacheManager: cacheProp(),
                                      fit: BoxFit.fill,
                                      placeholder: (context, url) =>
                                          scrollingImageShimmer(isDark),
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                        'assets/images/na_logo.png',
                                        fit: BoxFit.cover,
                                      ),
                                      imageUrl: TMDB_BASE_IMAGE_URL +
                                          imageQuality +
                                          season.posterPath!,
                                    ),
                            ),
                          ),
                        )),
                  ),
                  const SizedBox(width: 16),
                  //  titles
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () {
                            // _utilityController.toggleTitleVisibility();
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                season.airDate == null || season.airDate == ""
                                    ? season.name!
                                    : '${season.name!} (${DateTime.parse(season.airDate!).year})',
                                style: kTextSmallHeaderStyle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 15.0),
                                child: Column(
                                  children: [
                                    Text(
                                      tvSeries.originalTitle!,
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: isDark
                                              ? Colors.white54
                                              : Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ))
        ],
      ),
    );
  }
}

class TVSeasonAbout extends StatefulWidget {
  const TVSeasonAbout({
    Key? key,
    required this.season,
    required this.tvDetails,
    required this.seriesName,
  }) : super(key: key);

  final Seasons season;
  final TVDetails tvDetails;
  final String? seriesName;

  @override
  State<TVSeasonAbout> createState() => _TVSeasonAboutState();
}

class _TVSeasonAboutState extends State<TVSeasonAbout> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8.0),
                bottomRight: Radius.circular(8.0))),
        child: Column(
          children: [
            const Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text(
                    'Overview',
                    style: kTextHeaderStyle,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ReadMoreText(
                widget.season.overview!.isEmpty
                    ? 'This season doesn\'t have an overview'
                    : widget.season.overview!,
                trimLines: 4,
                style: const TextStyle(fontFamily: 'Poppins'),
                colorClickableText: Theme.of(context).colorScheme.primary,
                trimMode: TrimMode.Line,
                trimCollapsedText: 'read more',
                trimExpandedText: 'read less',
                lessStyle: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold),
                moreStyle: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
                  child: Text(
                    widget.season.airDate == null
                        ? 'First episode air date: N/A'
                        : 'First episode air date:  ${DateTime.parse(widget.season.airDate!).day} ${DateFormat("MMMM").format(DateTime.parse(widget.season.airDate!))}, ${DateTime.parse(widget.season.airDate!).year}',
                    style: const TextStyle(
                      fontFamily: 'PoppinsSB',
                    ),
                  ),
                ),
              ],
            ),
            ScrollingTVArtists(
              id: widget.tvDetails.id!,
              seasonNumber: widget.season.seasonNumber,
              passedFrom: 'seasons_detail',
              api: Endpoints.getTVSeasonCreditsUrl(
                  widget.tvDetails.id!, widget.season.seasonNumber!),
              title: 'Cast',
            ),
            EpisodeListWidget(
              seriesName: widget.seriesName,
              tvId: widget.tvDetails.id,
              api: Endpoints.getSeasonDetails(
                  widget.tvDetails.id!, widget.season.seasonNumber!),
              posterPath: widget.season.posterPath,
            ),
            TVSeasonImagesDisplay(
              title: 'Images',
              name: '${widget.seriesName}_season_${widget.season.seasonNumber}',
              api: Endpoints.getTVSeasonImagesUrl(
                  widget.tvDetails.id!, widget.season.seasonNumber!),
            ),
            // TVVideosDisplay(
            //   api: Endpoints.getTVSeasonVideosUrl(
            //       widget.tvDetails.id!, widget.season.seasonNumber!),
            //   title: 'Videos',
            // ),

            // TVCastTab(
            //   api: Endpoints.getFullTVSeasonCreditsUrl(
            //       widget.tvDetails.id!, widget.season.seasonNumber!),
            // ),
            // TVCrewTab(
            //   api: Endpoints.getFullTVSeasonCreditsUrl(
            //       widget.tvDetails.id!, widget.season.seasonNumber!),
            // ),
          ],
        ),
      ),
    );
  }
}

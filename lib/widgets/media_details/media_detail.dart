import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:netfilm/i18/app_localizations.dart';
import 'package:netfilm/model/app_model.dart';
import 'package:netfilm/model/cast.dart';
import 'package:netfilm/model/genres.dart';
import 'package:netfilm/model/mediaitem.dart';
import 'package:netfilm/model/move.dart';
import 'package:netfilm/model/video.dart';
import 'package:netfilm/util/mediaproviders.dart';
import 'package:netfilm/util/navigator.dart';
import 'package:netfilm/util/styles.dart';
import 'package:netfilm/util/utils.dart';
import 'package:netfilm/widgets/component/text_bubble.dart';
import 'package:netfilm/widgets/media_details/cast_section.dart';
import 'package:netfilm/widgets/media_details/trailer_section.dart';
import 'package:scoped_model/scoped_model.dart';

class MediaDetailScreen extends StatefulWidget {
  final MediaItem _mediaItem;
  final MediaProvider provider;

  MediaDetailScreen(this._mediaItem, this.provider);

  @override
  MediaDetailScreenState createState() {
    return MediaDetailScreenState();
  }
}

class MediaDetailScreenState extends State<MediaDetailScreen> {
  List<Actor> _actorList;
  dynamic _mediaDetails;
  List<Video> _videos;
  List<Genres> _genresIds;

  @override
  void initState() {
    super.initState();
    _loadGenres();
    _loadCast();
    _loadVideos();
    _loadDetails();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _loadGenres() async {
    try {
      List<Genres> list = await widget.provider.loadGenres();
      setState(() => _genresIds = list);
    } catch (e) {
      e.toString();
    }
  }

  void _loadCast() async {
    try {
      List<Actor> cast = await widget.provider.loadCast(widget._mediaItem.id);
      setState(() => _actorList = cast);
    } catch (e) {}
  }

  void _loadVideos() async {
    try {
      List<Video> _vvv = await widget.provider.loadVideo(widget._mediaItem.id);
      if (_vvv == null || _vvv.isEmpty) {
        return;
      }

      this._videos = new List<Video>();
      for (var item in _vvv) {
        if (item.site == 'YouTube' && item.type == 'Trailer') {
          this._videos.add(item);
        }
      }
      if (this._videos.isEmpty) {
        this._videos.add(_vvv.first);
      }
    } catch (e) {
      this._videos = [];
    }
    setState(() => {});
  }

  void _loadDetails() async {
    try {
      dynamic details = await widget.provider.getDetails(widget._mediaItem.id);
      setState(() => _mediaDetails = details);
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: primary,
        body: CustomScrollView(
          slivers: <Widget>[
            _buildAppBar(widget._mediaItem),
            _buildContentSection(widget._mediaItem),
          ],
        ));
  }

  Widget _buildAppBar(MediaItem movie) {
    return SliverAppBar(
        expandedHeight: 310.0,
        pinned: false,
        title: Text(
          widget._mediaItem.title,
          maxLines: 1,
          style: TextStyle(color: Color(0xFFEEEEEE), fontSize: 18.0),
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        ),
        actions: <Widget>[
          ScopedModelDescendant<AppModel>(
              builder: (context, child, AppModel model) => Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
                  child: IconButton(
                      icon: Icon(model.isItemFavorite(widget._mediaItem)
                          ? Icons.favorite
                          : Icons.favorite_border),
                      onPressed: () =>
                          model.toggleFavorites(widget._mediaItem)))),
        ],
        flexibleSpace: FlexibleSpaceBar(
          background: Container(
            decoration: BoxDecoration(color: primary),
            child: Column(
              children: <Widget>[
                _buildMetaSection(movie),
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                    child: TrailerSection(_videos, widget._mediaItem)),
              ],
            ),
          ),
        ));
  }

  Widget _buildMetaSection(MediaItem mediaItem) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xff222128)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 80.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection(MediaItem media) {
    return SliverList(
      delegate: SliverChildListDelegate(<Widget>[
        Container(
          decoration: BoxDecoration(color: const Color(0xff222128)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _genresIds == null
                    ? Container()
                    : Row(
                        children:
                            getGenresNameForIds2(media.genreIds, _genresIds)
                                .sublist(0, min(5, media.genreIds.length))
                                .map((genre) => Row(
                                      children: <Widget>[
                                        TextBubble(genre),
                                        Container(
                                          width: 8.0,
                                        )
                                      ],
                                    ))
                                .toList(),
                      ),
                Container(
                  height: 8.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        AppLocalizations.of(context).translate("OVERVIEW"),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Spacer(),
                    TextBubble(
                      widget._mediaItem.getReleaseYear().toString(),
                      backgroundColor: Color(0xffF47663),
                    ),
                    Container(
                      width: 8.0,
                    ),
                    TextBubble(
                      widget._mediaItem.voteAverage.toString(),
                      backgroundColor: Color(0xffF47663),
                    ),
                    Container(
                      width: 8,
                    ),
                  ],
                ),
                Container(
                  height: 8.0,
                ),
                Text(media.overview,
                    style:
                        const TextStyle(color: Colors.white, fontSize: 12.0)),
                Container(
                  height: 8.0,
                ),
                _mediaDetails == null
                    ? Container()
                    : Column(
                        children: <Widget>[
                          prepareSection(
                              AppLocalizations.of(context).translate("title"),
                              widget._mediaItem.title,
                              false),
                          prepareSection(
                              AppLocalizations.of(context).translate("status"),
                              _mediaDetails['status'] +
                                  ' (' +
                                  formatDate(_mediaDetails['release_date']) +
                                  ')',
                              false),
                          prepareSection(
                              AppLocalizations.of(context).translate("runtime"),
                              formatRuntime(_mediaDetails['runtime']),
                              false),
                          prepareSection(
                              AppLocalizations.of(context).translate("hompage"),
                              _mediaDetails['homepage'],
                              true),
                          prepareSection("Imdb",
                              getImdbUrl(_mediaDetails['imdb_id']), true),
                          prepareSection(
                              "Id", widget._mediaItem.id.toString(), false),
                        ]
                          ..add(
                            widget._mediaItem.movieIds == null
                                ? []
                                : Divider(
                                    color: salmon,
                                  ),
                          )
                          ..addAll(widget._mediaItem.movieIds.map(
                            (Movie movie) => prepareMovieSection(movie),
                          )),
                      ),
                Container(
                  height: 8.0,
                ),
              ],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(color: primary),
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _actorList == null
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : CastSection(_actorList, widget.provider)),
        ),
      ]),
    );
  }

  Widget prepareSection(String label, String value, bool isLink) {
    value = value == null ? "" : value;
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3.0),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: TextStyle(color: Colors.grey, fontSize: 11.0),
              ),
            ),
            Expanded(
              flex: 4,
              child: GestureDetector(
                onTap: () => isLink ? launchUrl(value) : null,
                child: Text(
                  value,
                  style: TextStyle(
                      color: isLink ? Colors.blue : Colors.white,
                      fontSize: 11.0),
                ),
              ),
            ),
          ],
        ));
  }

  prepareMovieSection(Movie movie) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(children: <Widget>[
        GestureDetector(
          onTap: () => goToMoviePlay(context, movie, widget._mediaItem),
          child: Icon(
            Icons.play_circle_filled,
            size: 42,
          ),
        ),
        Container(
          width: 5.0,
        ),
        Row(children: <Widget>[
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(children: <Widget>[
                  Text(
                    movie.site,
                    style: TextStyle(color: Colors.white, fontSize: 20.0),
                  ),
                  Text(
                    (movie.time == null
                        ? ""
                        : " (" + movie.time.toString() + " min.)"),
                    style: TextStyle(color: Colors.white, fontSize: 12.0),
                  ),
                ]),
                GestureDetector(
                  onTap: () => goToMoviePlay(context, movie, widget._mediaItem),
                  child: Container(
                    width: MediaQuery.of(context).size.width - 90,
                    height: 16,
                    child: Text(
                      movie.title,
                      style: TextStyle(color: Colors.white, fontSize: 12.0),
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ),
                ),
              ]),
        ]),
      ]),
    );
  }
}

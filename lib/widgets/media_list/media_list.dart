import 'package:flutter/material.dart';
import 'package:netfilm/i18/app_localizations.dart';
import 'package:netfilm/model/mediaitem.dart';
import 'package:netfilm/util/mediaproviders.dart';
import 'package:netfilm/util/utils.dart';
import 'package:netfilm/widgets/media_list/media_list_item.dart';

class MediaList extends StatefulWidget {
  MediaList(this.provider, this.sortBy, {Key key}) : super(key: key);

  final MediaProvider provider;
  final String sortBy;

  @override
  _MediaListState createState() => _MediaListState();
}

class _MediaListState extends State<MediaList> {
  List<MediaItem> _movies = List();
  int _pageNumber = 1;
  LoadingState _loadingState = LoadingState.LOADING;
  bool _isLoading = false;

  _loadNextPage() async {
    _isLoading = true;
    try {
      var nextMovies =
          await widget.provider.loadMedia(widget.sortBy, page: _pageNumber);
      setState(() {
        _loadingState = LoadingState.DONE;
        _movies.addAll(nextMovies);
        _isLoading = false;
        _pageNumber++;
      });
    } catch (e) {
      print(e);
      _isLoading = false;
      if (_loadingState == LoadingState.LOADING) {
        setState(() => _loadingState = LoadingState.ERROR);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadNextPage();
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: _getContentSection());
  }

  Widget _getContentSection() {
    switch (_loadingState) {
      case LoadingState.DONE:
        return ListView.builder(
            itemCount: _movies.length,
            itemBuilder: (BuildContext context, int index) {
              if (!_isLoading && index > (_movies.length * 0.7)) {
                _loadNextPage();
              }

              return MediaListItem(_movies[index], widget.provider);
            });
      case LoadingState.ERROR:
        return Text(AppLocalizations.of(context).translate("an_error_occured"));
      case LoadingState.LOADING:
        return CircularProgressIndicator();
      default:
        return Container();
    }
  }
}

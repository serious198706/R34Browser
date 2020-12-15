import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:r34_browser/detail_page.dart';
import 'package:r34_browser/preference_utils.dart';
import 'package:r34_browser/r34image.dart';
import 'package:r34_browser/themes.dart';
import 'package:xml/xml.dart';

class SearchResultPage extends StatefulWidget {
  final List<String> tags;

  const SearchResultPage(this.tags);

  @override
  _SearchResultPageState createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage>
    with AutomaticKeepAliveClientMixin {
  R34ImageRepository _repository;

  bool isTaped = false;
  bool changed = false;

  List<String> _tags = List();
  String _title = '';
  bool fav = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadFav();
    _tags.addAll(widget.tags);
    _title = '#' + _tags.join(' #');
    _repository = R34ImageRepository();
    _repository.setTags(_tags);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(_title, style: TextStyle(color: textColor)),
        iconTheme: IconThemeData(color: textColor),
        actions: [
          // don't show fav icon when there is more than 1 tag
          if (widget.tags.length == 1)
            IconButton(
                icon: fav ? Icon(Icons.favorite) : Icon(Icons.favorite_border),
                onPressed: _save)
        ],
      ),
      body: Stack(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: LoadingMoreList(
              ListConfig<R34Image>(
                indicatorBuilder: (_, status) {
                  if (status == IndicatorStatus.empty) {
                    return Center(
                      child: Text(
                        'No posts.',
                        style: TextStyle(color: textColor),
                      ),
                    );
                  } else if (status == IndicatorStatus.error) {
                    return Center(
                      child: Text(
                        'Error.',
                        style: TextStyle(color: textColor),
                      ),
                    );
                  } else if (status == IndicatorStatus.noMoreLoad) {
                    return Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'NO MORE POSTS',
                          style: TextStyle(color: textColor),
                        ));
                  } else {
                    return Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 1,
                        ),
                      ),
                    );
                  }
                },
                itemBuilder: _buildImage,
                sourceList: _repository,
                extendedListDelegate:
                    SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(BuildContext context, R34Image image, int index) {
    return GestureDetector(
      onTap: () async {
        var result =
            await Navigator.of(context).push(MaterialPageRoute(builder: (_) {
          var type = 0;
          if (image.fileUrl.endsWith('webm')) {
            type = 1;
          }
          return DetailPage(
              type, image.thumbnailUrl, image.fileUrl, image.tags);
        }));

        if (result != null) {
          setState(() {
            _tags.clear();
            _tags.add(result);
            changed = true;

            _repository.setTags(_tags);
            _repository.refresh(true);
          });
        }
      },
      child: Stack(
        children: [
          ExtendedImage.network(
            image.sampleUrl,
            width: MediaQuery.of(context).size.width / 2,
            fit: BoxFit.cover,
            enableLoadState: true,
            loadStateChanged: (state) {
              if (state.extendedImageLoadState == LoadState.loading) {
                return Image.network(image.thumbnailUrl);
              } else {
                return null;
              }
            },
          ),
          if (image.fileUrl.endsWith('webm'))
            Align(
                alignment: Alignment.center,
                child: Icon(Icons.play_arrow, color: Colors.white70, size: 90))
        ],
      ),
    );
  }

  void _save() async {
    List<String> saved = await getSaved();

    if (!fav) {
      for (var tag in _tags) {
        if (tag.startsWith('-')) continue;

        if (!saved.contains(tag)) {
          saved.add(tag);
        }
      }
    } else {
      for (var tag in _tags) {
        saved.remove(tag);
      }
    }

    await save(_tags);

    setState(() {
      fav = !fav;
    });
  }

  void _loadFav() async {
    List<String> saved = await getSaved();

    if (saved.isEmpty || widget.tags.isEmpty) {
      setState(() {
        fav = false;
      });
      return;
    }

    setState(() {
      fav = saved.contains(widget.tags[0]);
    });
  }
}

class R34ImageRepository extends LoadingMoreBase<R34Image> {
  int pageindex = 1;
  bool _hasMore = true;
  bool forceRefresh = false;
  String allTags = '';

  List<String> negativeTags = [
    '-mammal',
    '-fur',
    '-gay',
    '-horn',
    '-balls',
    '-feathers',
    '-feather',
    '-male_only',
  ];

  void setTags(List<String> tags) {
    tags.addAll(negativeTags);
    allTags = tags.join('+');
  }

  @override
  bool get hasMore => _hasMore || forceRefresh;

  @override
  Future<bool> refresh([bool clearBeforeRequest = false]) async {
    _hasMore = true;
    pageindex = 1;
    forceRefresh = !clearBeforeRequest;
    var result = await super.refresh(clearBeforeRequest);
    forceRefresh = false;
    return result;
  }

  @override
  Future<bool> loadData([bool isloadMoreAction = false]) async {
    String url = "";
    if (this.length == 0) {
      url =
          "https://rule34.xxx/index.php?page=dapi&tags=$allTags&s=post&limit=10&q=index&rating=explicit";
    } else {
      url =
          "https://rule34.xxx/index.php?page=dapi&tags=$allTags&s=post&limit=10&q=index&rating=explicit&pid=$pageindex";
    }

    bool isSuccess = false;

    try {
      Dio dio = Dio();
      Response<String> response = await dio.request(url);

      final document = XmlDocument.parse(response.data);
      final posts = document.findAllElements('post');

      for (var post in posts) {
        final fileUrl = post.getAttribute('file_url');
        var thumbnailUrl = post.getAttribute('preview_url');
        var sampleUrl = post.getAttribute('sample_url');
        if (sampleUrl.endsWith("webm")) {
          sampleUrl = post.getAttribute('preview_url');
        }
        final tags = post.getAttribute('tags');
        this.add(R34Image(fileUrl, thumbnailUrl, sampleUrl, tags));
      }

      _hasMore = posts.length != 0;
      pageindex++;
      isSuccess = true;
    } catch (exception, _) {
      isSuccess = false;
    }
    return isSuccess;
  }
}

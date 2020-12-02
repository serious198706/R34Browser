import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:r34_browser/detail_page.dart';
import 'package:r34_browser/themes.dart';
import 'package:xml/xml.dart';

import 'themes.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rule34',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  Animation<double> animation;
  AnimationController controller;

  List<R34Image> _images = List();
  R34ImageRepository _repository;

  bool isTaped = false;
  bool changed = false;

  List<String> _tags = List();

  IconData _appbarIcon = Icons.search;
  GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    animation = Tween(begin: 0.0, end: 100.0).animate(
      new CurvedAnimation(
        parent: controller,
        curve: new Interval(
          0.000,
          0.800,
          curve: Curves.linear,
        ),
      ),
    )..addListener(() {
        setState(() {
          // the state that has changed here is the animation object’s value
        });
      });

    // _tags.add('fireboxstudio');

    _repository = R34ImageRepository();
    _repository.setTags(_tags);

    init();
  }

  void init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await FlutterDownloader.initialize();
    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text('Rule34', style: TextStyle(color: textColor)),
        actions: [
          AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            transitionBuilder: (_, __) {
              return FadeTransition(child: _, opacity: __);
            },
            child: IconButton(
                icon: Icon(_appbarIcon, color: textColor),
                key: ValueKey<IconData>(_appbarIcon),
                onPressed: () {
                  if (!isTaped) {
                    controller.forward();
                    setState(() {
                      _appbarIcon = Icons.check;
                    });
                  } else {
                    controller.reverse();
                    setState(() {
                      _appbarIcon = Icons.search;
                    });
                    if (changed) {
                      _repository.setTags(_tags);
                      _repository.refresh(true);
                    }
                  }
                  isTaped = !isTaped;
                }),
          )
        ],
      ),
      body: Stack(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: LoadingMoreList(
              ListConfig<R34Image>(
                indicatorBuilder: (_, __) {
                  return Center(child:SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 1,)));
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
          Container(
            width: MediaQuery.of(context).size.width,
            height: animation.value,
            color: darkerPrimaryColor,
            padding: EdgeInsets.all(16),
            child: Wrap(children: _buildTags(), spacing: 8.0, runSpacing: 8.0),
          )
        ],
      ),
    );
  }

  List<Widget> _buildTags() {
    List<Widget> chips = _tags
        .map(
          (tag) => Chip(
            label: Text(tag),
            deleteIcon: Icon(Icons.remove, size: 12),
            onDeleted: () {
              setState(() {
                _tags.remove(tag);
                changed = true;
              });
            },
          ),
        )
        .toList();

    chips.add(Chip(
      label: Text('ADD'),
      deleteIcon: Icon(Icons.add, size: 12),
      onDeleted: () async {
        TextEditingController tc = TextEditingController();
        var tag = await showDialog<String>(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text('Input Tag'),
                content: TextField(
                  controller: tc,
                ),
                actions: [
                  FlatButton(
                    child: Text('CANCEL', style: TextStyle(color: Colors.grey)),
                    onPressed: () {
                      Navigator.of(context).pop('');
                    },
                  ),
                  FlatButton(
                    child: Text('ADD', style: TextStyle(color: textColor)),
                    onPressed: () {
                      if (tc.text == null || tc.text.isEmpty) {
                        return;
                      } else {
                        Navigator.of(context).pop(tc.text);
                      }
                    },
                  ),
                ],
              );
            });

        if (tag == null || tag.isEmpty) {
          return;
        }

        setState(() {
          _tags.add(tag);
          changed = true;
        });
      },
    ));

    return chips;
  }

  Widget _buildImage(BuildContext context, R34Image image, int index) {
    return GestureDetector(
      onTap: () async {
        var result = await Navigator.of(context).push(MaterialPageRoute(builder: (_) {
          return DetailPage(image.fileUrl, image.tags);
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
}

class R34Image {
  final String fileUrl;
  final String thumbnailUrl;
  final String sampleUrl;
  final String tags;

  R34Image(this.fileUrl, this.thumbnailUrl, this.sampleUrl, this.tags);
}

class R34ImageRepository extends LoadingMoreBase<R34Image> {
  int pageindex = 1;
  bool _hasMore = true;
  bool forceRefresh = false;
  String tags = '';

  void setTags(List<String> tags) {
    this.tags = tags.join('+');
  }

  @override
  bool get hasMore => _hasMore || forceRefresh;

  @override
  Future<bool> refresh([bool clearBeforeRequest = false]) async {
    _hasMore = true;
    pageindex = 1;
    //force to refresh list when you don't want clear list before request
    //for the case, if your list already has 20 items.
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
          "https://rule34.xxx/index.php?page=dapi&tags=${this.tags}&s=post&limit=10&q=index";
    } else {
      url =
          "https://rule34.xxx/index.php?page=dapi&tags=${this.tags}&s=post&limit=10&q=index&pid=${pageindex}";
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
    } catch (exception, stack) {
      isSuccess = false;
    }
    return isSuccess;
  }
}

void downloadCallback(String id, DownloadTaskStatus status, int progress) {
  if (status == DownloadTaskStatus.complete) {
    Fluttertoast.showToast(msg: 'Download complete');
  }
}

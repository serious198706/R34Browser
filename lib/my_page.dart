import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:r34_browser/gallery_page.dart';
import 'package:r34_browser/new_gallery_page.dart';
import 'package:r34_browser/themes.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> with AutomaticKeepAliveClientMixin {
  var _imageData = List<Item>();
  var _videoData = List<Item>();
  bool _loading = true;

  final List<Tab> myTabs = <Tab>[
    Tab(text: 'IMAGE'),
    Tab(text: 'VIDEO'),
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _getPreview();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: lighterPrimaryColor,
        appBar: PreferredSize(
          preferredSize: Size(MediaQuery.of(context).size.width, 60),
          child: AppBar(
            backgroundColor: lighterPrimaryColor,
            bottom: TabBar(
              tabs: myTabs,
              indicatorColor: textColor,
              indicatorSize: TabBarIndicatorSize.label,
              indicatorWeight: 3,
              indicatorPadding: EdgeInsets.only(bottom: 6),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            Stack(
              fit: StackFit.expand,
              children: [
                GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4),
                  itemCount: _imageData.length,
                  itemBuilder: _buildImageItems,
                ),
                if (_loading) Center(child: CircularProgressIndicator()),
              ],
            ),
            Stack(
              fit: StackFit.expand,
              children: [
                GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4),
                  itemCount: _videoData.length,
                  itemBuilder: _buildVideoItems,
                ),
                if (_loading) Center(child: CircularProgressIndicator()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoItems(BuildContext context, int index) {
    return Hero(
        tag: _videoData[index].filePath + index.toString(),
        child: _buildVideo(index));
  }

  Widget _buildImageItems(BuildContext context, int index) {
    return Hero(
        tag: _imageData[index].filePath + index.toString(),
        child: _buildImage(index));
  }

  Widget _buildVideo(int index) {
    return GestureDetector(
      onTap: () => _goVideo(index),
      child: FutureBuilder(
        future: _generatePreview(index),
        builder: (_, data) {
          if (data.hasData) {
            return Container(
              height: 200,
              width: 200,
              child: Stack(
                children: [
                  ExtendedImage.file(
                    File(data.data),
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    width: 200,
                    height: 200,
                    color: Colors.black.withAlpha(100),
                  ),
                  Center(
                    child: Icon(
                      Icons.play_circle_outline_rounded,
                      color: textColor,
                      size: 40,
                    ),
                  ),
                ],
              ),
            );
          } else {
            return SizedBox(
                width: 48, height: 48, child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildImage(int index) {
    return GestureDetector(
      onTap: () => _goImage(index),
      child: ExtendedImage.file(
        File(_imageData[index].filePath),
        fit: BoxFit.cover,
        height: 200,
      ),
    );
  }

  Future<String> _generatePreview(int index) async {
    Directory thumbnailPath = await getExternalStorageDirectory();
    String path = _videoData[index].filePath;
    String fileName = path.substring(path.lastIndexOf('/'));
    String thumbnailFilePath =
        thumbnailPath.path + fileName.replaceAll('webm', 'png');

    if (!File(thumbnailFilePath).existsSync()) {
      thumbnailFilePath = await VideoThumbnail.thumbnailFile(
        video: _videoData[index].filePath,
        thumbnailPath: thumbnailPath.path,
        quality: 100,
        maxHeight: 1920,
        maxWidth: 1080,
      );
    }

    _videoData[index].thumbnailFilePath = thumbnailFilePath;
    return thumbnailFilePath;
  }

  void _getPreview() async {
    var dir = Directory('/sdcard/Pictures/r34');

    List<File> tempFiles = dir.listSync().map((e) => File(e.path)).toList();
    tempFiles.sort((f1, f2) {
      return f2.lastModifiedSync().compareTo(f1.lastModifiedSync());
    });

    List videos = tempFiles.where((e) => e.path.endsWith('webm')).toList();
    List images = tempFiles.where((e) => !e.path.endsWith('webm')).toList();

    setState(() {
      _videoData = videos.map((e) => Item(e.path)).toList();
      _imageData = images.map((e) => Item(e.path)).toList();
      _loading = false;
    });
  }

  void _goImage(int index) {
    Navigator.of(context).push(TransparentMaterialPageRoute(builder: (_) {
      return FullscreenGallery(_imageData, index);
    }));
  }

  void _goVideo(int index) {
    Navigator.of(context).push(TransparentMaterialPageRoute(builder: (_) {
      return GalleryPage(_videoData[index].filePath);
    }));
  }
}

class Item {
  String filePath;
  String thumbnailFilePath;

  Item(this.filePath, [this.thumbnailFilePath]);
}

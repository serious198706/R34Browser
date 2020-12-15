import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:r34_browser/new_gallery_page.dart';
import 'package:r34_browser/themes.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> with AutomaticKeepAliveClientMixin {
  var _data = List<Item>();
  bool _loading = true;
  bool _showGallery = false;
  int _currentIndex = 0;

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

    return Scaffold(
      backgroundColor: lighterPrimaryColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, crossAxisSpacing: 4, mainAxisSpacing: 4),
            itemCount: _data.length,
            itemBuilder: _buildItems,
          ),
          if (_loading) Center(child: CircularProgressIndicator()),
          if (_showGallery) FullscreenGallery(_data, _currentIndex)
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.refresh),
          onPressed: () async {
            setState(() {
              _loading = true;
            });
            _getPreview();
          }),
    );
  }

  Widget _buildItems(BuildContext context, int index) {
    if (_data[index].type == 1) {
      return Hero(
          tag: _data[index].filePath + index.toString(),
          child: _buildVideo(index));
    } else {
      return Hero(
          tag: _data[index].filePath + index.toString(),
          child: _buildImage(index));
    }
  }

  Widget _buildVideo(int index) {
    return GestureDetector(
      onTap: () => _go(index),
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
      onTap: () => _go(index),
      child: ExtendedImage.file(
        File(_data[index].filePath),
        fit: BoxFit.cover,
        height: 200,
      ),
    );
  }

  Future<String> _generatePreview(int index) async {
    Directory thumbnailPath = await getExternalStorageDirectory();
    String path = _data[index].filePath;
    String fileName = path.substring(path.lastIndexOf('/'));
    String thumbnailFilePath =
        thumbnailPath.path + fileName.replaceAll('webm', 'png');

    if (!File(thumbnailFilePath).existsSync()) {
      thumbnailFilePath = await VideoThumbnail.thumbnailFile(
        video: _data[index].filePath,
        thumbnailPath: thumbnailPath.path,
        quality: 100,
        maxHeight: 1920,
        maxWidth: 1080,
      );
    }

    _data[index].thumbnailFilePath = thumbnailFilePath;
    return thumbnailFilePath;
  }

  void _getPreview() async {
    var dir = Directory('/sdcard/Pictures/r34');

    List<File> tempFiles = dir.listSync().map((e) => File(e.path)).toList();
    tempFiles.sort((f1, f2) {
      return f2.lastModifiedSync().compareTo(f1.lastModifiedSync());
    });

    setState(() {
      _data = tempFiles
          .map((e) => Item(e.path.endsWith('webm') ? 1 : 0, e.path))
          .toList();
      _loading = false;
    });
  }

  void _go(int index) {
    Navigator.of(context).push(TransparentMaterialPageRoute(builder: (_) {
      return FullscreenGallery(_data, index);
    }));
  }
}

class Item {
  int type;
  String filePath;
  String thumbnailFilePath;

  Item(this.type, this.filePath, [this.thumbnailFilePath]);
}

import 'package:extended_image/extended_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:r34_browser/gallery_page.dart';

import 'themes.dart';

class DetailPage extends StatefulWidget {
  final int type;
  final String thumbnailUrl;
  final String url;
  final String tags;

  const DetailPage(this.type, this.thumbnailUrl, this.url, this.tags);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> with TickerProviderStateMixin {
  List<String> _tags = List();

  double _bottomPosition = 0;

  @override
  void initState() {
    super.initState();
    _tags = widget.tags.split(' ');
    _tags.removeWhere((element) => element.isEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: primaryColor,
      body: _buildBody(),
      // appBar: AppBar(
      //   backgroundColor: primaryColor,
      // ),
    ));
  }

  Widget _buildBody() {
    // return ListView(
    //   children: [_buildImageViewer(), _buildTags()],
    // );
    return Stack(
      fit: StackFit.expand,
      children: [
        ListView(
          children: [
            widget.type == 0 ? _buildImageViewer() : _buildVideoPreview(),
            _buildTags(),
            SizedBox(height: 30)
          ],
        ),
        _buildAppBar(),
        _buildButtons(),
      ],
    );
  }

  Widget _buildAppBar() {
    return Positioned(
        left: 0,
        top: 0,
        right: 0,
        child: AppBar(backgroundColor: Colors.transparent, elevation: 0));
  }

  Widget _buildButtons() {
    return Positioned(
      child: Row(
        children: [
          Expanded(
            child: FlatButton(
              onPressed: () async {
                var path = await _findLocalPath();

                print('saving to $path');
                await FlutterDownloader.enqueue(
                    url: widget.url,
                    savedDir: path,
                    showNotification: false,
                    openFileFromNotification: false);

                Fluttertoast.showToast(msg: 'Added to download');
              },
              child: Text('DOWNLOAD'),
              textColor: textColor,
              color: primaryColor,
            ),
          )
        ],
      ),
      left: 0,
      bottom: 0,
      right: 0,
    );
  }

  Widget _buildTags() {
    return Container(
      color: primaryColor,
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TAGS', style: TextStyle(color: textColor, fontSize: 18)),
          SizedBox(height: 6),
          Container(
            width: MediaQuery.of(context).size.width,
            child: Text.rich(
              TextSpan(
                  text: '',
                  style: TextStyle(color: Colors.white),
                  children: _tags.map(_buildTag).toList()),
            ),
          )
        ],
      ),
    );
  }

  TextSpan _buildTag(String tag) {
    return TextSpan(
        text: '#$tag ',
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            Navigator.of(context).pop(tag);
          });
  }

  Widget _buildImageViewer() {
    return GestureDetector(
      onTap: _goToGallery,
      child: ExtendedImage.network(
        widget.type == 0 ? widget.url : widget.thumbnailUrl,
        width: MediaQuery.of(context).size.width,
        fit: BoxFit.fitWidth,
        cache: true,
        mode: ExtendedImageMode.gesture,
        enableSlideOutPage: true,
        enableLoadState: true,
        loadStateChanged: (state) {
          if (state.extendedImageLoadState == LoadState.loading) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Image.network(widget.thumbnailUrl),
                CircularProgressIndicator()
              ],
            );
          } else {
            return null;
          }
        },
      ),
    );
  }

  Widget _buildVideoPreview() {
    return Stack(
      children: [
        _buildImageViewer(),
        Positioned(
          right: 16,
          bottom: 16,
          child: IconButton(
              icon: Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 80,
              ),
              onPressed: _goToGallery),
        )
      ],
    );
  }

  void _goToGallery() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return GalleryPage(widget.url);
    }));
  }

  Future<String> _findLocalPath() async {
    final directory = await getExternalStorageDirectory();
    return directory.path;
  }
}

import 'package:extended_image/extended_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:r34_browser/gallery_page.dart';
import 'package:r34_browser/platform_channel.dart';
import 'package:r34_browser/search_result_page.dart';

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
  ScrollController _controller = ScrollController();
  bool _showFab = true;

  @override
  void initState() {
    super.initState();
    _tags = widget.tags.split(' ');
    _tags.removeWhere((element) => element.isEmpty);

    _controller.addListener(() {
      setState(() {
        _showFab = _controller.offset < 10;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: primaryColor,
        floatingActionButton: _showFab
            ? FloatingActionButton(
                backgroundColor: lighterPrimaryColor,
                onPressed: _download,
                child: Icon(Icons.file_download, color: textColor),
              )
            : null,
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return Stack(
      fit: StackFit.expand,
      children: [
        ListView(
          controller: _controller,
          children: [
            widget.type == 0 ? _buildImageViewer() : _buildVideoPreview(),
            _buildTags(),
            SizedBox(height: 30)
          ],
        ),
        _buildAppBar()
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
                children: _tags.map(_buildTag).toList(),
              ),
            ),
          )
        ],
      ),
    );
  }

  TextSpan _buildTag(String tag) {
    return TextSpan(
        text: '#$tag ',
        style: TextStyle(height: 2, wordSpacing: 1.5),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) {
              return SearchResultPage([tag]);
            }));
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
        enableMemoryCache: true,
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
        GestureDetector(
          onTap: _goToGallery,
          child: ExtendedImage.network(
            widget.thumbnailUrl,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.fitWidth,
            cache: true,
            enableMemoryCache: true,
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
        ),
        Positioned(
          right: 36,
          bottom: 36,
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

  void _download() {
    DownloadFile.downloadFile(widget.url);
    Fluttertoast.showToast(msg: 'Added to download');
  }

  void _goToGallery() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return GalleryPage(widget.url);
    }));
  }
}

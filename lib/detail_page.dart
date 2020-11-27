import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';

import 'themes.dart';

class DetailPage extends StatefulWidget {
  final String url;
  final String tags;

  const DetailPage(this.url, this.tags);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  VideoPlayerController _controller;
  bool _buttonsShowing = false;
  bool _isFullscreen = false;
  bool _isShowingTags = false;

  @override
  void initState() {
    super.initState();
    if (widget.url.endsWith('webm')) {
      _controller = VideoPlayerController.network(widget.url)
        ..initialize().then((value) => {setState(() {})});
      _controller.addListener(() {
        if (_controller.value.position == _controller.value.duration) {
          setState(() {
            _controller.seekTo(Duration(seconds: 0));
            _controller.pause();
            _buttonsShowing = true;
          });
        }
      });
      _controller.setLooping(true);
      _controller.play();
    }
  }

  @override
  void dispose() {
    if (_controller != null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.black, body: _buildBody());
  }

  Widget _buildBody() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _buttonsShowing = !_buttonsShowing;
        });
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.url.endsWith('webm')
              ? _buildVideoPlayer()
              : _buildImageViewer(),
          Positioned(
              left: 0,
              top: 0,
              right: 0,
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                actions: [
                  IconButton(
                    icon: Icon(Icons.info_outline),
                    onPressed: () {
                      setState(() {
                        _isShowingTags = !_isShowingTags;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.download_outlined),
                    onPressed: () async {
                      var path = await _findLocalPath();

                      print('saving to $path');
                      await FlutterDownloader.enqueue(
                          url: widget.url,
                          savedDir: path,
                          showNotification: false,
                          openFileFromNotification: false);
                    },
                  ),
                ],
              )),
          if (_isShowingTags)
            Positioned(
                top: 100,
                left: 0,
                child: Container(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(16),
                  width: MediaQuery.of(context).size.width - 32,
                  color: Colors.black45,
                  child: Expanded(
                      child: Text(
                    'TAGS: ' + widget.tags,
                    style: TextStyle(color: Colors.white),
                    maxLines: 100,
                  )),
                ))
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Center(
      child: _controller.value.initialized
          ? Stack(
              children: <Widget>[
                Center(
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                ),
                // Center(
                //   child: _ControlsOverlay(controller: _controller),
                // ),
                Positioned(
                    left: 0, bottom: 0, right: 0, child: _buildControlButtons())
              ],
            )
          : CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(
                primaryColor,
              ),
            ),
    );
  }

  Widget _buildControlButtons() {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 50),
      reverseDuration: Duration(milliseconds: 200),
      child: _buttonsShowing
          ? SizedBox.shrink()
          : Column(
              children: [
                VideoProgressIndicator(
                  _controller,
                  colors: VideoProgressColors(
                      playedColor: primaryColor, bufferedColor: Colors.white30),
                  allowScrubbing: true,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 12),
                    IconButton(
                        icon: Icon(Icons.loop,
                            color: _controller.value.isLooping
                                ? primaryColor
                                : primaryColor.withAlpha(100)),
                        onPressed: () {
                          setState(() {
                            _controller
                                .setLooping(!_controller.value.isLooping);
                          });
                        }),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.fast_rewind, color: primaryColor),
                      onPressed: () {
                        var current = _controller.value.position;
                        if (current.inSeconds > 5) {
                          _controller
                              .seekTo(Duration(seconds: current.inSeconds - 5));
                        } else {
                          _controller.seekTo(Duration(seconds: 0));
                        }
                      },
                    ),
                    SizedBox(width: 12),
                    IconButton(
                      icon: Icon(
                          _controller.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: primaryColor),
                      onPressed: () {
                        setState(() {
                          if (_controller.value.position ==
                              _controller.value.duration) {
                            _controller.seekTo(Duration(seconds: 0));
                            _controller.play();
                            _buttonsShowing = false;
                          } else {
                            if (_controller.value.isPlaying) {
                              _controller.pause();
                            } else {
                              _controller.play();
                              _buttonsShowing = false;
                            }
                          }
                        });
                      },
                    ),
                    SizedBox(width: 12),
                    IconButton(
                      icon: Icon(Icons.fast_forward, color: primaryColor),
                      onPressed: () {
                        var current = _controller.value.position;
                        if (current.inSeconds + 5 <=
                            _controller.value.duration.inSeconds) {
                          _controller
                              .seekTo(Duration(seconds: current.inSeconds + 5));
                        } else {
                          _controller.seekTo(_controller.value.duration);
                        }
                      },
                    ),
                    Spacer(),
                    IconButton(
                        icon: Icon(
                            _isFullscreen
                                ? Icons.fullscreen_exit
                                : Icons.fullscreen,
                            color: primaryColor),
                        onPressed: () {
                          setState(() {
                            _isFullscreen = !_isFullscreen;

                            if (_isFullscreen) {
                              SystemChrome.setPreferredOrientations(
                                  [DeviceOrientation.landscapeLeft]);
                              SystemChrome.setEnabledSystemUIOverlays([]);
                            } else {
                              SystemChrome.setPreferredOrientations(
                                  [DeviceOrientation.portraitUp]);
                              SystemChrome.setEnabledSystemUIOverlays(
                                  SystemUiOverlay.values);
                            }
                          });
                        }),
                    SizedBox(width: 12),
                  ],
                )
              ],
            ),
    );
  }

  Widget _buildImageViewer() {
    return ExtendedImage.network(
      widget.url,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      fit: BoxFit.fitWidth,
      cache: true,
      mode: ExtendedImageMode.gesture,
      enableSlideOutPage: true,
    );
  }

  Future<String> _findLocalPath() async {
    final directory = await getExternalStorageDirectory();
    return directory.path;
  }
}

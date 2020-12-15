import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import 'themes.dart';

class GalleryPage extends StatefulWidget {
  final String url;

  const GalleryPage(this.url);

  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage>
    with TickerProviderStateMixin {
  VideoPlayerController _controller;
  bool _buttonsShowing = false;
  bool _isFullscreen = false;
  List<String> _tags = List();

  double _bottomPosition = 0;

  @override
  void initState() {
    super.initState();
    if (widget.url.endsWith('webm') || widget.url.endsWith('mp4')) {
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

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

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
          widget.url.endsWith('webm') || widget.url.endsWith('mp4')
              ? _buildVideoPlayer()
              : _buildImageViewer(),
          Positioned(
              left: 0,
              top: 0,
              right: 0,
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
              )),
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
                                ? Colors.white
                                : Colors.white.withAlpha(100)),
                        onPressed: () {
                          setState(() {
                            _controller
                                .setLooping(!_controller.value.isLooping);
                          });
                        }),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.fast_rewind, color: Colors.white),
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
                          color: Colors.white),
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
                      icon: Icon(Icons.fast_forward, color: Colors.white),
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
                            color: Colors.white),
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
    return GestureDetector(
      onTap: () {
        setState(() {
          _bottomPosition = (_bottomPosition == 0 ? -300 : 0);
        });
      },
      child: ExtendedImage.network(
        widget.url,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        fit: BoxFit.fitWidth,
        cache: true,
        mode: ExtendedImageMode.gesture,
        enableSlideOutPage: true,
      ),
    );
  }
}

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'themes.dart';

class DetailPage extends StatefulWidget {
  final String url;

  const DetailPage(this.url);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    if (widget.url.endsWith('webm')) {
      _controller = VideoPlayerController.network(widget.url)
        ..initialize().then((value) => {setState(() {})});
      _controller.setLooping(true);
      _controller.play();
    }
    print(widget.url);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: widget.url.endsWith('webm')
          ? Center(
              child: _controller.value.initialized
                  ? _buildVideoPlayer()
                  : CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(primaryColor)))
          : ExtendedImage.network(
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

  Widget _buildVideoPlayer() {
    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          VideoPlayer(_controller),
          _ControlsOverlay(controller: _controller),
          VideoProgressIndicator(_controller, allowScrubbing: true),
        ],
      ),
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({Key key, this.controller}) : super(key: key);

  static const _examplePlaybackRates = [
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
    5.0,
    10.0,
  ];

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: Duration(milliseconds: 50),
          reverseDuration: Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
        Align(
          alignment: Alignment.topRight,
          child: PopupMenuButton<double>(
            initialValue: controller.value.playbackSpeed,
            tooltip: 'Playback speed',
            onSelected: (speed) {
              controller.setPlaybackSpeed(speed);
            },
            itemBuilder: (context) {
              return [
                for (final speed in _examplePlaybackRates)
                  PopupMenuItem(
                    value: speed,
                    child: Text('${speed}x'),
                  )
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                // Using less vertical padding as the text is also longer
                // horizontally, so it feels like it would need more spacing
                // horizontally (matching the aspect ratio of the video).
                vertical: 12,
                horizontal: 16,
              ),
              child: Text('${controller.value.playbackSpeed}x'),
            ),
          ),
        ),
      ],
    );
  }
}

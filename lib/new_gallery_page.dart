import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:r34_browser/gallery_page.dart';
import 'package:r34_browser/my_page.dart';
import 'package:r34_browser/themes.dart';

class FullscreenGallery extends StatefulWidget {
  final List<Item> data;
  final int index;

  FullscreenGallery(this.data, this.index);

  @override
  _FullscreenGalleryState createState() => _FullscreenGalleryState();
}

class _FullscreenGalleryState extends State<FullscreenGallery>
    with SingleTickerProviderStateMixin {
  var rebuildIndex = StreamController<int>.broadcast();
  var rebuildSwiper = StreamController<bool>.broadcast();
  AnimationController _animationController;
  Animation<double> _animation;
  Function animationListener;

  List<double> doubleTapScales = <double>[1.0, 2.0];

  int _currentIndex = 0;
  GlobalKey<ExtendedImageSlidePageState> slidePagekey =
      GlobalKey<ExtendedImageSlidePageState>();

  @override
  void initState() {
    _currentIndex = widget.index;
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 150), vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    rebuildIndex.close();
    rebuildSwiper.close();
    _animationController?.dispose();
    clearGestureDetailsCache();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Material(
      /// if you use ExtendedImageSlidePage and slideType =SlideType.onlyImage,
      /// make sure your page is transparent background
      color: Colors.transparent,
      shadowColor: Colors.transparent,
      child: ExtendedImageSlidePage(
        key: slidePagekey,
        slideAxis: SlideAxis.both,
        slideType: SlideType.onlyImage,
        onSlidingPage: (state) {},
        slidePageBackgroundHandler: (offset, size) {
          final Size pageSize = MediaQuery.of(context).size;
          double opacity = offset.dy.abs() / (pageSize.height / 2.0);
          return Colors.black.withOpacity(min(1.0, max(1.0 - opacity, 0.0)));
        },
        child: ExtendedImageGesturePageView.builder(
          itemCount: widget.data.length,
          itemBuilder: (context, index) {
            if (widget.data[index].type == 1) {
              return _buildVideo(index);
            } else {
              return _buildImage(index);
            }
          },
          onPageChanged: (int index) {
            _currentIndex = index;
            rebuildIndex.add(index);
          },
          controller: PageController(
            initialPage: _currentIndex,
          ),
          canMovePage: (GestureDetails gestureDetails) =>
              gestureDetails.totalScale <= 1.0,
          scrollDirection: Axis.horizontal,
          physics: ClampingScrollPhysics(),
        ),
      ),
    );
  }

  Widget _buildVideo(int index) {
    return GestureDetector(
      onTap: () => _go(widget.data[index].filePath),
      child: Container(
        color: Colors.black,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            Center(
                child: ExtendedImage.file(
                    File(widget.data[index].thumbnailFilePath),
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.cover)),
            Center(
              child: Icon(Icons.play_arrow, color: textColor, size: 80),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(int index) {
    return ExtendedImage.file(
      File(widget.data[index].filePath),
      fit: BoxFit.fitWidth,
      width: MediaQuery.of(context).size.width,
      enableSlideOutPage: true,
      mode: ExtendedImageMode.gesture,
      heroBuilderForSlidingPage: (Widget result) {
        if (index == _currentIndex) {
          return Hero(
            tag: widget.data[index].filePath + index.toString(),
            child: result,
            flightShuttleBuilder: (BuildContext flightContext,
                Animation<double> animation,
                HeroFlightDirection flightDirection,
                BuildContext fromHeroContext,
                BuildContext toHeroContext) {
              final Hero hero = flightDirection == HeroFlightDirection.pop
                  ? fromHeroContext.widget
                  : toHeroContext.widget;
              return hero.child;
            },
          );
        } else {
          return result;
        }
      },
      onDoubleTap: _doubleTap,
      initGestureConfigHandler: (state) {
        return GestureConfig(
            inPageView: true, initialScale: 1.0, cacheGesture: false);
      },
    );
  }

  void _doubleTap(ExtendedImageGestureState state) {
    ///you can use define pointerDownPosition as you can,
    ///default value is double tap pointer down postion.
    var pointerDownPosition = state.pointerDownPosition;
    double begin = state.gestureDetails.totalScale;
    double end;

    //remove old
    _animation?.removeListener(animationListener);

    //stop pre
    _animationController.stop();

    //reset to use
    _animationController.reset();

    if (begin == doubleTapScales[0]) {
      end = doubleTapScales[1];
    } else {
      end = doubleTapScales[0];
    }

    animationListener = () {
      state.handleDoubleTap(
          scale: _animation.value, doubleTapPosition: pointerDownPosition);
    };
    _animation =
        _animationController.drive(Tween<double>(begin: begin, end: end));

    _animation.addListener(animationListener);

    _animationController.forward();
  }

  void _go(String path) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return GalleryPage(path);
    }));
  }
}

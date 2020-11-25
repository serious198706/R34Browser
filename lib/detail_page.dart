import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

class DetailPage extends StatefulWidget {
  final String url;

  const DetailPage(this.url);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: ExtendedImage.network(
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

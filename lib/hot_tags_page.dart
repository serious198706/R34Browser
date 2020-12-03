import 'package:flutter/material.dart';
import 'package:r34_browser/search_result_page.dart';
import 'package:r34_browser/themes.dart';

class HotTagsPage extends StatefulWidget {
  @override
  _HotTagsPageState createState() => _HotTagsPageState();
}

class _HotTagsPageState extends State<HotTagsPage>
    with AutomaticKeepAliveClientMixin {
  List<String> _hotTags = [
    'auxtasy',
    'yeero',
    'fireboxstudio',
    'discko',
    'fpsblyck',
    'junkerz',
    'vgerotica',
    'xordel',
    'grand_cupido',
    'arti202',
    'tabesc3d',
    'volkor',
    'bewyx'
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: lighterPrimaryColor,
      body: Container(
        padding: EdgeInsets.all(16),
        child: Wrap(
          children: _buildTags(),
          spacing: 8.0,
          runSpacing: 8.0,
        ),
      ),
    );
  }

  List<Widget> _buildTags() {
    return _hotTags
        .map((tag) => GestureDetector(
              child: Chip(label: Text('#$tag')),
              onTap: () => search(tag),
            ))
        .toList();
  }

  void search(String tag) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return SearchResultPage([tag]);
    }));
  }
}

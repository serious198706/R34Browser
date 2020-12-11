import 'package:flutter/material.dart';
import 'package:r34_browser/search_result_page.dart';
import 'package:r34_browser/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HotTagsPage extends StatefulWidget {
  @override
  _HotTagsPageState createState() => _HotTagsPageState();
}

class _HotTagsPageState extends State<HotTagsPage>
    with AutomaticKeepAliveClientMixin {
  List<String> _initialhotTags = [
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
    'bewyx',
    'hydrafxx',
    'tiaz-3dx',
    'bulginsenpai'
  ];

  List<String> _hotTags = List();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _hotTags.addAll(_initialhotTags);
    _readSaved();
  }

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
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.refresh),
          onPressed: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            List<String> fav_tags = prefs.getStringList('tags');

            setState(() {
              _hotTags.clear();
              _hotTags.addAll(_initialhotTags);
              if (fav_tags != null) _hotTags.addAll(fav_tags);
            });
          }),
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

  void _readSaved() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> fav_tags = prefs.getStringList('tags');
    setState(() {
      if (fav_tags != null) _hotTags.addAll(fav_tags);
    });
  }

  void search(String tag) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return SearchResultPage([tag], true);
    }));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> fav_tags = prefs.getStringList('tags');

    setState(() {
      _hotTags.clear();
      _hotTags.addAll(_initialhotTags);
      if (fav_tags != null) _hotTags.addAll(fav_tags);
    });
  }
}

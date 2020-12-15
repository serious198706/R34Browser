import 'package:flutter/material.dart';
import 'package:r34_browser/preference_utils.dart';
import 'package:r34_browser/search_result_page.dart';
import 'package:r34_browser/themes.dart';

class HotTagsPage extends StatefulWidget {
  @override
  _HotTagsPageState createState() => _HotTagsPageState();
}

class _HotTagsPageState extends State<HotTagsPage>
    with AutomaticKeepAliveClientMixin {
  List<String> _hotTags = List();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _readSaved();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: lighterPrimaryColor,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Wrap(
            children: _buildTags(),
            spacing: 8.0,
            runSpacing: 4.0,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.refresh), onPressed: _readSaved),
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
    _hotTags.clear();
    // _hotTags.addAll(_initialhotTags);

    List<String> favTags = await getSaved();
    favTags.removeWhere((element) => element.startsWith('-'));

    setState(() {
      _hotTags.addAll(favTags);
    });

    print(_hotTags);
  }

  void search(String tag) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return SearchResultPage([tag]);
    }));

    List<String> favTags = await getSaved();
    favTags.removeWhere((element) => element.startsWith('-'));

    setState(() {
      _hotTags.clear();
      // _hotTags.addAll(_initialhotTags);
      if (favTags != null) _hotTags.addAll(favTags);
    });
  }
}

import 'package:flutter/material.dart';
import 'package:r34_browser/preference_utils.dart';
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
    'bulginsenpai',
    'shir0qq',
    'ninjartist',
    'gwen_stacy',
    'joelgraphz',
    'velocihaxor',
    'overwatch',
    'mchsuga7',
    'bifrost3d',
    'strauzek',
    'lerico213',
    'tyviania',
    'grand_cupido',
    'stukove',
    'fugtrup',
    'pewposterous',
    'lazyprocrastinator',
    'lunafreya_nox_fleuret',
    'nekoanimo',
    'sex_from_behind',
    'long_video',
    'allfs3d',
    'masqueradesfm',
    'generalbutch',
    'laosduude',
    '60fps',
    '4k',
    'blender',
    'forceballfx',
    'arhoangel',
    'sound',
    'gocrazygonsfw'
  ];

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
        child: Icon(Icons.refresh),
        onPressed: () async {
          List<String> favTags = await getSaved();
          favTags.removeWhere((element) => element.startsWith('-'));

          setState(() {
            _hotTags.clear();
            _hotTags.addAll(_initialhotTags);
            if (favTags != null) _hotTags.addAll(favTags);
          });
        },
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

  void _readSaved() async {
    _hotTags.addAll(_initialhotTags);

    List<String> favTags = await getSaved();

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

    setState(() {
      _hotTags.clear();
      _hotTags.addAll(_initialhotTags);
      if (favTags != null) _hotTags.addAll(favTags);
    });
  }
}

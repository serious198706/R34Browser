import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:r34_browser/models.dart';
import 'package:r34_browser/search_result_page.dart';
import 'package:r34_browser/themes.dart';
import 'package:r34_browser/textfield_tags.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with AutomaticKeepAliveClientMixin {
  List<String> _tags = List();
  TextEditingController _controller;
  List<Suggest> _suggest = List();
  GlobalKey<TextFieldTagsState> _key = GlobalKey<TextFieldTagsState>();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController()
      ..addListener(() {
        if (_controller.text != null && _controller.text.isNotEmpty) {
          _requestAutoComplete(_controller.text);
        } else {
          setState(() {
            _suggest.clear();
          });
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: lighterPrimaryColor,
          elevation: 0,
          toolbarHeight: 0,
        ),
        backgroundColor: lighterPrimaryColor,
        body: Center(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'ic_logo.png',
              width: MediaQuery.of(context).size.width / 2,
            ),
            SizedBox(height: 24),
            Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    color: Colors.white),
                margin: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFieldTags(
                        key: _key,
                        controller: _controller,
                        tagsStyler: TagsStyler(
                            tagDecoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4.0)),
                            ),
                            tagTextStyle: TextStyle(color: Colors.white),
                            tagCancelIcon: Icon(
                              Icons.clear,
                              color: Colors.white,
                              size: 14,
                            ),
                            tagCancelIconPadding: EdgeInsets.all(4)),
                        textFieldStyler: TextFieldStyler(
                            hintText: '',
                            helperText: '',
                            textFieldFilled: true,
                            helperStyle: TextStyle(fontSize: 0),
                            textFieldBorder: InputBorder.none,
                            textFieldFocusedBorder: InputBorder.none,
                            textFieldEnabledBorder: InputBorder.none,
                            textFieldDisabledBorder: InputBorder.none,
                            isDense: false),
                        onTag: (tag) {
                          _tags.add(tag);
                        },
                        onDelete: (tag) {
                          _tags.remove(tag);
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.search),
                      color: textColor,
                      onPressed: search,
                    )
                  ],
                )),
            if (_suggest.isNotEmpty)
              Container(
                height: 200,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    color: Colors.white),
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListView.builder(
                  itemCount: _suggest.length,
                  itemBuilder: (_, index) {
                    var item = _suggest[index];
                    return GestureDetector(
                      onTap: () {
                        _key.currentState.addTag(item.value);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(item.label),
                      ),
                    );
                  },
                ),
              )
          ],
        )));
  }

  void _requestAutoComplete(String key) async {
    String url = 'https://rule34.xxx/autocomplete.php?q=';
    Dio dio = Dio();
    Response<String> response = await dio.request(url + key);

    List<dynamic> suggest = jsonDecode(response.data);

    setState(() {
      _suggest = suggest
          .map((e) => Suggest(e['label'] as String, e['value'] as String))
          .toList();
    });
  }

  void search() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> saved = prefs.getStringList('tags');
    bool fav = true;

    for (var tag in _tags) {
      if (saved != null && !saved.contains(tag)) {
        fav = false;
        break;
      } else if (saved == null) {
        fav = false;
        break;
      }
    }

    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return SearchResultPage(_tags, fav);
    }));
  }
}

class Suggest {
  final String label;
  final String value;

  const Suggest(this.label, this.value);
}

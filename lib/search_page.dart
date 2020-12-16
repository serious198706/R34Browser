import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:r34_browser/models.dart';
import 'package:r34_browser/search_result_page.dart';
import 'package:r34_browser/themes.dart';
import 'package:r34_browser/textfield_tags.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  List<String> _tags = List();
  TextEditingController _controller;
  List<Suggest> _suggest = List();
  GlobalKey<TextFieldTagsState> _key = GlobalKey<TextFieldTagsState>();
  double _suggestBoxHeight = 0;

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
            _suggestBoxHeight = 0;
          });
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        backgroundColor: lighterPrimaryColor,
        elevation: 0,
        toolbarHeight: 0,
      ),
      backgroundColor: lighterPrimaryColor,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 48),
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
                  Expanded(child: _buildTagEdit()),
                  IconButton(
                    icon: Icon(Icons.search),
                    color: textColor,
                    onPressed: search,
                  )
                ],
              )),
          AnimatedContainer(
            duration: Duration(milliseconds: 250),
            height: _suggestBoxHeight,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                color: Colors.white),
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListView.builder(
              itemCount: _suggest.length,
              itemBuilder: (_, index) {
                var item = _suggest[index];
                return GestureDetector(
                  onTap: () => _key.currentState.addTag(item.value),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(item.label),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTagEdit() {
    return TextFieldTags(
        key: _key,
        controller: _controller,
        tagsStyler: TagsStyler(
            tagDecoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
            ),
            tagTextStyle: TextStyle(color: Colors.white),
            tagCancelIcon: Icon(Icons.clear, color: Colors.white, size: 14),
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
        onTag: (tag) => _tags.add(tag),
        onDelete: (tag) => _tags.remove(tag));
  }

  void _requestAutoComplete(String key) async {
    String url = 'https://rule34.xxx/autocomplete.php?q=';
    Dio dio = Dio();
    Response<String> response = await dio.request(url + key);

    // if there is  multiple requests, need to check if the result is fitting the input
    if (key != _controller.text) {
      return;
    }

    List<dynamic> suggest = jsonDecode(response.data);

    setState(() {
      _suggest = suggest
          .map((e) => Suggest(e['label'] as String, e['value'] as String))
          .toList();
      _suggestBoxHeight = _suggest.isEmpty ? 0 : 200;
    });
  }

  void search() async {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return SearchResultPage(_tags);
    }));
  }
}

class Suggest {
  final String label;
  final String value;

  const Suggest(this.label, this.value);
}

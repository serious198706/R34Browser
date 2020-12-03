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
    with AutomaticKeepAliveClientMixin {
  List<String> _tags = List();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
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
                color: Colors.white
              ),
              margin: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFieldTags(
                      tagsStyler: TagsStyler(
                        tagDecoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.all(Radius.circular(4.0)),
                        ),
                        tagTextStyle: TextStyle(
                          color: Colors.white
                        ),
                        tagCancelIcon: Icon(Icons.clear, color: Colors.white, size: 14,),
                        tagCancelIconPadding: EdgeInsets.all(4)
                      ),
                      textFieldStyler: TextFieldStyler(
                        hintText: '',
                        helperText: '',
                          textFieldFilled: true,
                        helperStyle: TextStyle(fontSize: 0),
                        textFieldBorder: InputBorder.none,
                        textFieldFocusedBorder: InputBorder.none,
                        textFieldEnabledBorder: InputBorder.none,
                        textFieldDisabledBorder: InputBorder.none,
                        isDense: false
                      ),
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
              )
            )
          ],
        )));
  }

  void search() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return SearchResultPage(_tags);
    }));
  }
}

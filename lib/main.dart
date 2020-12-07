import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:r34_browser/hot_tags_page.dart';
import 'package:r34_browser/my_page.dart';
import 'package:r34_browser/search_page.dart';
import 'package:r34_browser/themes.dart';

import 'themes.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rule34',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List _bottomItems = [
    {'icon': Icons.search, 'title': 'SEARCH', 'index': 0},
    {'icon': Icons.whatshot_rounded, 'title': 'HOT', 'index': 1},
    {'icon': Icons.person, 'title': 'MY', 'index': 2},
  ];

  PageController _pageController;
  int _selectedIndex = 0;
  Widget _searchPage;
  Widget _hotTagsPage;
  Widget _myPage;

  DateTime lastQuit;

  @override
  void initState() {
    super.initState();
    _searchPage = SearchPage();
    _hotTagsPage = HotTagsPage();
    _myPage = MyPage();

    _pageController = PageController(initialPage: 0, keepPage: true);

    FlutterDownloader.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        DateTime currentQuit = DateTime.now();
        if (lastQuit == null ||
            currentQuit.difference(lastQuit).inSeconds > 2) {
          lastQuit = currentQuit;
          Fluttertoast.showToast(msg: 'Press again to quit');
          return false;
        } else {
          return true;
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
          appBar: AppBar(
            brightness: Brightness.dark,
            elevation: 0.0,
            toolbarHeight: 0.0, // Hide// the AppBar
            backgroundColor: primaryColor,
          ),
          backgroundColor: primaryColor,
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: PageView.builder(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (_, position) {
                  switch (position) {
                    case 0:
                      return _searchPage;
                    case 1:
                      return _hotTagsPage;
                    case 2:
                      return _myPage;
                    default:
                      return Container(child: Text("good"));
                  }
                }),
          ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: primaryColor,
            items: _bottomItems
                .map((e) => BottomNavigationBarItem(
                    icon: Icon(e['icon'], size: 20), label: e['title']))
                .toList(),
            currentIndex: _selectedIndex,
            selectedItemColor: textColor,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }

  void _onItemTapped(int position) {
    _pageController.jumpToPage(position);
    setState(() {
      _selectedIndex = position;
    });
  }
}

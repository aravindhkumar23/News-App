import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'feed_tile.dart';
import 'keys/pass.dart';
import 'models/news_feed.dart';
import 'models/response.dart';
import 'models/serializers.dart';
import 'utils.dart';

class SearchNews extends StatefulWidget {
  @override
  _SearchNewsState createState() => _SearchNewsState();
}

class _SearchNewsState extends State<SearchNews> {
  ScrollController _scrollController = new ScrollController();
  final TextEditingController _searchTextController =
      new TextEditingController();
  final GlobalKey scaffoldKey = GlobalKey<ScaffoldState>();

  bool isLoading = false;
  bool isNextPageLoading = false;
  List<News> newsList = [];
  int newsCount = 0;
  int activePageNo = 1;
  final dio = new Dio();
  dynamic activeCountry;

  @override
  void initState() {
    getChosenCountry();
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (newsList.length < newsCount) {
          this.getNewsData(isInitialLoad: false, shouldGetNextPage: true);
        } else {}
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: scaffoldKey,
        appBar: new AppBar(
          title: new TextField(
            autofocus: true,
            textAlignVertical: TextAlignVertical.center,
            cursorColor: Colors.white,
            controller: _searchTextController,
            style: new TextStyle(
              color: Colors.white,
            ),
            decoration: new InputDecoration(
              suffix: IconButton(
                alignment: Alignment.bottomRight,
                icon: new Icon(Icons.clear, color: Colors.white),
                onPressed: () {
                  _searchTextController.clear();
                  newsList.clear();
                },
              ),
              hintText: "Search...",
              hintStyle: new TextStyle(color: Colors.white),
            ),
            onChanged: searchOperation,
          ),
        ),
        body: Container(
          child: isLoading
              ? new Center(
                  child: CircularProgressIndicator(),
                )
              : newsList.isEmpty
                  ? new Center(
                      child: Text(_searchTextController.text.isEmpty
                          ? 'Enter 3 or more character to search'
                          : 'No data found.'),
                    )
                  : new ListView.builder(
                      controller: _scrollController,
                      itemBuilder: ((BuildContext context, int index) {
                        if (index == newsList.length) {
                          return _buildProgressIndicator();
                        } else {
                          return FeedTile(
                            index: index,
                            news: newsList[index],
                          );
                        }
                      }),
                      itemCount: newsList.length,
                    ),
        ));
  }

  Future<void> getChosenCountry() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String localValue = prefs.getString('country');
    //else choose value from local storage.
    activeCountry = countries
        .where((dynamic country) => country['apiText'] == localValue)
        .first;
  }

  String _formatApiUrl() {
    return url +
        'country=${activeCountry['apiText']}' +
        '&pageSize=20' +
        '&page=$activePageNo' +
        '&q=' +
        _searchTextController.text +
        '&apiKey=' +
        apiKey;
  }

  //initial load used at 1. init state 2.category choose or reset category
  void getNewsData(
      {bool isInitialLoad = false, bool shouldGetNextPage = false}) async {
    setState(() {
      isNextPageLoading = shouldGetNextPage;
      isLoading = isInitialLoad;
      //increment page no if getting next page
      activePageNo = shouldGetNextPage ? activePageNo + 1 : 1;
    });
    try {
      print('---------->>> making api call url -> ${_formatApiUrl()}');

      final response = await dio.get(_formatApiUrl());
      final ApiResponse apiResponseObj =
          serializers.deserializeWith(ApiResponse.serializer, response.data);

      if (apiResponseObj.code != null) {
        showToast(msg: apiResponseObj.message, scaffoldKey: scaffoldKey);
      }
      if (isInitialLoad) {
        newsList.clear();
      }

      setState(() {
        isLoading = false;
        isNextPageLoading = false;
        newsCount = apiResponseObj.totalResults;
        newsList.addAll(apiResponseObj.articles);
      });
    } catch (e) {
      print('error api call ${e.toString()}');
      showToast(msg: 'Something went wrong.', scaffoldKey: scaffoldKey);
      setState(() {
        isLoading = false;
        isNextPageLoading = false;
      });
    }
  }

  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: isNextPageLoading ? 1.0 : 00,
          child: new CircularProgressIndicator(),
        ),
      ),
    );
  }

  void searchOperation(String searchText) {
    if (!isLoading &&
        _searchTextController.text.isNotEmpty &&
        _searchTextController.text.length > 3) {
      this.getNewsData(isInitialLoad: true, shouldGetNextPage: false);
    }
  }
}

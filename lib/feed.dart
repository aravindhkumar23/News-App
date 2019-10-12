import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'feed_tile.dart';
import 'keys/pass.dart';
import 'models/news_feed.dart';
import 'models/response.dart';
import 'models/serializers.dart';
import 'utils.dart';

class NewsFeed extends StatefulWidget {
  @override
  _NewsFeedState createState() => _NewsFeedState();
}

class _NewsFeedState extends State<NewsFeed> {
  ScrollController _scrollController = new ScrollController();
  final GlobalKey scaffoldKey = GlobalKey<ScaffoldState>();
  final dio = new Dio();

  //category selected index
  int _selectedIndex;
  bool isFilteredCategory = false;
  bool isLoading = true;
  bool isNextPageLoading = false;
  List<News> newsList = [];
  int newsCount = 0;
  int activePageNo = 1;
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

  Future<void> getChosenCountry() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String localValue = prefs.getString('country');
    //if local value is null pick first
    if (localValue == null) {
      await setChosenCountry(country: countries.first);
      activeCountry = countries.first;
    } else {
      //else choose value from local storage.
      activeCountry = countries
          .where((dynamic country) => country['apiText'] == localValue)
          .first;
    }
    this.getNewsData(isInitialLoad: true, shouldGetNextPage: false);
  }

  Future<void> setChosenCountry({dynamic country}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('country', country['apiText']);
    activeCountry = country;
    getNewsData(isInitialLoad: true, shouldGetNextPage: false);
  }

  String _formatApiUrl() {
    return url +
        'country=${activeCountry['apiText']}' +
        '&pageSize=20' +
        '${isFilteredCategory ? '&category=${categories[_selectedIndex]['apiText']}' : ''}' +
        '&page=$activePageNo' +
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('EECO'),
        actions: <Widget>[
          Container(
            alignment: Alignment.center,
            child: new DropdownButton<dynamic>(
              value: activeCountry,
              style: TextStyle(
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                  fontSize: 13.0),
              selectedItemBuilder: (BuildContext context) {
                return countries.map((dynamic item) {
                  return Text(
                    item['displayText'],
                  );
                }).toList();
              },
              items: countries.map(
                (dynamic country) {
                  return new DropdownMenuItem<dynamic>(
                    value: country,
                    child: new Text(
                      country['displayText'],
                      style: TextStyle(
                        color: activeCountry == country
                            ? Colors.blue
                            : Colors.black,
                      ),
                    ),
                  );
                },
              ).toList(),
              onChanged: (dynamic chosenCountry) {
                setState(() {
                  activeCountry = chosenCountry;
                });
                setChosenCountry(country: chosenCountry);
              },
              underline: new Container(),
              iconEnabledColor: Colors.white,
            ),
          ),
          new IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.of(context).pushNamed('/search');
            },
          ),
        ],
      ),
      body: new Container(
        child: new Column(
          children: <Widget>[
            Container(
              height: 50.0,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FilterChip(
                      selected: _selectedIndex == index,
                      label: Text(
                        '${categories[index]['displayText']}',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: _selectedIndex == index
                                ? FontWeight.bold
                                : FontWeight.w500),
                      ),
                      backgroundColor: categories[index]['color'],
                      selectedColor: Colors.blue,
                      checkmarkColor: Colors.white,
                      onSelected: (bool value) {
                        print("selected $index");
                        setState(() {
                          _selectedIndex =
                              _selectedIndex == index ? null : index;
                          isFilteredCategory = value;
                        });
                        getNewsData(
                            isInitialLoad: true, shouldGetNextPage: false);
                      },
                    ),
                  );
                },
              ),
            ),
            new Expanded(
              child: isLoading
                  ? new Center(
                      child: CircularProgressIndicator(),
                    )
                  : newsList.isEmpty
                      ? new Center(
                          child: Text('No recent headlines found.'),
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
            )
          ],
        ),
      ),
    );
  }
}

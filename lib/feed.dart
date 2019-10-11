import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'feed_detail.dart';
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
  int _selectedIndex;
  bool isFilteredCategory = false;
  dynamic activeCountry;

  ScrollController _scrollController = new ScrollController();

  bool isLoading = true;
  bool isNextPageLoading = false;

  List<News> newsList = [];
  int newsCount = 0;
  int activePageNo = 1;

  final dio = new Dio();

  @override
  void initState() {
    getChosenCountry();
    this.getNewsData(isInitialLoad: true, shouldGetNextPage: false);
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

  Future<dynamic> getChosenCountry() async {
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    if (true) {
//      await setChosenCountry(country: countries.first);
//    }
//    return prefs.getString('country');
    activeCountry = countries.first;
    return;
  }

  Future<void> setChosenCountry({dynamic country}) async {
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    await prefs.setString('country', country);
    activeCountry = country;
    getNewsData(isInitialLoad: true, shouldGetNextPage: false);
  }

  String _formatApiUrl() {
    return url +
        'country=${activeCountry['apiText']}' +
        '&pageSize=20' +
        '${isFilteredCategory ? 'category=${categories[_selectedIndex]['apiText']}' : ''}' +
        '&page=$activePageNo' +
        '&apiKey=' +
        apiKey;
  }

  //initial load used at 1. initstate 2.category choose or reset category
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
            onPressed: () {},
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
                  : new ListView.builder(
                      controller: _scrollController,
                      itemBuilder: ((BuildContext context, int index) {
                        if (index == newsList.length) {
                          return _buildProgressIndicator();
                        } else {
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FeedDetail(
                                          news: newsList[index],
                                          index: index,
                                        )),
                              );
                            },
                            child: new Card(
                              elevation: 3.0,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 5.0, horizontal: 20.0),
                              child: IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    new Expanded(
                                      flex: 1,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(4.0),
                                        ),
                                        child: Hero(
                                          tag: 'detail-$index',
                                          child: Image.network(
                                            getImageUrl(
                                              url: newsList[index]?.urlToImage,
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    new Expanded(
                                      flex: 3,
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                          top: 10.0,
                                          left: 10.0,
                                          right: 10.0,
                                        ),
                                        child: Column(
                                          children: <Widget>[
                                            new Text(
                                              '${newsList[index].title}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            new SizedBox(
                                              height: 4.0,
                                            ),
                                            new Text(
                                              '${newsList[index].description}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w200,
                                                fontSize: 12.0,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            new Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: <Widget>[
                                                new Expanded(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: <Widget>[
                                                      new Icon(
                                                        Icons.timer,
                                                        color: Colors.black45,
                                                        size: 15.0,
                                                      ),
                                                      new Text(
                                                        getTimeString(
                                                          date: newsList[index]
                                                              .publishedAt,
                                                        ),
                                                        style: TextStyle(
                                                            fontSize: 10.0),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.share,
                                                    color: Colors.blue,
                                                    size: 18.0,
                                                  ),
                                                  onPressed: () {
                                                    shareContent(
                                                      url: newsList[index].url,
                                                    );
                                                  },
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
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

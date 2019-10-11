import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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
  final List<Map<String, dynamic>> categories = [
    {
      'displayText': 'Business',
      'apiText': 'business',
      'color': Color(0xFF800000),
    },
    {
      'displayText': 'Entertainment',
      'apiText': 'entertainment',
      'color': Color(0xFF808000),
    },
    {
      'displayText': 'General',
      'apiText': 'general',
      'color': Color(0xFF008080),
    },
    {
      'displayText': 'Health',
      'apiText': 'health',
      'color': Color(0xFF800080),
    },
    {
      'displayText': 'Science',
      'apiText': 'science',
      'color': Color(0xFF000080),
    },
    {
      'displayText': 'Sports',
      'apiText': 'sports',
      'color': Color(0xFFCD5C5C),
    },
    {
      'displayText': 'Technology',
      'apiText': 'technology',
      'color': Color(0xFFFA8072),
    },
  ];

  int _selectedIndex;
  bool isFilteredCategory = false;

  ScrollController _scrollController = new ScrollController();

  bool isLoading = true;
  bool isNextPageLoading = false;

  List<News> newsList = [];
  int newsCount = 0;
  int activePageNo = 1;

  final dio = new Dio();

  String _formatApiUrl() {
    return url +
        'country=in&pageSize=20' +
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
      activePageNo = shouldGetNextPage ? activePageNo+1 : 1;
    });

    print(
        '---------->>> making next page api call count -> $newsCount list count ${newsList.length}');
//    return;
    try {
      print('---------->>> making api call url -> ${_formatApiUrl()}');

      final response = await dio.get(_formatApiUrl());
      final ApiResponse apiResponseObj =
          serializers.deserializeWith(ApiResponse.serializer, response.data);

      for(var object in apiResponseObj.articles){
        print('obj - ${object.title}');
      }

      if (isInitialLoad) {
        newsList.clear();
        print('-------reset array');
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

  @override
  void initState() {
    this.getNewsData(isInitialLoad: true, shouldGetNextPage: false);
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (newsList.length < newsCount) {
          this.getNewsData(isInitialLoad: false, shouldGetNextPage: true);
        } else {
          print('no further data');
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
        title: Text('News App'),
        centerTitle: true,
        actions: <Widget>[
          new IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      drawer: new Drawer(),
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
                              elevation: 1.0,
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
                                          Radius.circular(10.0),
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
                                        padding: const EdgeInsets.all(10.0),
                                        child: Column(
                                          children: <Widget>[
                                            new Text(
                                              '${index+1} = ${newsList[index].title}',
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
                                                fontWeight: FontWeight.normal,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            new Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: <Widget>[
                                                IconButton(
                                                  icon: const Icon(Icons.share),
                                                  onPressed: () {},
                                                ),
                                                new Icon(Icons.timer),
                                                new Text('10.0 am'),
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

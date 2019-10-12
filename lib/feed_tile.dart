import 'package:flutter/material.dart';
import 'package:news_app/utils.dart';

import 'feed_detail.dart';
import 'models/news_feed.dart';

class FeedTile extends StatelessWidget {
  final int index;
  final News news;

  const FeedTile({Key key, this.index, this.news}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => FeedDetail(
                    news: news,
                    index: index,
                  )),
        );
      },
      child: new Card(
        elevation: 3.0,
        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        url: news?.urlToImage,
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
                        '${news.title}',
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
                        '${news.description}',
                        style: TextStyle(
                          fontWeight: FontWeight.w200,
                          fontSize: 12.0,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      new Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          new Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                new Icon(
                                  Icons.timer,
                                  color: Colors.black45,
                                  size: 15.0,
                                ),
                                new Text(
                                  getTimeString(
                                    date: news.publishedAt,
                                  ),
                                  style: TextStyle(fontSize: 10.0),
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
                                url: news.url,
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
}

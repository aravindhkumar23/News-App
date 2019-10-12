import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'models/news_feed.dart';
import 'utils.dart';

class FeedDetail extends StatelessWidget {
  final News news;
  final int index;

  const FeedDetail({Key key, this.news, this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new GestureDetector(
        onHorizontalDragEnd: (DragEndDetails details) {
          if (details.primaryVelocity < 0) {
            launchURL(url: news.url);
          }
        },
        child: Column(
          children: <Widget>[
            new Expanded(
              child: new CustomScrollView(
                slivers: <Widget>[
                  new SliverAppBar(
                    expandedHeight: MediaQuery.of(context).size.height * 0.4,
                    pinned: true,
                    actions: <Widget>[
                      IconButton(
                        onPressed: () {
                          shareContent(
                            url: news.url,
                          );
                        },
                        icon: Icon(Icons.share),
                      )
                    ],
                    flexibleSpace: new FlexibleSpaceBar(
                      collapseMode: CollapseMode.pin,
                      background: new Hero(
                        tag: 'detail-$index',
                        child: new Image.network(
                          getImageUrl(
                            url: news.urlToImage,
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  new SliverPadding(
                    padding: const EdgeInsets.only(
                        top: 10.0, left: 10.0, right: 10.0),
                    sliver: new SliverList(
                        delegate: SliverChildListDelegate([
                      new Text(
                        news.title,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                            color: Colors.blue),
                      ),
                      new Container(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            new Text(
                              getTimeString(date: news.publishedAt),
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ),
                            new Text(' {' + news.source.name + '}')
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 16.0,
                            color: Colors.black.withOpacity(0.5),
                          ),
                          text: news.content?.split('… [')[0] ?? '',
                          children: <TextSpan>[
                            TextSpan(
                              recognizer: new TapGestureRecognizer()
                                ..onTap = () => launchURL(url: news.url),
                              text: ' ...Read more  ',
                              style: TextStyle(
                                fontWeight: FontWeight.w200,
                                fontSize: 12.0,
                                fontStyle: FontStyle.italic,
                                color: Colors.blue.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      new SizedBox(
                        height: 15.0,
                      ),
                    ])),
                  )
                ],
              ),
            ),
            new Container(
              padding: const EdgeInsets.all(10.0),
              width: double.infinity,
              color: Colors.black.withOpacity(0.5),
              child: InkWell(
                onTap: () {
                  launchURL(url: news.url);
                },
                child: new Text(
                  'Tap to know more',
                  maxLines: 1,
                  style: TextStyle(
                    fontWeight: FontWeight.w200,
                    fontSize: 12.0,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
//        body: Hero(tag: 'detail-$index', child: Container()));
  }
}

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
      body: new CustomScrollView(
        slivers: <Widget>[
          new SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            actions: <Widget>[
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.share),
              )
            ],
            flexibleSpace: new FlexibleSpaceBar(
              title: Text(news.author ?? ''),
              collapseMode: CollapseMode.pin,
              background: new Hero(
                  tag: 'detail-$index',
                  child: new Image.network(
                    getImageUrl(
                      url:news.urlToImage,
                    ),
                    fit: BoxFit.cover,
                  )),
            ),
          ),
          new SliverList(
              delegate: SliverChildListDelegate([
            new Text(news.title),
            new Text(news.description),
            new Text(news.content),
            new Text(news.url),
          ]))
        ],
      ),
    );
//        body: Hero(tag: 'detail-$index', child: Container()));
  }
}

import 'package:flutter/material.dart';
import 'package:news_app/feed.dart';

import 'search_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Set Roboto as the default app font.
          fontFamily: 'Roboto',
      ),
//      home: NewsFeed(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => NewsFeed(),
        '/search': (context) => SearchNews(),
      },
    );
  }
}

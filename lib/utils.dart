import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

String url = 'https://newsapi.org/v2/top-headlines?';

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

final List<Map<String, dynamic>> countries = [
  {
    'displayText': 'Canada',
    'apiText': 'ca',
  },
  {
    'displayText': 'China',
    'apiText': 'cn',
  },
  {
    'displayText': 'India',
    'apiText': 'in',
  },
  {
    'displayText': 'US',
    'apiText': 'us',
  },
];

String getImageUrl({String url}) {
  return url ?? 'https://picsum.photos/id/866/200/300';
}

String getTimeString({String date}) {
  final DateTime newsDate = DateTime.parse(date);
  var formatter = new DateFormat(' MMM dd, yyyy,').add_jm();
  String formatted = formatter.format(newsDate);
  return formatted;
}

void launchURL({String url}) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

void shareContent({String url}) {
  Share.share('Check out  $url');
}

void showToast({String msg, GlobalKey<ScaffoldState> scaffoldKey}) {
  scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text(msg)));
}

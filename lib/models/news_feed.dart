import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'news_feed.g.dart';

abstract class News implements Built<News, NewsBuilder> {
  factory News([NewsBuilder updates(NewsBuilder builder)]) =
      _$News;

  News._();

  @nullable
  String get author;

  @nullable
  String get title;

  @nullable
  String get description;

  @nullable
  String get url;

  @nullable
  String get urlToImage;

  @nullable
  String get publishedAt;

  @nullable
  String get content;

  static Serializer<News> get serializer => _$newsSerializer;
}

/*
        {
            "source": {
                "id": null,
                "name": "Hindustantimes.com"
            },
            "author": "Asian News International",
            "title": "Being bullied by siblings, friends increases suicidal thoughts - Hindustan Times",
            "description": "Using the Children of the 90s study, researchers have discovered that children who were bullied by siblings had more mental health issues in adulthood.",
            "url": "https://www.hindustantimes.com/more-lifestyle/being-bullied-by-siblings-friends-increases-suicidal-thoughts/story-uJMMOZR3pMJrVb4TWFNrrJ.html",
            "urlToImage": "https://www.hindustantimes.com/rf/image_size_960x540/HT/p2/2019/10/10/Pictures/_5c737456-eb43-11e9-8d06-17233a3ef1ac.jpg",
            "publishedAt": "2019-10-10T09:52:06Z",
            "content": "While depression in itself might cause people to cause self-harm or think of suicide, these thoughts become more prominent in adults in the early twenties who had been bullied at their home or school by friends or even siblings for that matter.\r\nUsing the Chi… [+1836 chars]"
        },
 */

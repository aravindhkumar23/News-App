import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:news_app/models/response.dart';
import 'package:built_collection/built_collection.dart';
import 'news_feed.dart';

part 'serializers.g.dart';

@SerializersFor(<Type>[
  //models
  News,
  ApiResponse,

])
final Serializers serializers =
(_$serializers.toBuilder()..addPlugin(new StandardJsonPlugin())).build();

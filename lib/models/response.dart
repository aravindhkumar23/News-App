import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import 'news_feed.dart';

part 'response.g.dart';

abstract class ApiResponse implements Built<ApiResponse, ApiResponseBuilder>{
  factory ApiResponse([ApiResponseBuilder updates(ApiResponseBuilder builder)]) = _$ApiResponse;

  ApiResponse._();
  String get status;
  @nullable
  String get code;
  @nullable
  String get message;

  int get totalResults;

  BuiltList<News> get articles;

  static Serializer<ApiResponse> get serializer => _$apiResponseSerializer;

}
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'countries.g.dart';

abstract class Countries implements Built<Countries, CountriesBuilder> {
  factory Countries([CountriesBuilder updates(CountriesBuilder builder)]) =
      _$Countries;

  Countries._();

  String get displayText;

  String get apiText;

  static Serializer<Countries> get serializer => _$countriesSerializer;
}

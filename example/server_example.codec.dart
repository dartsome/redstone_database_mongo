// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// SerializerGenerator
// **************************************************************************

library server_example.codec;

import 'package:serializer/core.dart' show Serializer, cleanNullInMap;
import 'package:serializer/codecs.dart';
import 'server_example.dart';

class UserCodec extends TypeCodec<User> {
  @override
  User decode(dynamic value, {Serializer serializer}) {
    User obj = new User();
    obj.id = serializer?.decode(value['_id'], type: ObjectId) ?? obj.id;
    obj.name = value['name'] as String ?? obj.name;
    obj.custom = value['custom'] as String ?? obj.custom;
    return obj;
  }

  @override
  dynamic encode(User value,
      {Serializer serializer, bool useTypeInfo, bool withTypeInfo}) {
    Map<String, dynamic> map = new Map<String, dynamic>();
    if (serializer.enableTypeInfo(useTypeInfo, withTypeInfo)) {
      map[serializer.typeInfoKey] = typeInfo;
    }
    map['_id'] = serializer?.toPrimaryObject(value.id,
        useTypeInfo: useTypeInfo, withTypeInfo: false);
    map['name'] = value.name;
    map['custom'] = value.custom;
    return cleanNullInMap(map);
  }

  @override
  String get typeInfo => 'User';
}

Map<String, TypeCodec<dynamic>> example_server_example_codecs =
    <String, TypeCodec<dynamic>>{
  'User': new UserCodec(),
};

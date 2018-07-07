# Changelog

## 0.5.0
- Align with dart 2

## 0.4.0
- Update to redstone_database_plugin 0.3.0

## 0.3.0
- Add getLastError method
- Possible encoding shortcut by passing 'null' as Type

## 0.2.0
- Update to serializer 0.5.0

**Breaking changes:**

- Use serializer_codegen for serialization
- Use a fork of redstone with updated DI

## 0.1.4
- Set serializer as private into MongoDb

## 0.1.3+1
- Remove cast on object for save, insert and insertAll (could be a Map)

## 0.1.3
- Align with serializer version 0.4.2
- Add dynamic serialization

## 0.1.2+1
- Updated object can be Map or ModifierBuilder, not only Serializable object

## 0.1.2
- Add closeConnections in MongoDbManager
- Add optional writeConcern parameter in MongoDbManager
- Add optional writeConcern parameter in MongoDBService and its atomic operations

## 0.1.1
- Implement partial update (using '$set')

## 0.1.0
- Initial version

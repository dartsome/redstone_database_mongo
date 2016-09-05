# Changelog

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

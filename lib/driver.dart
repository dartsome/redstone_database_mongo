// Copyright (c) 2016, the DartSome project authors.  Please see the AUTHORS file

import 'dart:async';

import 'package:connection_pool/connection_pool.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:serializer/core.dart';

bool isLastErrorValid(Map lastError) => lastError['ok'] == 1 && lastError['err'] == null;

bool isLastErrorDuplicateKey(Map lastError) => lastError["err"] != null && lastError["code"] == 11000;

/**
 * Wrapper for the MongoDb driver.
 *
 * This class provides helper functions for
 * enconding query parameters and decoding query
 * results using redstone_database.
 *
 */
class MongoDb {
  Serializer _serializer;
  ManagedConnection _managedConn;
  ManagedConnection get managedConn => _managedConn;

  MongoDb(this._serializer, this._managedConn);

  /// The original MongoDb connection object.
  Db get innerConn => _managedConn.conn;

  /// Get a MongoDb collection
  DbCollection collection(String collectionName) {
    return innerConn.collection(collectionName);
  }

  /**
   * Wrapper for DbCollection.find().
   *
   * [collection] is the MongoDb collection where the query will be executed,
   * and it can be a String or a DbCollection. [selector] can be a Map, a SelectorBuilder,
   * or an encodable object. The query result will be decoded to List<[type]>.
   */
  Future<List<T>> find<T>(DbCollection dbCol, Type type, [dynamic selector]) async {
    if (type == null) {
      throw ArgumentError.notNull("type");
    }

    if (selector != null && selector is! Map && selector is! SelectorBuilder) {
      selector = _serializer.toMap(selector);
    }
    var result = await dbCol.find(selector).toList();
    if (type == dynamic) {
      return new List<T>.from(_serializer.fromList(result, useTypeInfo: true));
    } else {
      return new List<T>.from(_serializer.fromList(result, type: type));
    }
  }

  /**
   * Wrapper for DbCollection.findOne().
   *
   * [collection] is the MongoDb collection where the query will be executed,
   * and it can be a String or a DbCollection. [selector] can be a Map, a SelectorBuilder,
   * or an encodable object. The query result will be decoded to an object of type [type]
   */
  Future<T> findOne<T>(DbCollection dbCol, Type type, [dynamic selector]) async {
    if (type == null) {
      throw ArgumentError.notNull("type");
    }

    if (selector != null && selector is! Map && selector is! SelectorBuilder) {
      selector = _serializer.toMap(selector);
    }
    var result = await dbCol.findOne(selector);

    if (type == dynamic) {
      return _serializer.fromMap(result, useTypeInfo: true);
    } else {
      return _serializer.fromMap(result, type: type);
    }
  }

  /**
   * Wrapper for DbCollection.save().
   *
   * [collection] is the MongoDb collection where the query will be executed,
   * and it can be a String or a DbCollection. [obj] is the object to be saved,
   * and can be a Map or an encodable object.
   */
  Future<Map<String, dynamic>> save(DbCollection dbCol, Object obj, {WriteConcern writeConcern}) {
    if (obj is! Map) {
      obj = _serializer.toMap(obj);
    }
    return dbCol.save(obj, writeConcern: writeConcern);
  }

  /**
   * Wrapper for DbCollection.insert().
   *
   * [collection] is the MongoDb collection where the query will be executed,
   * and it can be a String or a DbCollection. [obj] is the object to be inserted,
   * and can be a Map or an encodable object.
   */
  Future<Map<String, dynamic>> insert(DbCollection dbCol, Object obj, {WriteConcern writeConcern}) {
    if (obj is! Map) {
      obj = _serializer.toMap(obj);
    }
    return dbCol.insert(obj, writeConcern: writeConcern);
  }

  /**
   * Wrapper for DbCollection.insertAll().
   *
   * [collection] is the MongoDb collection where the query will be executed,
   * and it can be a String or a DbCollection. [objs] are the objects to be inserted,
   * and can be a list of maps, or a list of encodable objects.
   */
  Future<Map<String, dynamic>> insertAll(DbCollection dbCol, List objs, {WriteConcern writeConcern}) {
    return dbCol.insertAll(objs.map((obj) => _serializer.toMap(obj)).toList(), writeConcern: writeConcern);
  }

  /**
   * Wrapper for DbCollection.update().
   *
   * [collection] is the MongoDb collection where the query will be executed,
   * and it can be a String or a DbCollection. [selector] can be a Map, a SelectorBuilder,
   * or an encodable object. [update] is the object to be updated, and can be a Map, a
   * ModifierBuilder or an encodable object. If [update] is an encodable object and
   * [override] is false, then the codec will produce a ModifierBuilder, and only
   * non null fields will be updated, otherwise, the entire document will be updated.
   */
  Future<Map<String, dynamic>> update(DbCollection dbCol, dynamic selector, Object update,
      {bool override: true, bool upsert: false, bool multiUpdate: false, WriteConcern writeConcern}) {
    if (selector != null && selector is! Map && selector is! SelectorBuilder) {
      selector = _serializer.toMap(selector);
    }
    if (update != null && update is! Map && update is! ModifierBuilder) {
      update = _serializer.toMap(update);
      if (!override) {
        update = {r'$set': update};
      }
    }
    return dbCol.update(selector, update, upsert: upsert, multiUpdate: multiUpdate, writeConcern: writeConcern);
  }

  /**
   * Wrapper for DbCollection.remove().
   *
   * [collection] is the MongoDb collection where the query will be executed,
   * and it can be a String or a DbCollection. [selector] can be a Map, a SelectorBuilder,
   * or an encodable object.
   */
  Future<Map<String, dynamic>> remove(DbCollection dbCol, dynamic selector, {WriteConcern writeConcern}) {
    if (selector != null && selector is! Map && selector is! SelectorBuilder) {
      selector = _serializer.toMap(selector);
    }
    return dbCol.remove(selector, writeConcern: writeConcern);
  }

  /**
   * Wrapper for DbCollection.findAndModify().
   *
   * [collection] is the MongoDb collection where the query will be executed,
   * and it can be a String or a DbCollection. [query] can be a Map, a SelectorBuilder,
   * or an encodable object.
   */
  Future<T> findAndModify<T>(DbCollection dbCol, Type type,
      {query, sort, bool remove, update, bool returnNew, fields, bool upsert, WriteConcern writeConcern}) async {
    if (type == null) {
      throw ArgumentError.notNull("type");
    }

    if (query != null && query is! Map && query is! SelectorBuilder) {
      query = _serializer.toMap(query);
    }
    // TODO Implement WriteConcern in mongo_dart
    var result = await dbCol.findAndModify(
        query: query, sort: sort, remove: remove, update: update, returnNew: returnNew, fields: fields, upsert: upsert);

    if (type == dynamic) {
      return _serializer.fromMap(result, useTypeInfo: true);
    } else {
      return _serializer.fromMap(result, type: type);
    }
  }

  /**
   * Wrapper for DbCollection.getLastError().
   */
  Future<Map<String, dynamic>> getLastError({WriteConcern writeConcern}) => innerConn.getLastError(writeConcern);
}

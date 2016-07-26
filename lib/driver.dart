// Copyright (c) 2016, the DartSome project authors.  Please see the AUTHORS file

import 'dart:async';

import 'package:connection_pool/connection_pool.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:serializer/serializer.dart';

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
  Future<List> find(dynamic collection, Type type, [dynamic selector]) {
    var dbCol = _collection(collection);
    if (selector != null && selector is! Map && selector is! SelectorBuilder) {
      selector = _serializer.toMap(selector);
    }
    return dbCol.find(selector).toList().then((result) =>
        _serializer.fromList(result, type));
  }

  /**
   * Wrapper for DbCollection.findOne().
   *
   * [collection] is the MongoDb collection where the query will be executed,
   * and it can be a String or a DbCollection. [selector] can be a Map, a SelectorBuilder,
   * or an encodable object. The query result will be decoded to an object of type [type]
   */
  Future findOne(dynamic collection, Type type, [dynamic selector]) {
    var dbCol = _collection(collection);
    if (selector != null && selector is! Map && selector is! SelectorBuilder) {
      selector = _serializer.toMap(selector);
    }
    return dbCol.findOne(selector).then((result) =>
        _serializer.fromMap(result, type));
  }

  /**
   * Wrapper for DbCollection.save().
   *
   * [collection] is the MongoDb collection where the query will be executed,
   * and it can be a String or a DbCollection. [obj] is the object to be saved,
   * and can be a Map or an encodable object.
   */
  Future save(dynamic collection, Object obj) {
    var dbCol = _collection(collection);
    if (obj is! Map) {
      obj = _serializer.toMap(obj);
    }
    return dbCol.save(obj);
  }

  /**
   * Wrapper for DbCollection.insert().
   *
   * [collection] is the MongoDb collection where the query will be executed,
   * and it can be a String or a DbCollection. [obj] is the object to be inserted,
   * and can be a Map or an encodable object.
   */
  Future insert(dynamic collection, Object obj) async {
    DbCollection dbCol = _collection(collection);
    if (obj is! Map) {
      obj = _serializer.toMap(obj);
    }
    return dbCol.insert(obj);
  }

  /**
   * Wrapper for DbCollection.insertAll().
   *
   * [collection] is the MongoDb collection where the query will be executed,
   * and it can be a String or a DbCollection. [objs] are the objects to be inserted,
   * and can be a list of maps, or a list of encodable objects.
   */
  Future insertAll(dynamic collection, List objs) {
    var dbCol = _collection(collection);
    return dbCol.insertAll(objs.map((obj) => _serializer.toMap(obj)).toList());
  }

  /**
   * Wrapper for DbCollection.update().
   *
   * [collection] is the MongoDb collection where the query will be executed,
   * and it can be a String or a DbCollection. [selector] can be a Map, a SelectorBuilder,
   * or an encodable object. [obj] is the object to be updated, and can be a Map, a
   * ModifierBuilder or an encodable object. If [obj] is an encodable object and
   * [override] is false, then the codec will produce a ModifierBuilder, and only
   * non null fields will be updated, otherwise, the entire document will be updated.
   */
  Future update(dynamic collection, dynamic selector, Object obj,
      {bool override: true, bool upsert: false, bool multiUpdate: false}) {
    var dbCol = _collection(collection);
    if (selector != null && selector is! Map && selector is! SelectorBuilder) {
      selector = _serializer.toMap(selector);
    }
    if (obj != null && obj is! Map && obj is! ModifierBuilder) {
      obj = _serializer.toMap(obj);
      if (!override) {
        obj = { r'$set': obj };
      }
    }
    return dbCol.update(selector, obj, upsert: upsert, multiUpdate: multiUpdate);
  }

  /**
   * Wrapper for DbCollection.remove().
   *
   * [collection] is the MongoDb collection where the query will be executed,
   * and it can be a String or a DbCollection. [selector] can be a Map, a SelectorBuilder,
   * or an encodable object.
   */
  Future remove(dynamic collection, dynamic selector) {
    var dbCol = _collection(collection);
    if (selector is! Map) {
      selector = _serializer.toMap(selector);
    }
    return dbCol.remove(selector);
  }

  DbCollection _collection(collection) {
    if (collection is String) {
      collection = innerConn.collection(collection);
    }
    return collection;
  }
}

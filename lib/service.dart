// Copyright (c) 2016, the DartSome project authors.  Please see the AUTHORS file

import 'dart:async';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:redstone/redstone.dart';
import 'package:redstone_database_plugin/database.dart';

import 'driver.dart';

/**
 * Handles MongoDB operations for type T.
 *
 * Usage:
 *
 *      MongoDbService dbService = new MongoDbService<User>("users");
 *
 *      @app.Route("/services/user/list")
 *      @Encode()
 *      Future<List<User>> listUsers() => dbService.find();
 *
 *      @app.Route("/services/user/add")
 *      Future addUser(@Decode() User user) =>
 *          dbService.insert(user);
 *
 * Also, it's possible to inherit from this class:
 *
 *      @app.Group("/services/user")
 *      Class UserServices extends MongoDbService<User> {
 *
 *        UserServices() : super("users");
 *
 *        @app.Route("/list")
 *        @Encode()
 *        Future<List<User>> list() => find();
 *
 *        @app.Route("/add")
 *        Future add(@Decode() User user) => insert(user);
 *
 *      }
 *
 * By default, the service will use the database connection
 * associated with the current http request. If you are not using
 * Redstone.dart, be sure to use the [MongoDbService.fromConnection]
 * constructor to create a new service.
 *
 */
class MongoDbService<T> {
  MongoDb _mongoDb = null;

  /// The name of the MongoDB collection associated with this service
  final String collectionName;

  /// acknowledgment of write operations with various paramate
  final WriteConcern writeConcern;

  /// The MongoDB connection wrapper
  MongoDb get mongoDb =>
      _mongoDb != null ? _mongoDb : request.attributes[dbConnectionAttribute];

  /// The MongoDb connection
  Db get innerConn => mongoDb.innerConn;

  /// The MongoDB collection associated with this service
  DbCollection get collection => mongoDb.collection(collectionName);

  /**
   * Creates a new MongoDB service.
   *
   * This service will use the database connection
   * associated with the current http request.
   */
  MongoDbService(this.collectionName, {WriteConcern this.writeConcern});

  /**
   * Creates a new MongoDB service, using the provided
   * MongoDB connection.
   */
  MongoDbService.fromConnection(this._mongoDb, this.collectionName, {WriteConcern this.writeConcern});

  /**
   * Wrapper for DbCollection.find().
   *
   * [selector] can be a Map, a SelectorBuilder,
   * or an encodable object.
   */
  Future<List<T>> find([dynamic selector]) async {
    return await mongoDb.find<T>(collection, T, selector);
  }

  /**
   * Wrapper for DbCollection.findOne().
   *
   * [selector] can be a Map, a SelectorBuilder,
   * or an encodable object.
   */
  Future<T> findOne([dynamic selector]) {
    return mongoDb.findOne<T>(collection, T, selector);
  }

  /**
   * Wrapper for DbCollection.save().
   *
   * [obj] is the object to be saved.
   */
  Future<Map<String,dynamic>> save(obj, {WriteConcern writeConcern}) {
    return mongoDb.save(collection, obj, writeConcern: writeConcern ?? this.writeConcern);
  }

  /**
   * Wrapper for DbCollection.insert().
   *
   * [obj] is the object to be inserted.
   */
  Future<Map<String,dynamic>> insert(obj, {WriteConcern writeConcern}) {
    return mongoDb.insert(collection, obj, writeConcern: writeConcern ?? this.writeConcern);
  }

  /**
   * Wrapper for DbCollection.insertAll().
   *
   * [objs] are the objectes to be inserted.
   */
  Future<Map<String,dynamic>> insertAll(List objs, {WriteConcern writeConcern}) {
    return mongoDb.insertAll(collection, objs, writeConcern: writeConcern ?? this.writeConcern);
  }

  /**
   * Wrapper for DbCollection.update().
   *
   * [selector] can be a Map, a SelectorBuilder, or an encodable object.
   * [update] is the object to be updated, and can be a Map, a ModifierBuilder
   * or an encodable object. If [override] is false, then only non null fields
   * will be updated, otherwise, the entire document will be replaced.
   */
  Future<Map<String,dynamic>> update(dynamic selector, Object update, {bool override: true, bool upsert: false, bool multiUpdate: false, WriteConcern writeConcern}) {
    return mongoDb.update(collection, selector, update,
        override: override, upsert: upsert,
        multiUpdate: multiUpdate, writeConcern: writeConcern ?? this.writeConcern);
  }

  /**
   * Wrapper for DbCollection.remove().
   *
   * [selector] can be a Map, a SelectorBuilder,
   * or an encodable object.
   */
  Future<Map<String,dynamic>> remove(dynamic selector, {WriteConcern writeConcern}) {
    return mongoDb.remove(collection, selector, writeConcern: writeConcern ?? this.writeConcern);
  }

  /**
   * Wrapper for DbCollection.findAndModify().
   *
   * [query] can be a Map, a SelectorBuilder,
   * or an encodable object.
   */
  Future<T> findAndModify({query, sort, bool remove, update, bool returnNew, fields, bool upsert, WriteConcern writeConcern}) {
    return mongoDb.findAndModify<T>(collection, T, query: query, sort: sort, remove: remove, update: update, returnNew: returnNew, fields: fields, upsert: upsert, writeConcern: writeConcern ?? this.writeConcern);
  }

  /**
   * Wrapper for DbCollection.getLastError()
   */
  Future<Map<String,dynamic>> getLastError({WriteConcern writeConcern}) => mongoDb.getLastError(writeConcern: writeConcern ?? this.writeConcern);
}

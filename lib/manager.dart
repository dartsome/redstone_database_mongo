// Copyright (c) 2016, the DartSome project authors.  Please see the AUTHORS file

import 'dart:async';

import 'package:connection_pool/connection_pool.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:redstone_database_plugin/database.dart';
import 'package:serializer/serializer.dart';

import 'driver.dart';

/// Manage connections with a MongoDB instance
class MongoDbManager extends DatabaseManager<MongoDb> {
  _MongoDbPool _pool;

  /**
   * Creates a new MongoDbManager
   *
   * [uri] a MongoDB uri, and [poolSize] is the number of connections
   * that will be created.
   *
   */
  MongoDbManager(Serializer serializer, String uri, {int poolSize: 3}): super(serializer) {
    _pool = new _MongoDbPool(uri, poolSize);
  }

  void closeConnection(MongoDb connection, {error}) {
    var invalidConn = error is ConnectionException;
    _pool.releaseConnection(connection.managedConn, markAsInvalid: invalidConn);
  }

  Future<MongoDb> getConnection() {
    return _pool.getConnection().then((managedConn) => new MongoDb(serializer, managedConn));
  }
}

class _MongoDbPool extends ConnectionPool<Db> {
  String uri;

  _MongoDbPool(String this.uri, int poolSize) : super(poolSize);

  void closeConnection(Db conn) {
    conn.close();
  }

  Future<Db> openNewConnection() {
    var conn = new Db(uri);
    return conn.open().then((_) => conn);
  }
}

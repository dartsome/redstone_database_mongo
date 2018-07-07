// Copyright (c) 2016, the DartSome project authors.  Please see the AUTHORS file

import 'dart:async';

import 'package:connection_pool/connection_pool.dart';
import 'package:mongo_dart/mongo_dart.dart' hide ConnectionPool;
import 'package:redstone_database_plugin/database.dart';
import 'package:serializer/core.dart';

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
  MongoDbManager(Serializer serializer, String uri, {WriteConcern writeConcern: WriteConcern.ACKNOWLEDGED, int poolSize: 3}): super(serializer) {
    _pool = new _MongoDbPool(uri, writeConcern, poolSize);
  }

  void closeConnection(MongoDb connection, {error}) {
    var invalidConn = error is ConnectionException;
    _pool.releaseConnection(connection.managedConn, markAsInvalid: invalidConn);
  }

  Future<MongoDb> getConnection() {
    return _pool.getConnection().then((managedConn) => new MongoDb(serializer, managedConn));
  }

  Future closeConnections() {
    return _pool.closeConnections();
  }
}

class _MongoDbPool extends ConnectionPool<Db> {
  String uri;
  WriteConcern writeConcern;

  _MongoDbPool(String this.uri, WriteConcern this.writeConcern, int poolSize) : super(poolSize);

  Future<Db> openNewConnection() {
    var conn = new Db(uri);
    return conn.open(writeConcern: writeConcern).then((_) => conn);
  }

  void closeConnection(Db conn) {
    conn.close();
  }
}

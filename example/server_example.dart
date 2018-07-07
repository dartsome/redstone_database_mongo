// Copyright (c) 2016, the DartSome project authors.  Please see the AUTHORS file

import 'dart:async';
import 'dart:convert';

import 'package:bson/bson.dart';
import 'package:logging/logging.dart';
import 'package:redstone/redstone.dart' as app;
import 'package:redstone_database_mongo/manager.dart';
import 'package:redstone_database_mongo/service.dart';
import 'package:redstone_database_plugin/plugin.dart';
import 'package:serializer/codecs.dart';
import 'package:serializer/serializer.dart';

import 'server_example.codec.dart';
export 'package:bson/bson.dart';

@serializable
class User {
  @SerializedName("_id")
  ObjectId id;
  String name;
  String custom;
}

void main() {
  var serializer = new Serializer(codec: json)..addAllTypeCodecs(example_server_example_codecs);
  var dbManager = new MongoDbManager(serializer, "mongodb://localhost/test", poolSize: 3);
  app.addPlugin(getDatabasePlugin(serializer, dbManager, null));
  app.setupConsoleLog(Level.INFO);
  app.start();
}

@app.Group("")
class UsersService extends MongoDbService<User> {
  UsersService(): super("users");

  @app.Route("/users", methods: const [app.POST])
  @Encode()
  Future<User> addUser(@Decode() User user) async {
    app.redstoneLogger.info("POST /users ${user.name}");
    user.id = new ObjectId();
    await insert(user);
    return user;
  }

  @app.Route("/users", methods: const [app.GET])
  @Encode()
  Future<List<User>> getUsers() {
    app.redstoneLogger.info("GET /users");
    return find();
  }

  @app.Route("/users/:id", methods: const [app.GET])
  @Encode()
  Future<User> getUser(String id) {
    app.redstoneLogger.info("GET /users/$id");
    return findOne({"_id": new ObjectId.fromHexString(id)});
  }


  @app.Route("/users/:id", methods: const [app.POST])
  @Encode()
  Future<User> replaceUser(String id, @Decode() User user) async {
    app.redstoneLogger.info("POST /users/$id");
    await update({"_id": new ObjectId.fromHexString(id)}, user);
    return user;
  }

  @app.Route("/users/:id", methods: const [app.PUT])
  @Encode()
  Future<User> updateUser(String id, @Decode() User user) async {
    app.redstoneLogger.info("PUT /users/$id");
    await update({"_id": new ObjectId.fromHexString(id)}, user, override: false);
    return user;
  }
}

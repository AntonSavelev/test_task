import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:test_task/feature/data/models/photo_model.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();

  static Database? _database;

  String photosTable = 'Photos';
  String id = 'id';
  String albumId = 'albumId';
  String title = 'title';
  String url = 'url';
  String thumbnailUrl = 'thumbnailUrl';
  String like = 'like';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = dir.path + 'Photo.db';
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  void _createDB(Database db, int version) async {
    await db.execute(
      'CREATE TABLE $photosTable($id INTEGER PRIMARY KEY, $albumId INTEGER, $title TEXT, $url TEXT, $thumbnailUrl TEXT, $like INTEGER)',
    );
  }

  // READ
  Future<List<PhotoModel>> getPhotos() async {
    Database db = await this.database;
    final List<Map<String, dynamic>> photosMapList =
        await db.query(photosTable);
    return List.generate(photosMapList.length, (index) {
      return PhotoModel(
        id: photosMapList[index][id] as int,
        albumId: photosMapList[index][albumId] as int,
        title: photosMapList[index][title] as String,
        url: photosMapList[index][url] as String,
        thumbnailUrl: photosMapList[index][thumbnailUrl] as String,
        isLike: photosMapList[index][like] as int == 1 ? true : false,
      );
    });
  }

  // INSERT
  Future<PhotoModel> insertPhoto(PhotoModel photoModel) async {
    Database db = await this.database;
    photoModel.id = await db.insert(photosTable, photoModel.toMap());
    return photoModel;
  }

  // UPDATE
  Future<int> updatePhoto(PhotoModel photoModel) async {
    Database db = await this.database;
    return await db.update(
      photosTable,
      photoModel.toMap(),
      where: '$id = ?',
      whereArgs: [photoModel.id],
    );
  }

  // DELETE
  Future<int> deletePhotos() async {
    Database db = await this.database;
    return await db.delete(
      photosTable,
    );
  }
}


import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_task/core/error/exception.dart';
import 'package:test_task/feature/data/datasources/photo_local_data_source.dart';
import 'package:test_task/feature/data/db/database.dart';
import 'package:test_task/feature/data/models/photo_model.dart';

const CACHED_PHOTOS_LIST = 'CACHED_PHOTOS_LIST';

class PhotoLocalDataSourceImpl implements PhotoLocalDataSource {
  final SharedPreferences sharedPreferences;
  final DBProvider dbProvider;

  PhotoLocalDataSourceImpl(
      {required this.sharedPreferences, required this.dbProvider});

  // @override
  // Future<List<PhotoModel>> getLastPhotosFromCache() {
  //   final jsonPhotosList =
  //   sharedPreferences.getStringList(CACHED_PHOTOS_LIST);
  //   if (jsonPhotosList!.isNotEmpty) {
  //     print('Get Photos from Cache: ${jsonPhotosList.length}');
  //     return Future.value(jsonPhotosList
  //         .map((photo) => PhotoModel.fromJson(json.decode(photo)))
  //         .toList());
  //   } else {
  //     throw CacheException();
  //   }
  // }

  @override
  Future<List<PhotoModel>> getLastPhotosFromCache() async {
    final photosList = await dbProvider.getPhotos();
    if (photosList.isNotEmpty) {
      return photosList;
    } else {
      throw CacheException();
    }
  }

  // @override
  // Future<void> photosToCache(List<PhotoModel> photos) {
  //   final List<String> jsonPhotosList =
  //   photos.map((photo) => json.encode(photo.toJson())).toList();
  //
  //   sharedPreferences.setStringList(CACHED_PHOTOS_LIST, jsonPhotosList);
  //   print('Photos to write Cache: ${jsonPhotosList.length}');
  //   return Future.value(jsonPhotosList);
  // }

  @override
  Future<void> photosToCache(List<PhotoModel> photos) async {
    if (photos.isNotEmpty) {
      photos.forEach((photo) async {
        await dbProvider.insertPhoto(photo);
      });
    }
  }
}

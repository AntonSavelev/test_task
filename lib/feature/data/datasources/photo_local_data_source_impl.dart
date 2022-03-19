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

  @override
  Future<List<PhotoModel>> getLastPhotosFromCache() async {
    final photosList = await dbProvider.getPhotos();
    if (photosList.isNotEmpty) {
      return photosList;
    } else if (photosList.length == 0) {
      return [];
    } else {
      throw CacheException();
    }
  }

  @override
  Future<void> photosToCache(List<PhotoModel> photos) async {
    if (photos.isNotEmpty) {
      photos.forEach((photo) async {
        await dbProvider.insertPhoto(photo);
      });
    }
  }
}

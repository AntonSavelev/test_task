import 'package:test_task/feature/data/models/photo_model.dart';

abstract class PhotoLocalDataSource {
  Future<List<PhotoModel>> getLastPhotosFromCache();

  Future<void> photosToCache(List<PhotoModel> photos);

  Future<int> updatePhotoInDatabase(PhotoModel photoModel);
}

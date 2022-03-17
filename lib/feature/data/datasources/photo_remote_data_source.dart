import 'package:test_task/feature/data/models/photo_model.dart';

abstract class PhotoRemoteDataSource {
  Future<List<PhotoModel>> getAllPhotos(int page);
}
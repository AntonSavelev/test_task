import 'package:dartz/dartz.dart';
import 'package:test_task/core/error/exception.dart';
import 'package:test_task/core/error/failure.dart';
import 'package:test_task/core/platform/network_info.dart';
import 'package:test_task/feature/data/datasources/photo_local_data_source.dart';
import 'package:test_task/feature/data/datasources/photo_remote_data_source.dart';
import 'package:test_task/feature/data/models/photo_model.dart';
import 'package:test_task/feature/domain/entities/photo_entity.dart';
import 'package:test_task/feature/domain/repositories/photo_repository.dart';

class PhotoRepositoryImpl implements PhotoRepository {
  final PhotoRemoteDataSource remoteDataSource;
  final PhotoLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  PhotoRepositoryImpl(
      {required this.remoteDataSource,
      required this.localDataSource,
      required this.networkInfo});

  @override
  Future<Either<Failure, List<PhotoEntity>>> getAllPhoto(int page) async {
    return await _getPhotos(() {
      return remoteDataSource.getAllPhotos(page);
    });
  }

  Future<Either<Failure, List<PhotoModel>>> _getPhotos(
      Future<List<PhotoModel>> Function() getPhotos) async {
    if (await networkInfo.isConnected) {
      try {
        final remotePhotos = await getPhotos();
        localDataSource.photosToCache(remotePhotos);
        return Right(remotePhotos);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      try {
        final localPhotos = await localDataSource.getLastPhotosFromCache();
        return Right(localPhotos);
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }
}

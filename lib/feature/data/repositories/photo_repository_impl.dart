import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_task/common/constants.dart';
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
  final SharedPreferences sharedPreferences;

  PhotoRepositoryImpl(
      {required this.remoteDataSource,
      required this.localDataSource,
      required this.networkInfo,
      required this.sharedPreferences});

  @override
  Future<Either<Failure, List<PhotoEntity>>> getAllPhoto(int page) async {
    return await _getPhotos(() {
      return remoteDataSource.getAllPhotos(page);
    });
  }

  Future<Either<Failure, List<PhotoModel>>> _getPhotos(
      Future<List<PhotoModel>> Function() getPhotos) async {
    final isNeedToCheckCache =
        sharedPreferences.getBool(Constants.isNeedToCheckCache) ?? true;
    if (await networkInfo.isConnected) {
      try {
        if (isNeedToCheckCache) {
          await sharedPreferences.setBool(Constants.isNeedToCheckCache, false);
          final localPhotos = await localDataSource.getLastPhotosFromCache();
          if (localPhotos.length > 0) {
            return Right(localPhotos);
          } else {
            final remotePhotos = await getPhotos();
            localDataSource.photosToCache(remotePhotos);
            await pageNumberIncrease();
            return Right(remotePhotos);
          }
        } else {
          final remotePhotos = await getPhotos();
          localDataSource.photosToCache(remotePhotos);
          await pageNumberIncrease();
          return Right(remotePhotos);
        }
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      try {
        if (isNeedToCheckCache) {
          await sharedPreferences.setBool(Constants.isNeedToCheckCache, false);
          final localPhotos = await localDataSource.getLastPhotosFromCache();
          return Right(localPhotos);
        } else {
          return Right([]);
        }
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }

  Future<void> pageNumberIncrease() async {
    int page = sharedPreferences.getInt(Constants.pageNumber) ?? 1;
    page++;
    await sharedPreferences.setInt(Constants.pageNumber, page);
  }
}

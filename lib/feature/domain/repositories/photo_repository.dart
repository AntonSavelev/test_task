import 'package:dartz/dartz.dart';
import 'package:test_task/core/error/failure.dart';
import 'package:test_task/feature/domain/entities/photo_entity.dart';

abstract class PhotoRepository {
  Future<Either<Failure, List<PhotoEntity>>> getAllPhoto(int page);

  Future<Either<Failure, int>> updatePhoto(PhotoEntity photoEntity);
}

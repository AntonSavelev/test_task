import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:test_task/core/error/failure.dart';
import 'package:test_task/core/usecases/usecase.dart';
import 'package:test_task/feature/domain/entities/photo_entity.dart';
import 'package:test_task/feature/domain/repositories/photo_repository.dart';

class GetAllPhotos extends UseCase<List<PhotoEntity>, PagePhotoParams> {
  final PhotoRepository photoRepository;

  GetAllPhotos(this.photoRepository);

  @override
  Future<Either<Failure, List<PhotoEntity>>> call(
      PagePhotoParams params) async {
    return await photoRepository.getAllPhoto(params.page);
  }
}

class PagePhotoParams extends Equatable {
  final int page;

  const PagePhotoParams({required this.page});

  @override
  List<Object> get props => [page];
}
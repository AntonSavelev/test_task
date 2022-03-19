import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:test_task/core/error/failure.dart';
import 'package:test_task/core/usecases/usecase.dart';
import 'package:test_task/feature/domain/entities/photo_entity.dart';
import 'package:test_task/feature/domain/repositories/photo_repository.dart';

class UpdatePhoto extends UseCase<int, UpdatePhotoParams> {
  final PhotoRepository photoRepository;

  UpdatePhoto(this.photoRepository);

  @override
  Future<Either<Failure, int>> call(UpdatePhotoParams params) async {
    return await photoRepository.updatePhoto(params.photo);
  }
}

class UpdatePhotoParams extends Equatable {
  final PhotoEntity photo;

  const UpdatePhotoParams({required this.photo});

  @override
  List<Object> get props => [photo];
}

import 'package:equatable/equatable.dart';
import 'package:test_task/feature/domain/entities/photo_entity.dart';

abstract class PhotoState extends Equatable {
  const PhotoState();

  @override
  List<Object> get props => [];
}

class PhotoEmpty extends PhotoState {
  @override
  List<Object> get props => [];
}

class PhotoLoading extends PhotoState {
  final List<PhotoEntity> oldPhotoList;
  final bool isFirstFetch;

  const PhotoLoading(this.oldPhotoList, {this.isFirstFetch = false});

  @override
  List<Object> get props => [oldPhotoList];
}

class PhotoLoaded extends PhotoState {
  final List<PhotoEntity> photosList;

  const PhotoLoaded(this.photosList);

  @override
  List<Object> get props => [photosList];
}

class PhotoError extends PhotoState {
  final String message;

  const PhotoError({required this.message});

  @override
  List<Object> get props => [message];
}

class PhotoNoInternetConnection extends PhotoState {
  final String message;

  const PhotoNoInternetConnection({required this.message});

  @override
  List<Object> get props => [message];
}

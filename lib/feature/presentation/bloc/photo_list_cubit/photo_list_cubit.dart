import 'package:test_task/core/error/failure.dart';
import 'package:test_task/feature/domain/entities/photo_entity.dart';
import 'package:test_task/feature/domain/usecases/get_all_photos.dart';
import 'package:test_task/feature/presentation/bloc/photo_list_cubit/photo_list_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const SERVER_FAILURE_MESSAGE = 'Server Failure';
const CACHED_FAILURE_MESSAGE = 'Cache Failure';

class PhotoListCubit extends Cubit<PhotoState> {
  final GetAllPhotos getAllPhotos;

  PhotoListCubit({required this.getAllPhotos}) : super(PhotoEmpty());

  int page = 1;

  void loadPhoto() async {
    if (state is PhotoLoading) return;

    final currentState = state;

    var oldPerson = <PhotoEntity>[];
    if (currentState is PhotoLoaded) {
      oldPerson = currentState.photosList;
    }

    emit(PhotoLoading(oldPerson, isFirstFetch: page == 1));

    final failureOrPhoto = await getAllPhotos(PagePhotoParams(page: page));

    failureOrPhoto.fold(
            (error) => emit(PhotoError(message: _mapFailureToMessage(error))),
            (result) {
          page++;
          final photos = (state as PhotoLoading).oldPhotoList;
          photos.addAll(result);
          print('List length: ${photos.length.toString()}');
          emit(PhotoLoaded(photos));
        });
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return SERVER_FAILURE_MESSAGE;
      case CacheFailure:
        return CACHED_FAILURE_MESSAGE;
      default:
        return 'Unexpected Error';
    }
  }
}
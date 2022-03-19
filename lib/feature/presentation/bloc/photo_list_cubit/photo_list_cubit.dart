import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_task/common/constants.dart';
import 'package:test_task/core/error/failure.dart';
import 'package:test_task/feature/domain/entities/photo_entity.dart';
import 'package:test_task/feature/domain/usecases/get_all_photos.dart';
import 'package:test_task/feature/presentation/bloc/photo_list_cubit/photo_list_state.dart';

const SERVER_FAILURE_MESSAGE = 'Server Failure';
const CACHED_FAILURE_MESSAGE = 'Cache Failure';

class PhotoListCubit extends Cubit<PhotoState> {
  final GetAllPhotos getAllPhotos;
  final SharedPreferences sharedPreferences;

  PhotoListCubit({required this.getAllPhotos, required this.sharedPreferences})
      : super(PhotoEmpty());

  void loadPhoto() async {
    if (state is PhotoLoading) return;

    final currentState = state;
    int page = sharedPreferences.getInt(Constants.pageNumber) ?? 1;
    print('page: $page');

    var oldPerson = <PhotoEntity>[];
    if (currentState is PhotoLoaded) {
      oldPerson = currentState.photosList;
    }

    emit(PhotoLoading(oldPerson, isFirstFetch: page == 1));

    final failureOrPhoto = await getAllPhotos(PagePhotoParams(page: page));

    failureOrPhoto
        .fold((error) => emit(PhotoError(message: _mapFailureToMessage(error))),
            (result) async {
      final photos = (state as PhotoLoading).oldPhotoList;
      photos.addAll(result);
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

  void startApp() {
    sharedPreferences.setBool(Constants.isNeedToCheckCache, true);
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_task/common/constants.dart';
import 'package:test_task/core/error/failure.dart';
import 'package:test_task/feature/data/db/database.dart';
import 'package:test_task/feature/domain/entities/photo_entity.dart';
import 'package:test_task/feature/domain/usecases/get_all_photos.dart';
import 'package:test_task/feature/presentation/bloc/photo_list_cubit/photo_list_state.dart';

const SERVER_FAILURE_MESSAGE = 'Server Failure';
const CACHED_FAILURE_MESSAGE = 'Cache Failure';

class PhotoListCubit extends Cubit<PhotoState> {
  final GetAllPhotos getAllPhotos;
  final SharedPreferences sharedPreferences;
  final DBProvider dbProvider;

  PhotoListCubit(
      {required this.getAllPhotos,
      required this.sharedPreferences,
      required this.dbProvider})
      : super(PhotoEmpty());

  void loadPhoto() async {
    List<PhotoEntity> listInCash = await dbProvider.getPhotos();
    var oldPerson = <PhotoEntity>[];
    int page;
    if (listInCash.length > 0) {
      page = sharedPreferences.getInt(Constants.pageNumber)!;
      oldPerson = listInCash;
    } else {
      page = 1;
    }
    if (state is PhotoLoading) return;

    final currentState = state;

    if (currentState is PhotoLoaded) {
      oldPerson = currentState.photosList;
    }

    emit(PhotoLoading(oldPerson, isFirstFetch: page == 1));

    final failureOrPhoto = await getAllPhotos(PagePhotoParams(page: page));

    failureOrPhoto
        .fold((error) => emit(PhotoError(message: _mapFailureToMessage(error))),
            (result) async {
      page++;
      await sharedPreferences.setInt(Constants.pageNumber, page);
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
}

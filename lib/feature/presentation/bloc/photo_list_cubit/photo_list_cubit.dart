import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_task/common/constants.dart';
import 'package:test_task/core/error/failure.dart';
import 'package:test_task/feature/domain/entities/photo_entity.dart';
import 'package:test_task/feature/domain/usecases/get_all_photos.dart';
import 'package:test_task/feature/domain/usecases/update_photo.dart';
import 'package:test_task/feature/presentation/bloc/photo_list_cubit/photo_list_state.dart';

const SERVER_FAILURE_MESSAGE = 'Server Failure';
const LOCAL_DATABASE_FAILURE_MESSAGE = 'Local Database Failure';
const INTERNET_CONNECTION_MESSAGE = 'No internet connection';

class PhotoListCubit extends Cubit<PhotoState> {
  final GetAllPhotos getAllPhotos;
  final UpdatePhoto updatePhoto;
  final SharedPreferences sharedPreferences;

  PhotoListCubit(
      {required this.getAllPhotos,
      required this.sharedPreferences,
      required this.updatePhoto})
      : super(PhotoEmpty());

  void loadPhoto() async {
    if (state is PhotoLoading) return;
    final currentState = state;
    int page = sharedPreferences.getInt(Constants.pageNumber) ?? 1;
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

  void updatePhotoInDatabase(PhotoEntity photo) {
    updatePhoto.call(UpdatePhotoParams(photo: photo));
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return SERVER_FAILURE_MESSAGE;
      case LocalDatabaseFailure:
        return LOCAL_DATABASE_FAILURE_MESSAGE;
      case InternetConnectionFailure:
        return INTERNET_CONNECTION_MESSAGE;
      default:
        return 'Unexpected Error';
    }
  }

  void startApp() {
    sharedPreferences.setBool(Constants.isNeedToCheckCache, true);
  }
}

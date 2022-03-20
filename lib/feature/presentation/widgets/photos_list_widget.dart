import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_task/common/app_colors.dart';
import 'package:test_task/feature/domain/entities/photo_entity.dart';
import 'package:test_task/feature/presentation/bloc/photo_list_cubit/photo_list_cubit.dart';
import 'package:test_task/feature/presentation/bloc/photo_list_cubit/photo_list_state.dart';
import 'package:test_task/feature/presentation/widgets/photo_card_widget.dart';

class PhotosList extends StatefulWidget {
  PhotosList({Key? key, required this.scaffoldKey}) : super(key: key);
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  _PhotosListState createState() => _PhotosListState();
}

class _PhotosListState extends State<PhotosList> {
  final scrollController = ScrollController();

  final int page = -1;
  List<PhotoEntity> _photos = [];

  @override
  void initState() {
    context.read<PhotoListCubit>().startApp();
    super.initState();
  }

  void setupScrollController(BuildContext context) {
    scrollController.addListener(() {
      if (scrollController.position.atEdge) {
        if (scrollController.position.pixels != 0) {
          context.read<PhotoListCubit>().loadPhoto();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    context.read<PhotoListCubit>().loadPhoto();
    setupScrollController(context);

    bool _isLoading = false;
    bool _isInternetConnectionAvailable = true;
    return BlocConsumer<PhotoListCubit, PhotoState>(listener: (context, state) {
      if (state is PhotoNoInternetConnection) {
        _isInternetConnectionAvailable = false;
        _showSnackBar(state.message);
      }
    }, builder: (context, state) {
      if (state is PhotoLoading && state.isFirstFetch) {
        return _loadingIndicator();
      } else if (state is PhotoLoading) {
        _photos = state.oldPhotoList;
        _isLoading = true;
      } else if (state is PhotoLoaded) {
        _photos = state.photosList;
      } else if (state is PhotoError) {
        return Center(
          child: Text(
            state.message,
            style: const TextStyle(color: Colors.white, fontSize: 25),
          ),
        );
      }
      return ListView.separated(
        controller: scrollController,
        itemBuilder: (context, index) {
          if (index < _photos.length) {
            return PhotoCard(
              photo: _photos[index],
              onTap: (isLike) =>
                  onLikeButtonTapped(isLike, _photos[index], index),
            );
          } else {
            Timer(const Duration(milliseconds: 30), () {
              scrollController
                  .jumpTo(scrollController.position.maxScrollExtent);
            });
            return _isInternetConnectionAvailable
                ? _loadingIndicator()
                : Container();
          }
        },
        separatorBuilder: (context, index) {
          return Divider(
            color: Colors.grey[400],
          );
        },
        itemCount: _photos.length + (_isLoading ? 1 : 0),
      );
    });
  }

  Widget _loadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  _showSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(color: AppColors.greyColor),
      ),
      backgroundColor: AppColors.mainBackground,
    );
    ScaffoldMessenger.of(widget.scaffoldKey.currentContext!)
        .showSnackBar(snackBar);
  }

  Future<bool> onLikeButtonTapped(
      bool isLiked, PhotoEntity photo, int index) async {
    photo.isLike = !photo.isLike;
    _photos[index] = photo;
    context.read<PhotoListCubit>().updatePhotoInDatabase(photo);
    return !isLiked;
  }
}

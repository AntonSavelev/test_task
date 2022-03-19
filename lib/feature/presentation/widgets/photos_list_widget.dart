import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_task/feature/domain/entities/photo_entity.dart';
import 'package:test_task/feature/presentation/bloc/photo_list_cubit/photo_list_cubit.dart';
import 'package:test_task/feature/presentation/bloc/photo_list_cubit/photo_list_state.dart';
import 'package:test_task/feature/presentation/widgets/photo_card_widget.dart';

class PhotosList extends StatefulWidget {
  PhotosList({Key? key}) : super(key: key);

  @override
  _PhotosListState createState() => _PhotosListState();
}

class _PhotosListState extends State<PhotosList> {
  final scrollController = ScrollController();

  final int page = -1;
  List<PhotoEntity> photos = [];

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

    bool isLoading = false;
    return BlocBuilder<PhotoListCubit, PhotoState>(builder: (context, state) {
      if (state is PhotoLoading && state.isFirstFetch) {
        return _loadingIndicator();
      } else if (state is PhotoLoading) {
        photos = state.oldPhotoList;
        isLoading = true;
      } else if (state is PhotoLoaded) {
        photos = state.photosList;
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
          if (index < photos.length) {
            return PhotoCard(
              photo: photos[index],
              onTap: (isLike) =>
                  onLikeButtonTapped(isLike, photos[index], index),
            );
          } else {
            Timer(const Duration(milliseconds: 30), () {
              scrollController
                  .jumpTo(scrollController.position.maxScrollExtent);
            });
            return _loadingIndicator();
          }
        },
        separatorBuilder: (context, index) {
          return Divider(
            color: Colors.grey[400],
          );
        },
        itemCount: photos.length + (isLoading ? 1 : 0),
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

  Future<bool> onLikeButtonTapped(
      bool isLiked, PhotoEntity photo, int index) async {
    photo.isLike = !photo.isLike;
    photos[index] = photo;
    context.read<PhotoListCubit>().updatePhotoInDatabase(photo);
    return !isLiked;
  }
}

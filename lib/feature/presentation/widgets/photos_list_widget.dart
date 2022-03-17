import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_task/feature/domain/entities/photo_entity.dart';
import 'package:test_task/feature/presentation/bloc/photo_list_cubit/photo_list_cubit.dart';
import 'package:test_task/feature/presentation/bloc/photo_list_cubit/photo_list_state.dart';
import 'package:test_task/feature/presentation/widgets/photo_card_widget.dart';

class PhotosList extends StatelessWidget {
  final scrollController = ScrollController();
  final int page = -1;

  PhotosList({Key? key}) : super(key: key);

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
    setupScrollController(context);
    List<PhotoEntity> photos = [];
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
            return PhotoCard(photo: photos[index]);
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
}

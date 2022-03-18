import 'package:equatable/equatable.dart';

class PhotoEntity extends Equatable {
  int albumId;
  int id;
  String title;
  String url;
  String thumbnailUrl;
  bool isLike = false;

  PhotoEntity({
    required this.albumId,
    required this.id,
    required this.title,
    required this.url,
    required this.thumbnailUrl,
    required this.isLike,
  });

  @override
  List<Object?> get props => [albumId, id, title, url, thumbnailUrl, isLike];
}


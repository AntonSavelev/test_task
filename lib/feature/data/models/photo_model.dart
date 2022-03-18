import 'dart:core';

import 'package:test_task/feature/domain/entities/photo_entity.dart';

class PhotoModel extends PhotoEntity {
  PhotoModel({
    albumId,
    id,
    title,
    url,
    thumbnailUrl,
    isLike,
  }) : super(
            albumId: albumId,
            id: id,
            title: title,
            url: url,
            thumbnailUrl: thumbnailUrl,
            isLike: isLike);

  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    return PhotoModel(
      albumId: json['albumId'],
      id: json['id'],
      title: json['title'],
      url: json['url'],
      thumbnailUrl: json['thumbnailUrl'],
      isLike: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'albumId': albumId,
      'id': id,
      'title': title,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'isLike': isLike ? 1 : 0,
    };
  }

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      'albumId': albumId,
      'id': id,
      'title': title,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'like': isLike ? 1 : 0,
    };
    return map;
  }
}

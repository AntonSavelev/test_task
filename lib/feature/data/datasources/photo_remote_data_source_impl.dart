import 'dart:convert';

import 'package:test_task/core/error/exception.dart';
import 'package:test_task/feature/data/datasources/photo_remote_data_source.dart';
import 'package:test_task/feature/data/models/photo_model.dart';
import 'package:http/http.dart' as http;

const LIMIT = 20;

class PhotoRemoteDataSourceImpl implements PhotoRemoteDataSource {
  final http.Client client;

  PhotoRemoteDataSourceImpl({required this.client});

  @override
  Future<List<PhotoModel>> getAllPhotos(int page) => _getPhotoFromUrl('https://jsonplaceholder.typicode.com/photos?_page=$page&_limit=$LIMIT');

  Future<List<PhotoModel>> _getPhotoFromUrl(String url) async {
    final response = await client.get(Uri.parse(url), headers: {'Content-type': 'application/json; charset=UTF-8'});
    if (response.statusCode == 200) {
      final photos = json.decode(response.body);
      return (photos as List).map((photo) => PhotoModel.fromJson(photo)).toList();
    } else {
      throw ServerException();
    }
  }
  
}
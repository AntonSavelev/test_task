import 'package:flutter/material.dart';
import 'package:test_task/feature/presentation/widgets/photos_list_widget.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photos'),
        centerTitle: true,
      ),
      body: PhotosList(),
    );
  }
}

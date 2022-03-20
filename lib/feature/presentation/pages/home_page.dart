import 'package:flutter/material.dart';
import 'package:test_task/feature/presentation/widgets/photos_list_widget.dart';

class HomePage extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Photos'),
        centerTitle: true,
      ),
      body: PhotosList(
        scaffoldKey: scaffoldKey,
      ),
    );
  }
}

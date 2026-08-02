import 'package:flutter/material.dart';

class GalleryBody extends StatefulWidget {
  const GalleryBody({Key? key}) : super(key: key);

  @override
  _GalleryBodyState createState() => _GalleryBodyState();
}

class _GalleryBodyState extends State<GalleryBody> {
  late List<Widget> models;

  @override
  void initState() {
    super.initState();
    models = [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Service Image/Sample 1'),
        ),
      ),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Service Image/Sample 2'),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: models,
    );
  }
}

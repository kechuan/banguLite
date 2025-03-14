import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

@FFRoute(name: '/photoView')

class BangumiPictureViewPage extends StatelessWidget {
  const BangumiPictureViewPage({
    super.key,
    required this.imageProvider
  });

  final ImageProvider imageProvider;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ScalableText("图片查看"),
        backgroundColor: Colors.transparent,
      ),
      body: PhotoView(
        
        minScale: 0.1,
        maxScale: PhotoViewComputedScale.covered,
        imageProvider: imageProvider
      ),
    );
  }
}
import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/internal/utils/convert.dart';
import 'package:bangu_lite/internal/custom_bbcode_tag.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';

@FFRoute(name: '/commentPreview')
class SendCommentPreview extends StatelessWidget {
  const SendCommentPreview({
    super.key,
    required this.renderText,
  });

  final String renderText;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text('预览')),
      body: Padding(
        padding: Padding16,
        child: BBCodeText(
          data: convertBangumiCommentSticker(renderText),
          stylesheet: appDefaultStyleSheet(context)
        ),
      ),


    );
  }
}
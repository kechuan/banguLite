import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/internal/utils/convert.dart';
import 'package:bangu_lite/internal/custom_bbcode_tag.dart';
import 'package:bangu_lite/widgets/components/custom_bbcode_text.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';

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
      body: EasyRefresh(
        child: SizedBox.expand(
          child: Padding(
            padding: Padding16,
            child: SingleChildScrollView(
              child: AdapterBBCodeText(
                data: convertBangumiCommentSticker(renderText),
                stylesheet: appDefaultStyleSheet(context)
              ),
            ),
          ),
        ),
      ),


    );
  }
}
import 'package:flutter/widgets.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';

import 'package:bbob_dart/bbob_dart.dart' as bbob;
import 'package:flutter_bbcode/src/default_tags/widgets/spoiler_widget.dart';

class MaskTag extends WrappedStyleTag {
  MaskTag() : super("mask");

  @override
  List<InlineSpan> wrap(FlutterRenderer renderer, bbob.Element element, List<InlineSpan> spans) {
    late String text;
    if (element.attributes.isNotEmpty) {
      text = "mask: ${element.attributes.values.join(' ')}";
    } 
    
    else {
      text = "mask";
    }

    return [
      WidgetSpan(
          child: SpoilerDisplay(
            spoilerText: text,
            content: spans,
            selectable: renderer.stylesheet.selectableText,
          ))
    ];
  }
}

class BangumiStickerTag extends AdvancedTag{

  BangumiStickerTag() : super("sticker");

  @override
  List<InlineSpan> parse(FlutterRenderer renderer, bbob.Element element) {
    if (element.children.isEmpty) {
      return [TextSpan(text: "[$tag]")];
    }

    // Image URL is the first child / node. If not, that's an issue for the person writing
    // the BBCode.
    String imageUrl = element.children.first.textContent;

    final image = Image.asset(
		imageUrl,
		scale: 0.8,
        errorBuilder: (context, error, stack) => Text("[$tag]")
	);

    if (renderer.peekTapAction() != null) {
      return [
        WidgetSpan(
            child: GestureDetector(
          onTap: renderer.peekTapAction(),
          child: image,
        ))
      ];
    }

    return [
      WidgetSpan(
        child: image,
      )
    ];
  }

}

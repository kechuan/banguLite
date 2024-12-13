
import 'package:bangu_lite/widgets/fragments/comment_image_panel.dart';
import 'package:bangu_lite/widgets/fragments/unvisible_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';

import 'package:bbob_dart/bbob_dart.dart' as bbob;

final allEffectTag = [
	BoldTag(),
	ItalicTag(),
	UnderlineTag(),
	StrikeThroughTag(),
	ColorTag(),
	SizeTag(),
	//ImgTag(),
	LateLoadImgTag(),
	UrlTag(),
	QuoteTag(),
	LeftAlignTag(),
	CenterAlignTag(),
	RightAlignTag(),
	MaskTag(),
	BangumiStickerTag()
];

class MaskDisplay extends StatelessWidget {
  final String spoilerText;
  final List<InlineSpan> content;
  final bool selectable;

  	const MaskDisplay({
		super.key,
		required this.spoilerText,
		required this.content,
	
		this.selectable = true
	});

  @override
  Widget build(BuildContext context) {

	ValueNotifier<bool> activedNotifier = ValueNotifier<bool>(false);

	return UnVisibleResponse(
		onTap: () => activedNotifier.value = true,
		  child: MouseRegion(
			onEnter: (event) => activedNotifier.value = true,
			onExit: (event) => activedNotifier.value = false,
			child: ValueListenableBuilder(
					valueListenable: activedNotifier,
					builder: (_,activedStatus,__) {
		  
						return ColoredBox(
							color: Colors.black,
							child: 
								TweenAnimationBuilder<Color?>(
									duration: const Duration(milliseconds: 300),
									tween: ColorTween(
										begin: Colors.black,
										end: activedStatus ? Colors.white : Colors.black,
									),
		  
									builder: (_,color,__){
										//MergeStyle
										List<InlineSpan> newInlineSpan = content.map(
												(currentSpan){
													return TextSpan(
														text: currentSpan.toPlainText(),
														style: currentSpan.style!.merge(TextStyle(color: color)),
													);
												}
											).toList();
		  
										return selectable ? 
										SelectableText.rich(TextSpan(children: newInlineSpan)) :
										RichText(text: TextSpan(children: newInlineSpan));
									}
								)
							
						);
					}
			  ),
			),
		);
  
  }
}

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
			child: MaskDisplay(
				spoilerText: text,
				content: spans,
				selectable: renderer.stylesheet.selectableText,
			)
		)
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

    String imageUrl = element.children.first.textContent;

    final image = Image.asset(
		imageUrl,
		scale: 0.8,
        errorBuilder: (context, error, stack) => Text("[$tag]")
	);

    return [
      WidgetSpan(
        child: image,
      )
    ];
  }

}

class LateLoadImgTag extends AdvancedTag {
  LateLoadImgTag() : super("img");

  @override
  List<InlineSpan> parse(FlutterRenderer renderer, bbob.Element element) {
    if (element.children.isEmpty) {
      return [TextSpan(text: "[$tag]")];
    }

    String imageUri = element.children.first.textContent;

	//debugPrint("lateLoad textContent:${imageUri}");
	//目标: 只获取图片大小 并显示成一个Widget 直到。。你再次点击 以获取真正的图片.

    //final image = Image.network(imageUrl,
    //    errorBuilder: (context, error, stack) => Text("[$tag error: $error"));

    if (renderer.peekTapAction() != null) {
      return [
        WidgetSpan(
			child: GestureDetector(
				onTap: renderer.peekTapAction(),
				child: CommentImagePanel(imageUri: imageUri),
			)
		)
      ];
    }

    return [ WidgetSpan(child: CommentImagePanel(imageUri: imageUri)) ];
  }
}

class SizeTag extends StyleTag{
	SizeTag() : super('size');

	@override
	TextStyle transformStyle(TextStyle oldStyle, Map<String, String>? attributes) {
		//example: [Size=20][/Size] attributes?.entries.first.key => 20
		//element.children.first.textContent;
		if (attributes?.entries.isEmpty ?? true) return oldStyle;

		double fontSize = double.tryParse(attributes?.entries.first.key ?? "0.0")!;
		if (fontSize == 0.0) return oldStyle;
		return oldStyle.copyWith(fontSize: fontSize);
	}
}
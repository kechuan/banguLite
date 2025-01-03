
import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/internal/event_bus.dart';
import 'package:bangu_lite/widgets/fragments/comment_image_panel.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';

import 'package:bbob_dart/bbob_dart.dart' as bbob;
import 'package:flutter_bbcode/src/util/color_util.dart';
import 'package:url_launcher/url_launcher_string.dart';

final allEffectTag = [
	BoldTag(),
	ItalicTag(),
	UnderlineTag(),
	StrikeThroughTag(),
	//ColorTag(),
  PatchColorTag(),
	SizeTag(),
	//ImgTag(),
	LateLoadImgTag(),
	UrlTag(
    onTap: (link) async {
      if(await canLaunchUrlString(link)){
        //debugPrint("prevent");

        bus.emit('AppRoute', link);
        //await launchUrlString(link);
      }
    }
    
  ),
	//QuoteTag(),
  AdapterQuoteTag(),
	LeftAlignTag(),
	CenterAlignTag(),
	RightAlignTag(),
	MaskTag(),
  //SpoilerTag()
	BangumiStickerTag()
  
];

class MaskDisplay extends StatelessWidget {
  final String maskText;
  final List<InlineSpan> content;
  final bool selectable;

  	const MaskDisplay({
		super.key,
		required this.maskText,
		required this.content,
	
		this.selectable = true
	});

  @override
  Widget build(BuildContext context) {

	ValueNotifier<bool> activedNotifier = ValueNotifier<bool>(false);

	return MouseRegion(
    onEnter: (event) => activedNotifier.value = true,
    onExit: (event) => activedNotifier.value = false,
    child: Listener( //手势不知道和哪个组件冲突了 怀疑是BBCode内部也实现了空白的手势处理组件 那我干脆用Listener好了
      //onTap: () => activedNotifier.value = true,
      onPointerDown: (event) => activedNotifier.value = true,
      
      
      child:
          ValueListenableBuilder(
            valueListenable: activedNotifier,
            builder: (_,activedStatus,__) {

                bool isDarkMode = judgeDarknessMode(context);
          
                debugPrint("activedStatus rebuild");
          
              return ColoredBox(
                color: isDarkMode ? BangumiThemeColor.macha.color :Colors.black,
                child: 
                  TweenAnimationBuilder<Color?>(
                    duration: const Duration(milliseconds: 300),
                    tween: ColorTween(
                      begin: isDarkMode ? BangumiThemeColor.macha.color :Colors.black,
                      end: isDarkMode ? (activedStatus ? Colors.black : BangumiThemeColor.macha.color) : (activedStatus ? Colors.white : Colors.black),
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
        )
      
      )
    );
				
  
  }
}

class AdapterQuoteDisplay extends StatelessWidget{
  final String? author;
  final TextStyle headerTextStyle;
  final List<InlineSpan> content;

  const AdapterQuoteDisplay({
    super.key,
    required this.content,
    this.author,
    this.headerTextStyle = const TextStyle()
  });

  @override
  Widget build(BuildContext context) {

    bool isDarkMode = judgeDarknessMode(context);

    return Theme(
      data: ThemeData(
        brightness: Theme.of(context).brightness,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(
          border: Border(left: BorderSide(color: Colors.grey, width: 2))),
            child: Column(
              children: [
                if (author != null)
                  Container(
                    padding: const EdgeInsets.all(5),
                    width: double.infinity,
                    decoration: 
                      const BoxDecoration(
                        //color: Colors.white,
                        border:Border(bottom: BorderSide(color: Colors.grey, width: 1))
                      ),
                    child: ScalableText("$author said:", style: headerTextStyle),
                    
                  ),
                Builder(
                  builder: (_) {

                    List<InlineSpan> newInlineSpan = content.map(
                      (currentSpan){
                        return TextSpan(
                          text: currentSpan.toPlainText(),
                          style: currentSpan.style!.merge(TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
                        );
                      }
                    ).toList();

                    return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                        child: RichText(text: TextSpan(children: newInlineSpan)));
                  }
                )
              ],
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
          maskText: text,
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
		scale: imageUrl.contains(RegExp(r'(124)|(125)')) ? 1.6 : 0.8,
        errorBuilder: (context, error, stack) => ScalableText("[$tag]")
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

    String imageUrl = element.children.first.textContent;

	//debugPrint("lateLoad textContent:${imageUrl}");
	//目标: 只获取图片大小 并显示成一个Widget 直到。。你再次点击 以获取真正的图片.

    if (renderer.peekTapAction() != null) {
      return [
        WidgetSpan(
          child: GestureDetector(
            onTap: renderer.peekTapAction(),
            child: CommentImagePanel(imageUrl: imageUrl),
          )
		    )
      ];
    }

    return [ WidgetSpan(child: CommentImagePanel(imageUrl: imageUrl)) ];
  }
}

class SizeTag extends StyleTag{
	SizeTag() : super('size');

	@override
	TextStyle transformStyle(TextStyle oldStyle, Map<String, String>? attributes) {
		if (attributes?.entries.isEmpty ?? true) return oldStyle;

		double fontSize = double.tryParse(attributes?.entries.first.key ?? "0.0")!;
		if (fontSize == 0.0) return oldStyle;
		return oldStyle.copyWith(fontSize: fontSize);
	}
}

class AdapterQuoteTag extends WrappedStyleTag {
  final TextStyle headerTextStyle;

  AdapterQuoteTag({
    this.headerTextStyle = const TextStyle(),
  }) : super("quote");

  @override
  List<InlineSpan> wrap(
      FlutterRenderer renderer, bbob.Element element, List<InlineSpan> spans) {
    String? author =
        element.attributes.isNotEmpty ? element.attributes.values.first : null;

    return [
      WidgetSpan(
        child: AdapterQuoteDisplay(
          author: author,
          headerTextStyle: headerTextStyle,
          content: spans,
        )
      ),
    ];
  }
}

class PatchColorTag extends StyleTag {
  PatchColorTag() : super('color');

  @override
  TextStyle transformStyle(
      TextStyle oldStyle, Map<String, String>? attributes) {
    if (attributes?.entries.isEmpty ?? true) {
      return oldStyle;
    }

    String? hexColor = attributes?.entries.first.key;
    if (hexColor == null) return oldStyle;
    if (!hexColor.contains("#")) return oldStyle;
    return oldStyle.copyWith(color: HexColor.fromHex(hexColor));
  }
}
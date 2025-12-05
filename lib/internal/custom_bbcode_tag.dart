
import 'package:bangu_lite/internal/utils/callback.dart';
import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/internal/utils/convert.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/internal/event_bus.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:bangu_lite/widgets/fragments/comment_image_panel.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/fragments/unvisible_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';

import 'package:bbob_dart/bbob_dart.dart' as bbob;
import 'package:url_launcher/url_launcher_string.dart';

BBStylesheet appDefaultStyleSheet(
    BuildContext context, {
      bool selectableText = false,
      bool richless = false,
      double? fontSize
    }
) {
    return BBStylesheet(
        tags: richless ? richlessEffectTag : allEffectTag,
        selectableText: selectableText,
        defaultText: TextStyle(
          overflow: TextOverflow.ellipsis,
          fontSize: fontSize ?? AppFontSize.s16,
          fontFamilyFallback: convertSystemFontFamily(),
          color: judgeDarknessMode(context) ? Colors.white : Colors.black,
        )
    );
}


final allEffectTag = [
    BoldTag(),
    ItalicTag(),
    UnderlineTag(),
    StrikeThroughTag(),
    PatchColorTag(),
    SizeTag(),

    AdapterQuoteTag(),
    LeftAlignTag(),
    CenterAlignTag(),
    RightAlignTag(),
    MaskTag(),
    BangumiStickerTag(),

    AdapterUrlTag(tagName: "URL"),
    AdapterUrlTag(tagName: "url"),

    //RichTag
    LateLoadImgTag(),
    LateLoadImgTag(tagName: "photo"),
    LateLoadImgTag(tagName: "IMG"),

    CodeTag(),
	  UserTag()
];

final richlessEffectTag = allEffectTag.getRange(0, allEffectTag.length - 5);

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

        bool isDarkMode = judgeDarknessMode(context);

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
                    builder: (_, activedStatus, __) {
                        return DecoratedBox(
                            decoration: BoxDecoration(
                                color: isDarkMode ? AppThemeColor.macha.color : Colors.black,
                                boxShadow: [
                                    BoxShadow(
                                        color: isDarkMode ? AppThemeColor.macha.color : Colors.black,
                                        blurRadius: 2,
                                        spreadRadius: 1
                                    )
                                ]
                            ),
                            child: TweenAnimationBuilder<Color?>(
                                duration: const Duration(milliseconds: 300),
                                tween: ColorTween(
                                    begin: isDarkMode ? AppThemeColor.macha.color : Colors.black,
                                    end: isDarkMode ? (activedStatus ? Colors.black : AppThemeColor.macha.color) : (activedStatus ? Colors.white : Colors.black),
                                ),

                                builder: (_, color, __) {
                                    //MergeStyle
                                    List<InlineSpan> newInlineSpan = content.map(
                                        (currentSpan) {
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
                            ),
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
                                border: Border(bottom: BorderSide(color: Colors.grey, width: 1))
                            ),
                            child: ScalableText("$author 说:", style: headerTextStyle),

                        ),
                        Builder(
                            builder: (_) {

                                List<InlineSpan> newInlineSpan = content.map(
                                  (currentSpan) {

                                      //quote 无法 提取出 mask 的 text
                                      //或者说 mask 无法兼容 quote的渲染

                                      // 噢 直接抛出 WidgetSpan 就好了...
                                      if(currentSpan is WidgetSpan) return currentSpan;

                                      return TextSpan(
                                        text: currentSpan.toPlainText(),
                                        style: currentSpan.style?.merge(TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
                                      );
                                    }
                                ).toList();

                                return UnVisibleResponse(
                                    onTap: () {
                                        if (content.isEmpty) return;
                                        Clipboard.setData(
                                            ClipboardData(
                                                text: content.last.toPlainText().split('说:').last.trim()
                                            )
                                        );
                                    },
                                    child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(5),
                                        child: RichText(text: TextSpan(children: newInlineSpan))
                                    ),
                                );
                            }
                        )
                    ],
                ),
            ),
        );
    }



}

class AdapterUrlTag extends StyleTag{
  AdapterUrlTag({
    this.tagName,
    this.onTap,
    
  }): urlTag = UrlTag(onTap: onTap ?? (link) async {
    await canLaunchUrlString(link).then(
      (launchable) {
          if (launchable) bus.emit('AppRoute', link);	
      }
    );
  }), super( tagName ?? "url");

  final UrlTag urlTag;
  final Function(String)? onTap;

  final String? tagName;

  @override
  void onTagStart(FlutterRenderer renderer) => urlTag.onTagStart(renderer);

  @override
  void onTagEnd(FlutterRenderer renderer) => urlTag.onTagEnd(renderer);

  @override
  TextStyle transformStyle(
    TextStyle oldStyle, 
    Map<String, String>? attributes
  ) => urlTag.transformStyle(oldStyle, attributes);

}

class CodeTag extends AdvancedTag{

    //同种名称的 不同功能 or 不同名称 同种功能
    /// CodeTag({this.tagName = 'code'}) : super("code");
    /// CodeTag({this.tagName = 'code'}) : super(tagName ?? "code");
    CodeTag({this.tagName = 'code'}) : super("code");

    final String? tagName;

    @override
    List<InlineSpan> parse(FlutterRenderer renderer, bbob.Element element) {

        if (element.children.isEmpty) return [TextSpan(text: "[$tag]")];

        //String codeText = element.children.first.textContent;
        String codeText = element.children.map((currentNode) => currentNode.textContent).join();

        return [
            WidgetSpan(
                child: Padding(
                    padding: Padding16,
                    child: Builder(
                        builder: (context) {
                            return Container(
                                color: Colors.grey.withValues(alpha: 0.1),
                                child: Column(
                                    children: [

                                        if(tagName != 'codeExample')
                                        Padding(
                                          padding: PaddingH6,
                                          child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [

                                                    const ScalableText("Code", style: TextStyle(fontSize: 14, color: Colors.grey)),

                                                    IconButton(
                                                        onPressed: () => copyClipboardCallback(context, codeText),
                                                        icon: const Icon(Icons.copy),
                                                        iconSize: 18,
                                                        color: Colors.grey,
                                                    ),
                                                ],
                                            ),
                                        ),

                                        ScalableText(codeText,selectable: true),
                                    ],
                                ),
                            );
                        }
                    ),
                ),

            )
        ];
    }



}

class UserTag extends WrappedStyleTag {

  UserTag(): super("user");
  
    //同种名称的 不同功能 or 不同名称 同种功能
    /// CodeTag({this.tagName = 'code'}) : super("code");
    /// CodeTag({this.tagName = 'code'}) : super(tagName ?? "code");

	@override
	List<InlineSpan> wrap(FlutterRenderer renderer, bbob.Element element, List<InlineSpan> spans) {

    return [ 
			WidgetSpan(
        child: Builder(
          builder: (context) {
            return DecoratedBox(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.5),
                    spreadRadius: 1,
                    blurRadius: 1,
                    offset: const Offset(0, 1), // changes position of shadow
                  ),
                
                ]
              ),
              child: ScalableText(
                '@${spans.first.toPlainText()}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          }
        ),
				
			),
		];


	}

    
}

class MaskTag extends WrappedStyleTag {
    MaskTag() : super("mask");

    @override
    List<InlineSpan> wrap(
      FlutterRenderer renderer, 
      bbob.Element element, 
      List<InlineSpan> spans
    ) {

        String? text = element.attributes.isNotEmpty ?
        element.attributes.values.first :
        null
        ;

        return [
            WidgetSpan(
              child: MaskDisplay(
                maskText: text ?? "mask",
                content: spans,
                selectable: renderer.stylesheet.selectableText,
              )
            ),
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

        //String imageUrl = element.children.first.textContent;
        String imageUrl = element.textContent;

        final image = Image.asset(
            imageUrl,
            scale: 0.8,
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
    LateLoadImgTag({this.tagName}) : super(tagName ?? "img");

    final String? tagName;

    @override
    List<InlineSpan> parse(FlutterRenderer renderer, bbob.Element element) {

        if (element.children.isEmpty) {
            return [TextSpan(text: "[$tag]")];
        }

        String imageUrl = element.children.first.textContent;

        if (tagName == "photo") {
          imageUrl = BangumiAPIUrls.imgurl(imageUrl);
        }

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

        return [WidgetSpan(child: CommentImagePanel(imageUrl: imageUrl))];
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
        RegExp hexColorRegExp = RegExp(r'^#?[0-9a-f]{6}$', caseSensitive: false);

        if (attributes?.entries.isEmpty ?? true) {
            return oldStyle;
        }

        String? hexColor = attributes?.entries.first.key ?? "";

        if (hexColorRegExp.hasMatch(hexColor)) {
            return oldStyle.copyWith(color: HexColor.fromHex(hexColor));
        }

        return oldStyle;
    }

}


extension HexColor on Color {
    // Source: https://stackoverflow.com/questions/50081213/how-do-i-use-hexadecimal-color-strings-in-flutter

    /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
    static Color fromHex(String hexString) {
        final buffer = StringBuffer();
        if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
        buffer.write(hexString.replaceFirst('#', ''));
        return Color(int.parse(buffer.toString(), radix: 16));
    }

    /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
    String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
    '${(a * 256).round().toRadixString(16).padLeft(2, '0')}'
    '${(r * 256).round().toRadixString(16).padLeft(2, '0')}'
    '${(g * 256).round().toRadixString(16).padLeft(2, '0')}'
    '${(b * 256).round().toRadixString(16).padLeft(2, '0')}';
}

//import 'package:bangu_lite/internal/utils/extract.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';

String removeOrphanClosingTags(String text) {
  // 这是一个简单的计数器，防止出现 [/tag] 比 [tag] 多的情况
  final tagPattern = RegExp(r'\[(/?)([a-zA-Z*]+).*?\]');
  final Map<String, int> balance = {};
  
  return text.splitMapJoin(tagPattern, onMatch: (m) {
    String fullTag = m.group(0)!;
    bool isClosing = m.group(1) == '/';
    String tagName = m.group(2)!;

    if (!isClosing) {
      balance[tagName] = (balance[tagName] ?? 0) + 1;
      return fullTag;
    } else {
      if ((balance[tagName] ?? 0) > 0) {
        balance[tagName] = balance[tagName]! - 1;
        return fullTag;
      } else {
        return ''; // 发现孤立关闭标签，直接吞掉，不传给解析器
      }
    }
  });
}

class AdapterBBCodeText extends BBCodeText{
  const AdapterBBCodeText({
    required super.data,
    super.key,
    super.stylesheet,
    super.errorBuilder,
    this.maxLine,
    //this.contentIndex,
  });

  final int? maxLine;
  //final String? contentIndex;

  @override
  Widget build(BuildContext context) {
    // Used to catch any errors.
    Object? error;
    StackTrace? stackTrace;

    //缺失闭合Tag的处理

    // Parse the BBCode and catch an errors.
    List<InlineSpan> spans =
      parseBBCode(
        data, 
        stylesheet: stylesheet, 
        onError: (err, stack) {
          error = err;
          stackTrace = stack;
        }
      )
    ;

    // Handle any potential errors.
    if (error != null) {
      // Log the error if the app is running in debug mode or if verbose logging has been enabled.
      if (kDebugMode) {

        debugPrint(error.toString());
        debugPrint(stackTrace.toString());

        //final fail

        if (errorBuilder == null) {
          return ErrorWidget.withDetails(
              message:
                "An error occurred while attempting to parse the BBCode.\n${error.toString()}"
                "\n\n"
                "No error builder was provided.");
        }
      }

      //retry
      error = null;
      spans =
        parseBBCode(
          removeOrphanClosingTags(data), 
          stylesheet: stylesheet, 
          onError: (err, stack) {
            error = err;
            stackTrace = stack;
          }
        )
      ;

      if(error != null) return errorBuilder?.call(context, error!, stackTrace) ?? Text(data);
    }

    //debugPrint("Floor $contentIndex raw Length: ${data.length}, Parsed Length: ${extractBBCodeSelectableContent(spans).length}}");

    // Improve accessibility, scale text with textScaleFactor.
    var textScaler = MediaQuery.of(context).textScaler;

    //return Text(data,style: stylesheet?.defaultTextStyle);

    ///测试屏蔽
    if (stylesheet?.selectableText ?? false) {
      return SelectableText.rich(
        TextSpan(children: spans, style: stylesheet?.defaultTextStyle),
        textScaler: textScaler,
        maxLines: maxLine,
        style: TextStyle(
          overflow: maxLine != null ? TextOverflow.ellipsis : null,
        ),
      );
    }

    return RichText(
        text: TextSpan(children: spans, style: stylesheet?.defaultTextStyle),
        textScaler: textScaler,
        maxLines: maxLine,
        overflow: maxLine != null ? TextOverflow.ellipsis : TextOverflow.clip,
    );

  }



}

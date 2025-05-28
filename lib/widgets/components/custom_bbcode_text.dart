import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';

class AdapterBBCodeText extends BBCodeText{
  const AdapterBBCodeText({
    required super.data,
    super.key,
    super.stylesheet,
    super.errorBuilder,
    this.maxLine
  });

  final int? maxLine;

  @override
  Widget build(BuildContext context) {
    // Used to catch any errors.
    Object? error;
    StackTrace? stackTrace;

    // Parse the BBCode and catch an errors.
    List<InlineSpan> spans =
        parseBBCode(data, stylesheet: stylesheet, onError: (err, stack) {
      error = err;
      stackTrace = stack;
    });

    // Handle any potential errors.
    if (error != null) {
      // Log the error if the app is running in debug mode or if verbose logging has been enabled.
      if (kDebugMode) {
        debugPrint(error.toString());
        debugPrint(stackTrace.toString());

        if (errorBuilder == null) {
          return ErrorWidget.withDetails(
              message:
                  "An error occurred while attempting to parse the BBCode.\n${error.toString()}"
                  "\n\n"
                  "No error builder was provided.");
        }
      }

      if (errorBuilder == null) {
        return Text(data);
      }

      return errorBuilder!(context, error!, stackTrace);
    }

    // Improve accessibility, scale text with textScaleFactor.
    var textScaler = MediaQuery.of(context).textScaler;

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

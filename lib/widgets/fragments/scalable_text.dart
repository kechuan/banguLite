import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:flutter/material.dart';

class ScalableText extends Text {
  const ScalableText(
    this.text,{
    super.key,
    super.maxLines,
    super.overflow,
    super.style,
    this.selectable = false
  }) : super('');

  final String text;
  final bool selectable;


  @override
  Widget build(BuildContext context) {

    TextStyle? currentStyle = style ?? const TextStyle();
    double? originalSize = currentStyle.fontSize;

    return selectable ?
    SelectableText(
      text,
      style: currentStyle.copyWith(
        fontSize: originalSize != null ? AppFontSize.getScaledSize(originalSize) : AppFontSize.getScaledSize(AppFontSize.s16)
      ),
    ) :
    Text(
      text,
      style: currentStyle.copyWith(
        fontSize: originalSize != null ? AppFontSize.getScaledSize(originalSize) : AppFontSize.getScaledSize(AppFontSize.s16)
      ),
    );
  }
}
import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:flutter/material.dart';

class ScalableText extends Text {
  const ScalableText(
    this.text,{
    super.key,
    super.maxLines,
    super.overflow,
    super.style,
  }) : super('');

  final String text;


  @override
  Widget build(BuildContext context) {

    double? originalSize = style?.fontSize;

    return Text(
      text,
      style: style?.copyWith(
        fontSize: originalSize != null ? AppFontSize.getScaledSize(originalSize) : AppFontSize.getScaledSize(AppFontSize.s16)
      ),
    );
  }
}
import 'package:flutter/services.dart';

class MaxValueFormatter extends TextInputFormatter {
  final int maxValue;

  MaxValueFormatter(this.maxValue);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // 尝试解析输入的值
    final int? enteredValue = int.tryParse(newValue.text);

    // 如果解析失败（不是有效的数字），或者数值大于最大值，就返回最大值
    if (enteredValue == null || enteredValue > maxValue) {
      return TextEditingValue(
        text: maxValue.toString(),
        selection: TextSelection.collapsed(offset: maxValue.toString().length),
      );
    }

    // 否则返回用户输入的值
    return newValue;
  }
}
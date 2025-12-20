import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

void fadeToaster({
  required BuildContext context,
  required String message,
  Duration? duration,
  Color? color
}){
  showToastWidget(
    duration: duration,
    animDuration: const Duration(milliseconds: 200),
    animation: StyledToastAnimation.slideFromBottomFade,
    reverseAnimation: StyledToastAnimation.slideToBottomFade,
    SizedBox(
      height: 50,
      width: 350,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color ?? Colors.grey,
          borderRadius: BorderRadius.circular(16)
        ),
        child: Center(child: ScalableText(message,style: const TextStyle(color: Colors.white))),
      ),
    ),
    context: context,
    
  );

}

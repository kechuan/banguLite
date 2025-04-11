
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:flutter/material.dart';

void showTransitionAlertDialog(
  BuildContext context,
  {
    String? title,
    String? content,
    Function()? cancelAction,
    Function()? confirmAction,
    String? cancelText,
    String? confirmText,
  }
){
    showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: "'!barrierDismissible || barrierLabel != null' is not true",
      context: context,
      pageBuilder: (_,inAnimation,outAnimation){
        return AlertDialog(
          title: ScalableText("$title"),
          content: ScalableText("$content"),
          actions:[
            TextButton(
              onPressed: (){
                cancelAction?.call();
                Navigator.of(context).pop();
              }, child: ScalableText(cancelText ?? "取消")
            ),
            TextButton(
              onPressed: () async {
                confirmAction?.call();
                Navigator.of(context).pop();

              }, 
              child: ScalableText(confirmText ?? "确认")
            )
          ]
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation,child: child),
      transitionDuration: const Duration(milliseconds: 300)
    );
    
}
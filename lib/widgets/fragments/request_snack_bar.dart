import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:flutter/material.dart';

void showRequestSnackBar(
  BuildContext context,
  {
    bool? requestStatus,
    String? message,
    Duration? duration,
  }
){

  
  late Widget trailingWidget;

  switch(requestStatus){

    case null:{
      trailingWidget = const SizedBox(
        height: 25,
        width: 25,
        child: CircularProgressIndicator()
      );

      message ??= "正在请求...";
    }
      
    case true:{
      trailingWidget = const Icon(Icons.done_all);
      message ??= "发送成功";
    }
      
    case false:{
      trailingWidget = const Icon(Icons.close);
      message ??= "发送失败";
    }
      
  }

  
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
        backgroundColor:judgeCurrentThemeColor(context),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ScalableText(message),
            trailingWidget,
          ],
        ),
        duration: duration ?? const Duration(seconds: 5),
    )
  );


}
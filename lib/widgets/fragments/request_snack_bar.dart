import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:flutter/material.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

//DateTime? lastCallTime;

void showRequestSnackBar(
  {
    bool? requestStatus,
    String? message,
    Duration? duration,
    Color? backgroundColor
  }
){

  //final currentTime = DateTime.now();
  
  //// 防抖检查
  //if (
  //  lastCallTime != null && 
  //  (currentTime.millisecondsSinceEpoch - (lastCallTime?.millisecondsSinceEpoch ?? 0))~/1000 < 5
  //) {
  //  debugPrint("[PostContent] Denied ${(currentTime.millisecondsSinceEpoch - (lastCallTime?.millisecondsSinceEpoch ?? 0))~/1000}");
  //  return;
  //}

  //else{
  //  debugPrint("[PostContent] ${lastCallTime?.millisecond} / ${currentTime.millisecond}");
  //  lastCallTime = currentTime;
  //}

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

  scaffoldMessengerKey.currentState?.removeCurrentSnackBar();
  scaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(
        backgroundColor:backgroundColor,
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
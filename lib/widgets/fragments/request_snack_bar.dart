import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:flutter/material.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();


void showRequestSnackBar(
  {
    bool? requestStatus,
    String? message,
    Duration? duration,
    Color? backgroundColor,
    Widget? trailingWidget
  }
){

  switch(requestStatus){

    case null:{
      trailingWidget ??= const SizedBox(
        height: 25,
        width: 25,
        child: CircularProgressIndicator()
      );

      message ??= "正在请求...";
    }
      
    case true:{
      trailingWidget ??= const Icon(Icons.done_all);
      message ??= "发送成功";
    }
      
    case false:{
      trailingWidget ??= const Icon(Icons.close);
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
            ScalableText(message,style: const TextStyle(color: Colors.black),),
            trailingWidget,
          ],
        ),
        duration: duration ?? const Duration(seconds: 5),
    )
  );


}
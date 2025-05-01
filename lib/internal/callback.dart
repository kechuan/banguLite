import 'dart:math';

import 'package:bangu_lite/internal/custom_toaster.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


void animatedListAppendContentCallback(
  bool result,
  int initalLength,
  int receiveLength,
  
  {
	GlobalKey<dynamic>? animatedListKey,
    ScrollController? animatedListController,
    Function({String? message})? fallbackAction,
  }
){
  if(result){
      if(receiveLength == 0){
        fallbackAction?.call();
      }

      else{
        animatedListKey?.currentState?.insertAllItems(
          max(0,initalLength-1), 
          receiveLength,
          duration: const Duration(milliseconds: 300),
        );

		WidgetsBinding.instance.addPostFrameCallback((_) {
			animatedListController?.animateTo(
				animatedListController.offset + 120,
				duration: const Duration(milliseconds: 300),
				curve: Curves.easeOut
			);
		});

    }

  }
}

void copyClipboardCallback(BuildContext context,String content){
  Clipboard.setData(ClipboardData(text: content));
  fadeToaster(context: context, message: "已复制到剪切板");
}
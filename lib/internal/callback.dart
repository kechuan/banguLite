import 'dart:math';

import 'package:bangu_lite/internal/custom_toaster.dart';
import 'package:bangu_lite/internal/extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


void animatedListAppendContentCallback(
  bool result,
  int initalLength,
  List? selectedData,
  GlobalKey<dynamic> animatedListKey,
  
  {
    ScrollController? animatedListController,
    Function({String? message})? fallbackAction,
  }
){
  if(result){

    final int receiveLength = max(0,selectedData?.length ?? 0 - initalLength);

      if(receiveLength == 0){
        fallbackAction?.call();
      }

      else{
        animatedListKey.currentState?.insertAllItems(
          max(0,initalLength-1), 
          receiveLength,
          duration: const Duration(milliseconds: 300),
        );

        animatedListController?.let(
          (_){
            WidgetsBinding.instance.addPostFrameCallback((_) {
              animatedListController.animateTo(
                animatedListController.offset + 120,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut
              );
            });
          }
        );

        

    }

  }
}

void copyClipboardCallback(BuildContext context,String content){
  Clipboard.setData(ClipboardData(text: content));
  fadeToaster(context: context, message: "已复制到剪切板");
}
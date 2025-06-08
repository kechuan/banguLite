import 'package:bangu_lite/internal/custom_toaster.dart';
import 'package:bangu_lite/widgets/dialogs/general_transition_dialog.dart';
import 'package:docman/docman.dart';
import 'package:flutter/material.dart';

Future<dynamic> initalImageStorageDialog(BuildContext context){

  invokeToaster({required String message})=> fadeToaster(context: context, message: message); 

  return showTransitionAlertDialog(
    context,
    title: "初始化公共目录存储",
    content: "BanguLite 需求在公共目录下创建一个文件夹以存放用户保存的图片",
    cancelAction: () {
      return;
    },
    confirmAction: () async {
      //预计会有另一个Hive来存储 存储目录... 
      //也许不必
      invokeToaster(message: "正在唤起系统目录选择器");

      return await DocManPicker().directory(
        initDir: "content://com.android.externalstorage.documents/tree/primary%3ADownload"
      ).then((selectedDir) {

        debugPrint("selectedDir: $selectedDir");

        if(selectedDir == null){
          invokeToaster(message: "已取消目录选择");
        }

        return selectedDir!.uri;

      });

    },
    
  );
}
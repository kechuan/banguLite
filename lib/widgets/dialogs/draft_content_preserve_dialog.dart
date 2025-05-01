import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:bangu_lite/widgets/dialogs/general_transition_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void showDraftContentPreserveDialog(
  BuildContext context,
  int contentID,
  {
    String? title,
    String? content,
  }
  
){
  final indexModel = context.read<IndexModel>();

  showTransitionAlertDialog(
    context,
    title: "退出确认",
    content: "需要保留草稿纸吗? 编辑内容将会存留至退出APP之前",
    cancelText: "放弃修改",
    confirmText: "保留修改",
    cancelAction: () {
      //额外需要多 pop 一层
      Navigator.of(context).pop();
    },
    confirmAction: () {
      
      indexModel.draftContent.addAll({
        contentID :{title ?? "":content ?? ""}
      });

      Navigator.of(context).pop();
    },
  );
}
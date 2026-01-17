import 'dart:async';
import 'dart:math';

import 'package:bangu_lite/internal/bangumi_define/content_status_const.dart';
import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/internal/utils/extension.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/widgets/fragments/request_snack_bar.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/fragments/unvisible_response.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReportDialog extends StatelessWidget {
    const ReportDialog({
        super.key,
        required this.reportSubjectType,
        required this.contentID,

        this.themeColor, 
        //this.onUpdateLocalStar,
        //this.onUpdateBangumiStar

    });

    final ReportSubjectType reportSubjectType;
    final int contentID;

    //final Function()? onUpdateLocalStar;
    //final Function({String? message, bool? requestStatus})? onUpdateBangumiStar;

    final Color? themeColor;

    @override
    Widget build(BuildContext context) {

        final accountModel = context.read<AccountModel>();

        final reportTypeNotifier = ValueNotifier<ReportReasonType>(ReportReasonType.abuse);
        final commentExpandedStatusNotifier = ValueNotifier(false);

        final contentEditingController = TextEditingController();
        final commentExpansibleController = ExpansibleController();

		    debugPrint("[reportDialog] contentType: $reportSubjectType contentID: $contentID type:${reportTypeNotifier.value}");

        return Dialog(
            child: ValueListenableBuilder(
                valueListenable: commentExpandedStatusNotifier,
                builder: (_, commentExpandedStatus, child) {
                    return AnimatedContainer(
                        padding: Padding16,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        width: max(500, MediaQuery.sizeOf(context).height * 9 / 16),
                        height: max(360, MediaQuery.sizeOf(context).height / 2) + (commentExpandedStatus ? 180 : 0),
                        child: Column(
                            spacing: 12,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                                const ScalableText("举报该内容", style: TextStyle(fontSize: 20)),

                                GridView.builder(
                                    shrinkWrap: true,
                                    itemCount: ReportReasonType.values.length,
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisExtent: 45,
                                      mainAxisSpacing: 3,
                                      crossAxisSpacing: 3
                                    ),
                                    itemBuilder: (_, index) {
                                        return ValueListenableBuilder(
                                            valueListenable: reportTypeNotifier,
                                            builder: (_, reportType, textChild) {
                                                return UnVisibleResponse(
                                                  onTap: () {
                                                    reportTypeNotifier.value = ReportReasonType.values[index];
                                                  },
                                                  child: LayoutBuilder(
                                                    builder: (_,constraint) {
                                                      return Row(
                                                          spacing: 6,
                                                          children: [

                                                              RadioGroup(
                                                                onChanged: (reportReasonType){
                                                                  reportTypeNotifier.value = reportReasonType!;
                                                                },
                                                                groupValue: reportType,
                                                                child: Radio(
                                                                    value: ReportReasonType.values[index],
                                                                ),
                                                              ),
                                                      
                                                              
                                                      
                                                              ConstrainedBox(
                                                                constraints: BoxConstraints(
                                                                  maxWidth: constraint.maxWidth/2,
                                                                ),
                                                                child: textChild!
                                                              )
                                                      
                                                          ],
                                                      );
                                                    }
                                                  ),
                                                );

                                            },
                                            child: ScalableText(
                                              ReportReasonType.values[index].reasonName,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis
                                            ),
                                        );
                                    },
                                ),

                                ValueListenableBuilder(
                                    valueListenable: reportTypeNotifier,
                                    builder: (_, starType, child) {
                                        return ExpansionTile(
                                            controller: commentExpansibleController,
                                            onExpansionChanged: (value) => commentExpandedStatusNotifier.value = value,
                                            initiallyExpanded: false,
                                            title: const Text("(可选)展开详细原因"),
                                            children: [
                                                TextField(
                                                    controller: contentEditingController,
                                                    maxLines: 3,
                                                    decoration: const InputDecoration(
                                                        hintStyle: TextStyle(color: Colors.grey),
                                                        border: OutlineInputBorder(),
                                                    ),
                                                )
                                            ],
                                        );
                                    }
                                ),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                        TextButton(
                                            onPressed: () => Navigator.of(context).pop(), 
                                            child: const ScalableText("取消")
                                        ),
                                
                                        TextButton(
                                          onPressed: (){
                                            //invokeAsyncPop((ReportReasonType,String?) reportMessage) => Navigator.of(context).pop(reportMessage);


                                            invokeRequestSnackBar({String? message,bool? requestStatus}) => showRequestSnackBar(
                                              message: message,
                                              requestStatus: requestStatus,
                                              backgroundColor: themeColor
                                            );



                                            accountModel.reportContent(
                                              contentID, 
                                              reportSubjectType.typeIndex, 
                                              reportTypeNotifier.value.reasonIndex,
                                              comment: contentEditingController.text,
                                              fallbackAction: (message) => invokeRequestSnackBar(message: message,requestStatus: false),
                                            ).then((status){
                                              if(status){
                                                invokeRequestSnackBar(message: "已发送举报信息",requestStatus: status);
                                              }
                                            });


                                            
                                          }, 
                                          child: const ScalableText("确定")
                                        ),
                                    ],
                                )

                            ],
                        ),
                    );
                }
            ),
        );
    }
}

Future<StarType?> showReportDialog(
    BuildContext context,
    {
        required PostCommentType postCommentType,
        required int contentID,
        Color? themeColor
    }
) {

    Completer<StarType?> starTypeCompleter = Completer();

    showGeneralDialog(
        barrierDismissible: true,
        barrierLabel: "'!barrierDismissible || barrierLabel != null' is not true",
        context: context,
        pageBuilder: (_, inAnimation, outAnimation) {
          return ReportDialog(
              reportSubjectType: postCommentType.convertReportReason(),
              contentID: contentID,
              themeColor: themeColor,
          );
        },
        transitionBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300)
    ).then((result) {
        if (result is StarType?) starTypeCompleter.complete(result);
    });

    return starTypeCompleter.future;
}

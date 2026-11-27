import 'dart:math';

import 'package:bangu_lite/internal/bangumi_define/content_status_const.dart';
import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/hive.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/models/informations/subjects/bangumi_details.dart';
import 'package:bangu_lite/models/informations/subjects/comment_details.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/fragments/star_slider_panel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StarSubjectDialog extends StatefulWidget {
  const StarSubjectDialog({
    super.key,
    required this.subjectID,
    this.commentDetails,

    this.themeColor, 
    this.onUpdateLocalStar,
    this.onUpdateBangumiStar,
    this.onSaveCommentDetails,

  });

  final Function()? onUpdateLocalStar;
  final Function({String? message, bool? requestStatus})? onUpdateBangumiStar;
  final Function(CommentDetails updatedDetails)? onSaveCommentDetails;

  final CommentDetails? commentDetails;
  final int subjectID;
  final Color? themeColor;

  @override
  State<StarSubjectDialog> createState() => _StarSubjectDialogState();
}

class _StarSubjectDialogState extends State<StarSubjectDialog> {
  late final ValueNotifier<bool> commentExpandedStatusNotifier;
  late final ValueNotifier<double> commentRankNotifier;
  late final ValueNotifier<StarType> starTypeNotifier;
  late final TextEditingController contentEditingController;
  final ExpansibleController commentExpansibleController = ExpansibleController();

  @override
  void initState() {
    super.initState();
    final hasExistingComment = (widget.commentDetails?.comment ?? '').isNotEmpty;
    final hasExistingRate = (widget.commentDetails?.rate ?? 0) > 0;

    commentExpandedStatusNotifier = ValueNotifier(hasExistingComment || hasExistingRate);
    commentRankNotifier = ValueNotifier((widget.commentDetails?.rate ?? 0) / 10);
    starTypeNotifier = ValueNotifier<StarType>(widget.commentDetails?.type ?? StarType.none);
    contentEditingController = TextEditingController(text: widget.commentDetails?.comment);
  }

  @override
  void dispose() {
    commentExpandedStatusNotifier.dispose();
    commentRankNotifier.dispose();
    starTypeNotifier.dispose();
    contentEditingController.dispose();
    commentExpansibleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final accountModel = context.read<AccountModel>();

    return Dialog(
      child: ValueListenableBuilder(
        valueListenable: commentExpandedStatusNotifier,
        builder: (_, commentExpandedStatus, child) {
          return AnimatedContainer(
            padding: Padding16,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            width: max(300, MediaQuery.sizeOf(context).height * 9 / 16),
            height: max(250, MediaQuery.sizeOf(context).height / 3) + (commentExpandedStatus ? 180 : 0),
            child: Column(
              spacing: 6,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                ScalableText(starTypeNotifier.value != StarType.none ? "修改该番剧的收藏状态" : "收藏该番剧", style: const TextStyle(fontSize: 20)),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const ScalableText("Bangumi收藏状态 :", style: TextStyle(color: Color.fromARGB(255, 233, 166, 206)),),

                    ValueListenableBuilder(
                      valueListenable: starTypeNotifier,
                      builder: (_, starType, child) {
                        return PopupMenuButton<StarType>(
                          enabled: accountModel.isLogined(),
                          initialValue: starTypeNotifier.value,
                          position: PopupMenuPosition.under,
                          itemBuilder: (_) => List.generate(
                            StarType.values.length,
                            (index) {
                              return PopupMenuItem(
                                value: StarType.values[index],
                                child: ScalableText(StarType.values[index].starTypeName)
                              );
                            }
                          ),
                          onSelected: (starType) {
                            starTypeNotifier.value = starType;
                            if (starType == StarType.none) {
                              commentExpandedStatusNotifier.value = false;

                              if (commentExpansibleController.isExpanded) {
                                commentExpansibleController.collapse();
                              }

                            }

                          },
                          child: SizedBox(
                            height: 50,
                            child: Row(
                              children: [
                                Padding(
                                  padding: PaddingH6,
                                  child: ScalableText(
                                    starType.starTypeName,
                                    style: TextStyle(
                                      color: accountModel.isLogined() ? null : Colors.grey

                                    ),
                                  ),
                                ),

                                Icon(Icons.arrow_drop_down, color: accountModel.isLogined() ? null : Colors.grey,)

                              ],
                            ),
                          ),

                        );
                      }
                    )
                  ],
                ),

                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: ValueListenableBuilder(
                        valueListenable: starTypeNotifier,
                        builder: (_, starType, child) {
                          return ExpansionTile(
                            controller: commentExpansibleController,
                            enabled: starType != StarType.none,
                            onExpansionChanged: (value) => commentExpandedStatusNotifier.value = value,
                            initiallyExpanded: commentExpandedStatus,
                            title: const Text("展开评论与评分"),
                            children: [

                              Center(
                                child: StarSliderPanel(
                                  valueNotifier: commentRankNotifier,
                                  onChanged: (value) => commentRankNotifier.value = value,
                                  themeColor: widget.themeColor
                                ),
                              ),

                              const Padding(padding: PaddingV6),

                              TextField(
                                controller: contentEditingController,
                                maxLines: 3,
                                decoration: const InputDecoration(
                                  hintText: '写下吐槽...',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: OutlineInputBorder(),
                                ),
                              )
                            ],
                          );
                        }
                      ),
                    ),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [

                    TextButton(
                      onPressed: () {
                        widget.onUpdateLocalStar?.call();
                        Navigator.of(context).pop();
                      },
                      child: const ScalableText("仅本地收藏")
                    ),

                    if(accountModel.isLogined())
                    const Spacer(),

                    if(accountModel.isLogined())
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(), 
                          child: const ScalableText("取消")
                        ),
                        TextButton(
                          onPressed: () async {

                            if (!MyHive.starBangumisDataBase.containsKey(widget.subjectID)) {
                              widget.onUpdateLocalStar?.call();
                            }

                            widget.onUpdateBangumiStar?.call();

                            final rateValue = commentRankNotifier.value * 10 ~/ 1;

                            final status = await accountModel.postContent(
                              subjectID: widget.subjectID.toString(),
                              postContentType: PostCommentType.subjectComment,
                              actionType: UserContentActionType.edit,
                              subjectCommentData: BangumiDatas.subjectCommentData(
                                content: contentEditingController.text,
                                isPrivate: false,
                                starType: starTypeNotifier.value,
                                rate: rateValue,
                              ),
                              fallbackAction: (errorMessage) => widget.onUpdateBangumiStar?.call(message: errorMessage, requestStatus: false),
                            );

                            if (status != 0) {
                              final updatedDetails = CommentDetails()
                                ..userInformation = widget.commentDetails?.userInformation ?? AccountModel.loginedUserInformations.userInformation
                                ..commentTimeStamp = DateTime.now().millisecondsSinceEpoch
                                ..comment = contentEditingController.text
                                ..rate = rateValue
                                ..type = starTypeNotifier.value;

                              widget.onSaveCommentDetails?.call(updatedDetails);
                              widget.onUpdateBangumiStar?.call(message: "收藏成功", requestStatus: true);
                            }

                            if (!context.mounted) return;
                            Navigator.of(context).pop(
                              status != 0 ? starTypeNotifier.value : (widget.commentDetails?.type ?? StarType.none),
                            );

                          }, 
                          child: const ScalableText("确定")

                        ),
                      ],
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

Future<StarType?> showStarSubjectDialog(
  BuildContext context,
  {
    Function()? onUpdateLocalStar,
    Function({String? message, bool? requestStatus})? onUpdateBangumiStar,
    Function(CommentDetails updatedDetails)? onSaveCommentDetails,
    BangumiDetails? bangumiDetails,
    CommentDetails? commentDetails,
    String? comment,
    Color? themeColor
  }
) async {
  final result = await showGeneralDialog(
    barrierDismissible: true,
    barrierLabel: "'!barrierDismissible || barrierLabel != null' is not true",
    context: context,
    pageBuilder: (_, inAnimation, outAnimation) {

      return StarSubjectDialog(
        subjectID: bangumiDetails?.id ?? 0,
        commentDetails: commentDetails,
        onUpdateLocalStar: onUpdateLocalStar,
        onUpdateBangumiStar: onUpdateBangumiStar,
        onSaveCommentDetails: onSaveCommentDetails,
        themeColor: themeColor,

      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
    transitionDuration: const Duration(milliseconds: 300)
  );

  return result is StarType ? result : null;
}

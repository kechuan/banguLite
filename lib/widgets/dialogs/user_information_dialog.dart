import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/internal/bangumi_define/content_status_const.dart';
import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/internal/utils/convert.dart';
import 'package:bangu_lite/internal/custom_bbcode_tag.dart';
import 'package:bangu_lite/widgets/components/custom_bbcode_text.dart';
import 'package:bangu_lite/internal/custom_toaster.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/models/providers/user_model.dart';
import 'package:bangu_lite/models/informations/surf/timeline_details.dart';
import 'package:bangu_lite/models/informations/surf/user_details.dart';
import 'package:bangu_lite/widgets/dialogs/general_transition_dialog.dart';
import 'package:bangu_lite/widgets/fragments/cached_image_loader.dart';
import 'package:bangu_lite/widgets/fragments/request_snack_bar.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/fragments/unvisible_response.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class UserInformationDialog extends StatelessWidget {
    const UserInformationDialog({
        super.key,
        this.userInformation
    });

    final UserInformation? userInformation;

    @override
    Widget build(BuildContext context) {
        final accountModel = context.read<AccountModel>();
        final userModel = context.read<UserModel>();

        bool blockStatus = 
          AccountModel.loginedUserInformations.accessToken == null ||
          AccountModel.loginedUserInformations.userInformation?.userName == userInformation?.userName
        ;
                                                                
        return Dialog(
            backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9), 
            child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height / 2 > 200 ? MediaQuery.sizeOf(context).height / 2 : 200,
                    maxWidth: MediaQuery.sizeOf(context).width / 1.5 > 300 ? MediaQuery.sizeOf(context).width / 1.5 : 300,
                    minHeight: 200,
                    minWidth: 300
                ),

                child: Column(
                    spacing: 6,
                    children: [

                        Padding(
                            padding: Padding12,
                            child: SizedBox(
                                height: 60,
                                child: Row(
                                    spacing: 6,
                                    crossAxisAlignment: CrossAxisAlignment.center,

                                    children: [

                                        SizedBox(
                                            height: 50,
                                            width: 50,
                                            child: CachedImageLoader(imageUrl: userInformation?.avatarUrl)
                                        ),

                                        //可压缩信息 Expanded
                                        Expanded(
                                            child: UnVisibleResponse(
                                                onTap: () {
                                                    Clipboard.setData(ClipboardData(text: '${userInformation?.userName}'));
                                                    fadeToaster(context: context, message: "已复制用户ID");
                                                },
                                                child: ScalableText(
                                                    userInformation?.nickName ?? userInformation?.userName ?? "no data",
                                                    style: const TextStyle(color: Colors.blue),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                    textAlign: TextAlign.center,
                                                ),
                                            ),
                                        ),

                                        Column(
                                            children: [

                                                TextButton(
                                                    onPressed: () {

                                                        if (userInformation?.userName != null) {

                                                            Navigator.pushNamed(
                                                                context,
                                                                Routes.webview,
                                                                arguments: {"url":BangumiWebUrls.userTimeline(userInformation!.userName!)},
                                                            );

                                                            //launchUrlString(
                                                            //  mode: LaunchMode.inAppWebView,
                                                            //  BangumiWebUrls.userTimeline(userInformation!.userName!)
                                                            //);
                                                        }

                                                    },
                                                    child: const ScalableText(
                                                        "TA的主页",
                                                        style: TextStyle(decoration: TextDecoration.underline),
                                                    )
                                                ),

                                                Row(
                                                    spacing: 12,
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [

                                                        UnVisibleResponse(
                                                          onTap: () {
                                                            if (blockStatus) return;
                                                            fadeToaster(context: context, message: "暂未开放");
                                                          },
                                                          child: Icon(
                                                            Icons.email_outlined,
                                                            color: blockStatus ? Colors.grey : null,
                                                          )

                                                        ),

                                                        UnVisibleResponse(
                                                            onTap: () {
                                                                if ( blockStatus ){ return; }
                                                                

                                                                showTransitionAlertDialog(
                                                                    context,
                                                                    title: "发送好友请求",
                                                                    content: "确定对用户 ${userInformation?.getName()} 发送好友请求吗?",
                                                                    confirmAction: () async {

                                                                        invokeAsyncSnacker(String message) => showRequestSnackBar(message: message,backgroundColor: judgeCurrentThemeColor(context));

                                                                        accountModel.userRelationAction(
                                                                            userInformation?.userName,
                                                                            fallbackAction: (errorMessage) => invokeAsyncSnacker(errorMessage),
                                                                        ).then((status) {
                                                                          if (status) invokeAsyncSnacker("已发送好友请求");
                                                                        });

                                                                    },

                                                                );
                                                            },
                                                            child: Icon(

                                                                MdiIcons.accountPlusOutline,
                                                                color: blockStatus ? Colors.grey : null,
                                                            )
                                                        ),

                                                        UnVisibleResponse(
                                                            onTap: () {

                                                              if (blockStatus ){ return; }
                                                                
                                                                
                                                                showTransitionAlertDialog(
                                                                    context,
                                                                    title: "拉黑用户",
                                                                    content: "确定拉入用户 ${userInformation?.getName()} 进黑名单吗?",
                                                                    confirmAction: () async {

                                                                        invokeAsyncToaster(String message) => fadeToaster(context: context, message: message);

                                                                        accountModel.userRelationAction(
                                                                            userInformation?.userName,
                                                                            relationType: UserRelationsActionType.block,
                                                                            fallbackAction: (errorMessage) => invokeAsyncToaster(errorMessage),
                                                                        ).then((result) {
                                                                          if(result) invokeAsyncToaster("拉黑成功");
                                                                        });

                                                                    },

                                                                );
                                                            },
                                                            child: Icon(
                                                                Icons.no_accounts_outlined,
                                                                color: blockStatus ? Colors.grey : null,
                                                            )
                                                        )
                                                    ],
                                                )

                                            ],
                                        ),

                                    ],
                                ),
                            ),
                        ),

                        Expanded(
                            child: EasyRefresh(
                                child: FutureBuilder(
                                    future: userModel.loadUserInfomation(userInformation?.userName, userInformation),
                                    builder: (_, snapshot) {

                                        final timelineActions = userModel.userData[userInformation?.userName]?.timelineActions;

                                        switch (snapshot.connectionState){
                                            case ConnectionState.done:{
                                                return LayoutBuilder(
                                                    builder: (_, constraint) {
                                                        return Column(
                                                            spacing: 6,
                                                            children: [
                                                                Row(
                                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                    children: [

                                                                        ScalableText(
                                                                            "${covertPastDifferentTime(timelineActions?[0].timelineCreatedAt)} 来过",
                                                                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                                                                        ),

                                                                        Builder(
                                                                            builder: (_) {

                                                                                DateTime joinTime = DateTime.fromMillisecondsSinceEpoch((userInformation?.joinedAtTimeStamp ?? 0) * 1000);

                                                                                return ScalableText(
                                                                                    "加入时间: ${joinTime.year}-${convertDigitNumString(joinTime.month)}-${convertDigitNumString(joinTime.day)}",
                                                                                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                                                                                );
                                                                            }
                                                                        ),

                                                                    ],
                                                                ),

                                                                // 收藏数据
                                                                Builder(
                                                                    builder: (_) {
                                                                        final statListData = convertSubjectStat(userModel.userData[userInformation?.userName]?.subjectStat);
                                                                        return Wrap(
                                                                            spacing: 6,
                                                                            runSpacing: 12,
                                                                            children: List.generate(
                                                                                StarType.values.length - 1,
                                                                                (index) {
                                                                                    return ScalableText(
                                                                                        "${StarType.values[index].starTypeName} ${statListData[index]}",
                                                                                        style: const TextStyle(color: Colors.grey, fontSize: 14),

                                                                                    );
                                                                                },

                                                                            ),
                                                                        );
                                                                    }
                                                                ),

                                                                const Padding(
                                                                    padding: PaddingH16V6,
                                                                    child: Align(
                                                                        alignment: Alignment.centerLeft,
                                                                        child: ScalableText("最近动态", style: TextStyle(fontSize: 16))
                                                                    )),

                                                                Expanded(
                                                                    child: Padding(
                                                                        padding: PaddingH12 + Padding16,
                                                                        child: ListView.separated(
                                                                            itemCount: timelineActions?.length ?? 0,
                                                                            separatorBuilder: (_, index) => const Padding(padding: PaddingV6),
                                                                            itemBuilder: (_, index) {

                                                                                return Wrap(
                                                                                    spacing: 6,
                                                                                    children: [

                                                                                        ScalableText(
                                                                                            covertPastDifferentTime(timelineActions![index].timelineCreatedAt),
                                                                                            style: const TextStyle(color: Colors.blueGrey, fontSize: 14),
                                                                                        ),

                                                                                        AdapterBBCodeText(
                                                                                            data: convertTimelineDescription(timelineActions[index]),
                                                                                            stylesheet: appDefaultStyleSheet(context)
                                                                                        ),
                                                                                    ],
                                                                                );

                                                                            },
                                                                            shrinkWrap: true,

                                                                        ),
                                                                    ),
                                                                ),

                                                            ],
                                                        );
                                                    }
                                                );

                                            }

                                            default: return const Center(child: CircularProgressIndicator());
                                        }

                                    }
                                ),
                            ),
                        ),

                    ],
                ),
            ),
        );

    }
}

void showUserInfomationDialog(BuildContext context, UserInformation? userInformation) {
    showGeneralDialog(
        barrierDismissible: true,
        barrierLabel: "'!barrierDismissible || barrierLabel != null' is not true",
        context: context,
        transitionBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, inAnimation, outAnimation) {

            return UserInformationDialog(userInformation: userInformation);

        }
    );
}

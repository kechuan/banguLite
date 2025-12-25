
import 'dart:math';

import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/internal/bangumi_define/bangumi_social_hub.dart';
import 'package:bangu_lite/internal/hive.dart';
import 'package:bangu_lite/internal/utils/convert.dart';
import 'package:bangu_lite/internal/custom_bbcode_tag.dart';
import 'package:bangu_lite/widgets/components/custom_bbcode_text.dart';
import 'package:bangu_lite/internal/event_bus.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/informations/subjects/group_details.dart';
import 'package:bangu_lite/models/informations/surf/surf_timeline_details.dart';
import 'package:bangu_lite/widgets/fragments/bangumi_user_avatar.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/fragments/star_score_list.dart';
import 'package:bangu_lite/widgets/fragments/unvisible_response.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class BangumiTimelineTile extends StatelessWidget{

    const BangumiTimelineTile({
        super.key,
        required this.surfTimelineDetails,
        this.isRecordMode,
        this.onTap

    });

    final SurfTimelineDetails surfTimelineDetails;
    final bool? isRecordMode;
    final bool Function()? onTap;


    @override
    Widget build(BuildContext context) {
        return ListTile(
            contentPadding: const EdgeInsets.all(0),
            onTap: () {

                if (onTap?.call() == false) return;

                debugPrint("timeline DetailID:${surfTimelineDetails.detailID} timelineType:${surfTimelineDetails.bangumiSurfTimelineType}");

                ///历史记录的updatedAt 与 展示用的 updatedAt 效果不一致
                switch (surfTimelineDetails.bangumiSurfTimelineType){
                    case BangumiSurfTimelineType.subject:{
                        //错误 因为 单独透过Link 访问时得到的 同样会是null 没办法
                        if (surfTimelineDetails.commentDetails?.userInformation?.userID == null) {
                            Navigator.pushNamed(
                                context,
                                Routes.subjectDetail,
                                arguments: {"subjectID":surfTimelineDetails.detailID},
                            );
                        }

                        else {

                            if (surfTimelineDetails.sourceTitle?.contains("[日志]") == true) {

                                //目前唯一从这个渠道(timeline)打开 博客 的地方 只有历史记录了
                                bus.emit(
                                    "AppRoute",
                                    '${BangumiWebUrls.userBlog(surfTimelineDetails.detailID ?? 0)}'
                                    '?sourceID=${surfTimelineDetails.sourceID}' 
                                    '${surfTimelineDetails.sourceTitle!=null ? "&sourceTitle=${surfTimelineDetails.sourceTitle}" : ""}'
                                );
                            }

                            else {
                                bus.emit(
                                    "AppRoute",
                                    '${BangumiWebUrls.subjectTopic(surfTimelineDetails.detailID ?? 0)}'
									                  '?sourceID=${surfTimelineDetails.sourceID}'
                                    '&topicTitle=${surfTimelineDetails.title}'
                                    '${surfTimelineDetails.sourceTitle!=null ? "&sourceTitle=${surfTimelineDetails.sourceTitle}" : ""}'

                                );
                            }

                        }

                    }

                    case BangumiSurfTimelineType.group:{

                        if (surfTimelineDetails.detailID != null) {
                            MyHive.historySurfDataBase.put(
                                surfTimelineDetails.detailID!,
                                surfTimelineDetails.copyWithUpdateAt(surfTimelineDetails)
                            );

                            bus.emit(
                                "AppRoute",
                                '${BangumiWebUrls.groupTopic(surfTimelineDetails.detailID!)}?groupTitle=${surfTimelineDetails.title}'
                            );
                        }

                    }

                    default:{}
                }

            },
            title: Column(
                spacing: 6,
                children: [

                    Row(
                        spacing: 12,
                        children: [

                            BangumiUserAvatar(
                                size: 50,
                                userInformation: surfTimelineDetails.commentDetails?.userInformation,
                            ),

                            Expanded(
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                        AdapterBBCodeText(
                                            data: '${surfTimelineDetails.title}',
                                            stylesheet: appDefaultBBStyleSheet(context),
                                            maxLine: 3,
                                        ),

                                        if(
                                        surfTimelineDetails.commentDetails?.rate != null &&
                                            surfTimelineDetails.commentDetails?.rate != 0
                                        )
                                        SizedBox(
                                            height: 50,
                                            child: StarScoreList(
                                                ratingScore: surfTimelineDetails.commentDetails?.rate ?? 0,
                                                themeColor: judgeCurrentThemeColor(context),
                                            )
                                        )
                                    ],
                                ),
                            ),

                            if(surfTimelineDetails.replies != null)
                            Row(
                                children: [
                                    Icon(MdiIcons.chat, size: 16, color: Colors.grey.shade700),
                                    ScalableText("${surfTimelineDetails.replies}", style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                                ],
                            ),

                        ],
                    ),

                    LayoutBuilder(
                        builder: (_, constraint) {
                            if (surfTimelineDetails.commentDetails?.comment != null) {
                                return Align(
                                    alignment: Alignment.centerLeft,
                                    child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                            minWidth: min(constraint.maxWidth * 2 / 3, 250),
                                            maxWidth: constraint.maxWidth - 80,
                                        ),
                                        child: AdapterBBCodeText(
                                            data: "[quote]${surfTimelineDetails.commentDetails?.comment}[/quote]",
                                            stylesheet: appDefaultBBStyleSheet(context, richless: true)
                                        )
                                    ),
                                );
                            }

                            return const SizedBox.shrink();
                        }
                    ),

                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        spacing: 6,
                        children: [
                            Flexible(
                                flex: 3,
                                child: Row(

                                    children: [

                                        ScalableText(
                                            "${surfTimelineDetails.bangumiSurfTimelineType?.typeName ?? ""}"
                                            "${surfTimelineDetails.sourceTitle == null ? "" : " · "}"
                                            ,
                                            style: const TextStyle(fontSize: 14, color: Colors.grey)
                                        ),

                                        Flexible(
                                            child: UnVisibleResponse(
                                                onTap: () {

                                                    //debugPrint("sourceID: ${surfTimelineDetails.sourceID}");

													if(surfTimelineDetails.sourceID == null) return;

                                                    switch (surfTimelineDetails.bangumiSurfTimelineType) {

                                                        //利用callback 加载数据? 否则历史记录里面会缺失avatar 
                                                        //或者干脆直接在subjectDetail里加载得了。。
                                                        case BangumiSurfTimelineType.subject:{
                                                            Navigator.pushNamed(
                                                                context,
                                                                Routes.subjectDetail,
                                                                arguments: {"subjectID":surfTimelineDetails.sourceID},
                                                            );
                                                        }

                                                        case BangumiSurfTimelineType.group:{
                                                            Navigator.pushNamed(
                                                                context,
                                                                Routes.groups,
                                                                arguments: {
                                                                    "selectedGroupInfo":GroupInfo(
                                                                        id: surfTimelineDetails.detailID
                                                                    )
                                                                        ..groupName = surfTimelineDetails.sourceID
                                                                        ..groupTitle = surfTimelineDetails.sourceTitle
                                                                },
                                                            );
                                                        }

                                                        default:{}

                                                    }

                                                },
                                                child: ScalableText(                              
                                                    surfTimelineDetails.sourceTitle ?? "",
                                                    style: TextStyle(
														fontSize: 14, 
														color: Colors.grey, 
														decoration: surfTimelineDetails.sourceID != null ? TextDecoration.underline : null
													),
                                                    maxLines: 2,
                                                    textAlign: TextAlign.left,
                                                    overflow: TextOverflow.ellipsis,
                                                ),
                                            ),
                                        ),
                                    ],
                                ),
                            ),

                            Expanded(
                                flex: 2,
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    spacing: 6,

                                    children: [
                                        Flexible(
                                            child: ScalableText(
                                                surfTimelineDetails.commentDetails?.userInformation?.nickName ?? "",
                                                style: const TextStyle(fontSize: 12, color: Colors.grey)
                                            ),
                                        ),

                                        if(isRecordMode != true)
                                        ScalableText(
                                            covertPastedTime(surfTimelineDetails.updatedAt),
                                            style: const TextStyle(fontSize: 12, color: Colors.grey)
                                        ),

                                    ],
                                ),
                            ),
                        ],
                    )

                ],
            ),

        );
    }
}

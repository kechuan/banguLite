import 'dart:math';

import 'package:bangu_lite/internal/bangumi_define/bangumi_social_hub.dart';
import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/internal/hive.dart';
import 'package:bangu_lite/internal/judge_condition.dart';

import 'package:bangu_lite/internal/lifecycle.dart';
import 'package:bangu_lite/internal/utils/convert.dart';
import 'package:bangu_lite/internal/utils/extension.dart';
import 'package:bangu_lite/models/informations/subjects/base_details.dart';
import 'package:bangu_lite/models/informations/subjects/base_info.dart';
import 'package:bangu_lite/models/informations/subjects/comment_details.dart';
import 'package:bangu_lite/models/informations/surf/surf_timeline_details.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/models/providers/base_model.dart';
import 'package:bangu_lite/models/providers/history_model.dart';
import 'package:bangu_lite/widgets/components/bangumi_general_content_comment.dart';
//import 'package:bangu_lite/widgets/components/bangumi_general_content_comment.dart';
import 'package:bangu_lite/widgets/fragments/animated/animated_transition.dart';
import 'package:bangu_lite/widgets/fragments/bangumi_content_appbar.dart';
import 'package:bangu_lite/widgets/fragments/comment_filter.dart';
import 'package:bangu_lite/widgets/components/general_replied_line.dart';
import 'package:bangu_lite/widgets/fragments/custom_friction.dart';
import 'package:bangu_lite/widgets/fragments/error_load_prompt.dart';
import 'package:bangu_lite/widgets/fragments/request_snack_bar.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/fragments/skeleton_tile_template.dart';
import 'package:bangu_lite/widgets/views/ep_comments_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sliver_tools/sliver_tools.dart';

abstract class BangumiContentPageState<
    W extends StatefulWidget,
    M extends BaseModel,
    I extends ContentInfo,
    D extends ContentDetails
    > extends LifecycleRouteState<W> {

    //widget.*信息获取
    M getContentModel();
    I getContentInfo();
    D createEmptyDetailData();

    String getWebUrl(int? contentID);

    String? sourceTitle() => null;
    PostCommentType? getPostCommentType();

    //因为 reviewID 不与 blogID 相匹配 需要额外适配
    int? getSubContentID() => null;

    int? getCommentCount(D? contentDetail, bool isLoading);
    Color? getcurrentSubjectThemeColor();

    //可选的跳转ID
    int? getReferPostContentID();

    Future<void> loadContent(int contentID, {bool isRefresh = false});

    //blog 与 其他的 commentLoading 与 CommentCount 判定标注不一样 需要针对重写
    bool isContentLoading(int? contentID) {
        return getContentModel().contentDetailData[contentID] == null || 
            getContentModel().contentDetailData[contentID]?.detailID == 0;
    }

    List<String>? getTrailingPhotosUri() => null;

    bool isContentInitaled = false;

    //子内容加载(评论)
    Future? contentFuture;

    final scrollController = ScrollController();
    final GlobalKey<SliverAnimatedListState> animatedSliverListKey = GlobalKey();
    final GlobalKey authorContentKey = GlobalKey();

    final refreshNotifier = ValueNotifier(0);

    //推迟执行以允许在函数作用域之外执行 非const输入
    late final commentFilterTypeNotifier = ValueNotifier(
        getReferPostContentID() != null ? 
            BangumiCommentRelatedType.id :
            BangumiCommentRelatedType.normal
    );

    /// [Local Record] will be refreshed by selectedEP Toggle
    // For Record Comment Type List
    List<EpCommentDetails> resultFilterCommentList = [];

    // For record Local comment Change.
    final Map<int, String> userCommentMap = {};

    Color? readableThemeColor;

    @override
    void initState() {
        final contentInfo = getContentInfo();

        debugPrint('[GenernalContent] ${contentInfo.runtimeType} ID / subContentID: ${contentInfo.id} / ${getSubContentID()}');

        /// loadInterceptionCallback 拦截注入
        contentFuture = contentInfo.loadInterceptionCallback?.call() ?? loadContent(getSubContentID() ?? getContentInfo().id ?? 0);

        super.initState();
    }


    @override
    Widget build(BuildContext context) {

        //widget.获取
        final contentModel = getContentModel();
        final contentInfo = getContentInfo();

        readableThemeColor ??= 
          !judgeDarknessMode(context) ?
          getcurrentSubjectThemeColor()?.withValues(
              red: 1 - getcurrentSubjectThemeColor()!.r,
              green: 1 - getcurrentSubjectThemeColor()!.g,
              blue: 1 - getcurrentSubjectThemeColor()!.b
          ) : getcurrentSubjectThemeColor()
        ;

        return ChangeNotifierProvider.value(
            //因为下方的 Selector 需求 使用 带有contentModel 的context环境
            value: contentModel,
            builder: (context, _) {

                return EasyRefresh.builder(
                    childBuilder: (_, physic) {
                        return Theme(
                            data: Theme.of(context).copyWith(
                                scaffoldBackgroundColor: judgeDarknessMode(context) ? null : convertFineTuneColor(getcurrentSubjectThemeColor() ?? judgeCurrentThemeColor(context), lumiScaleType: ScaleType.min),
                            ),
                            child: Scaffold(
                                body: Selector<M, D>(
                                    selector: (_, model) => (getContentModel().contentDetailData[getSubContentID() ?? contentInfo.id] as D?) ?? createEmptyDetailData(),
                                    shouldRebuild: (previous, next) => previous != next,
                                    builder: (_, contentDetailData, contentComment) {

                                        return Scrollbar(
                                            thumbVisibility: true,
                                            interactive: true,
                                            thickness: 6,
                                            controller: scrollController,
                                            child: CustomScrollView(
                                                controller: scrollController,
                                                physics: CustomDampingPhysic(parent: physic),
                                                slivers: [
                                                    MultiSliver(
                                                        children: [

                                                            SliverPinnedHeader(
                                                                child: SafeArea(
                                                                    bottom: false,
                                                                    child: BangumiContentAppbar(
                                                                        contentID: getSubContentID() ?? contentInfo.id,
                                                                        titleText: contentDetailData.contentTitle ?? contentInfo.contentTitle,
                                                                        webUrl: getWebUrl(getSubContentID() ?? contentInfo.id),
                                                                        postCommentType: getPostCommentType(),
                                                                        surfaceColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
                                                                        onSendMessage: (content) {

                                                                            userCommentMap.addAll({content.$1 ?? 0:content.$2 as String});

                                                                            WidgetsBinding.instance.addPostFrameCallback((_) {
                                                                                    animatedSliverListKey.currentState?.insertItem(0);
                                                                                });

                                                                        },
                                                                    ),
                                                                )
                                                            ),

                                                            FutureBuilder(
                                                                future: contentFuture,
                                                                builder: (_, snapshot) {

                                                                    final bool isCommentLoading = isContentLoading(getSubContentID() ?? contentInfo.id) && contentInfo.id != unExistID;

                                                                    /// 载入失败
                                                                    if (snapshot.hasError) {
                                                                        return SizedBox(
                                                                            height: MediaQuery.sizeOf(context).height,
                                                                            width: MediaQuery.sizeOf(context).width,
                                                                            child: ErrorLoadPrompt(
                                                                                message: snapshot.error,
                                                                                onRetryAction: () {
                                                                                    contentFuture = loadContent(getSubContentID() ?? contentInfo.id ?? 0, isRefresh: true);
                                                                                    refreshNotifier.value += 1;
                                                                                },
                                                                            ),

                                                                        );
                                                                    }

                                                                    // 初始化载入内容
                                                                    if (!isContentInitaled) initCotent();

                                                                    return isCommentLoading ?
                                                                        Skeletonizer.sliver(
                                                                            enabled: true,
                                                                            child: SliverList(
                                                                                delegate: SliverChildBuilderDelegate(
                                                                                    (_, index) {
                                                                                        if (index == 0) {
                                                                                            return Padding(
                                                                                                padding: EdgeInsetsGeometry.only(top: 50, bottom: 125),
                                                                                                child: const SkeletonListTileTemplate(scaleType: ScaleType.medium),
                                                                                            );
                                                                                        }
                                                                                        return const SkeletonListTileTemplate(scaleType: ScaleType.min);
                                                                                    }
                                                                                ),

                                                                            ),
                                                                        ) :
                                                                        authorContent(contentInfo, contentDetailData);

                                                                }
                                                            ),

                                                            contentComment!

                                                        ]
                                                    )
                                                ],
                                            ),
                                        );
                                    },
                                    child: ValueListenableBuilder(
                                        valueListenable: refreshNotifier,
                                        builder: (_, __, ___) {
                                            return FutureBuilder(
                                                future: contentFuture,
                                                builder: (_, snapshot) {

                                                    final bool isCommentLoading = isContentLoading(getSubContentID() ?? contentInfo.id) && contentInfo.id != unExistID;
                                                    final D? contentDetail = contentModel.contentDetailData[getSubContentID() ?? contentInfo.id] as D?;

                                                    /// 载入失败
                                                    if (snapshot.data == false && contentDetail?.detailID == 0) {
                                                        return const Center(
                                                            child: SizedBox.shrink()
                                                        );
                                                    }

                                                    if (isCommentLoading) return const SizedBox.shrink();

                                                    int resultCommentCount = resultFilterCommentList.length;

                                                    return SliverSafeArea(
                                                        top: false,
                                                        sliver: ValueListenableBuilder(
                                                            valueListenable: commentFilterTypeNotifier,
                                                            builder: (_, commentFilterType, __) {
                                                    
                                                                return SliverAnimatedList(
                                                                    key: animatedSliverListKey,
                                                                    //rebuild不会影响内部 initialItemCount 只能分离逻辑了
                                                                    initialItemCount: contentDetail!.contentRepliedComment!.length,
                                                                    itemBuilder: (_, contentCommentIndex, animation) {
                                                    
                                                                        /// 用户添加回复时:
                                                                        if (contentCommentIndex >= resultCommentCount) {
                                                    
                                                                            // 但因为 animatedList 的 特质 
                                                                            // 会出现 相等甚至是超越 initialItemCount 的 index(明明没insert)
                                                                            if (
                                                                            contentCommentIndex >= resultCommentCount + userCommentMap.length
                                                                            ) {
                                                                                return const SizedBox.shrink();
                                                                            }
                                                    
                                                                            return newRepliedContent(
                                                                                contentCommentIndex,
                                                                                contentInfo,
                                                                                animation
                                                                            );
                                                    
                                                                        }
                                                    
                                                                        /// 常规内容
                                                                        return RepaintBoundary(
                                                                          child: repliedContent(contentCommentIndex)
                                                                        );
                                                    
                                                                    },
                                                    
                                                                );
                                                            }
                                                        ),
                                                    );

                                                }
                                            );
                                        }
                                    ),
                                )
                            ),
                        );

                    }

                );
            },
        );
    }

    void initCotent() {

        final contentModel = getContentModel();
        final contentInfo = getContentInfo();

        final D? contentDetail = contentModel.contentDetailData[getSubContentID() ?? contentInfo.id] as D?;

        final currentEpCommentDetails = contentDetail?.contentRepliedComment;

        debugPrint("contentDetail?.detailID: ${contentDetail?.detailID} currentEpCommentDetails:${currentEpCommentDetails?.length} ");

        if (currentEpCommentDetails != null) {
            resultFilterCommentList = [...currentEpCommentDetails];                                               

            recordHistorySurf(contentInfo, contentDetail);
            isContentInitaled = true;

            if (commentFilterTypeNotifier.value == BangumiCommentRelatedType.id) {

                debugPrint("trigged referContentID: ${getReferPostContentID()}");

                resultFilterCommentList = filterCommentList(
                    commentFilterTypeNotifier.value,
                    resultFilterCommentList,
                    referID: getReferPostContentID()
                );

                WidgetsBinding.instance.addPostFrameCallback((_) {
                        debugPrint("measure height:${authorContentKey.currentContext?.size?.height},result:${(authorContentKey.currentContext?.size?.height ?? 300) - kToolbarHeight - scrollController.offset}");
                        scrollController.animateTo(
                            max(0, (authorContentKey.currentContext?.size?.height ?? 300) - kToolbarHeight - MediaQuery.sizeOf(context).height / 3),
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOut,
                        );

                    });

            }

        }

    }

    void recordHistorySurf(I contentInfo, D? contentDetail) {
        if (contentDetail?.detailID != 0) {

            String? subjectTitle = sourceTitle();

            if (getPostCommentType() == PostCommentType.replyBlog) {
                if (sourceTitle() != null) {
                    subjectTitle = sourceTitle()!.contains('[日志]') ? sourceTitle() : '[日志] ${sourceTitle()}';
                }

                else {
                    subjectTitle = '[日志]';
                }
            }

            final accessID = getSubContentID() ?? contentInfo.id ?? 0;

            switch (getPostCommentType()){

                case PostCommentType.replyTopic:
                case PostCommentType.replyBlog:
                {

                    if (accessID == 0) break;

                    if (MyHive.historySurfDataBase.keys.contains(accessID)) {

                        MyHive.historySurfDataBase.get(accessID)?.sourceTitle.let((sourceTitle) {
                                if (sourceTitle == "帖子" || sourceTitle == "博客") {

                                    final historyModel = HistoryModel.instance;

                                    subjectTitle = historyModel.dataSource.firstWhere((surfTimelineDetails) {
                                            return 
                                            surfTimelineDetails.detailID == getContentModel().subjectID &&
                                                surfTimelineDetails.sourceTitle == null
                                            ;
                                        }).title;

                                }
                            });

                        MyHive.historySurfDataBase.put(
                            accessID,
                            MyHive.historySurfDataBase.get(accessID)!
                                ..sourceTitle = subjectTitle
                                ..updatedAt = DateTime.now().millisecondsSinceEpoch
                                ..replies = contentDetail?.contentRepliedComment?.length ?? 0
                        );

                    }

                    else {

                        MyHive.historySurfDataBase.put(
                            accessID,
                            SurfTimelineDetails(
                                detailID: getSubContentID() ?? contentInfo.id ?? 0,
                            )
                                ..updatedAt = DateTime.now().millisecondsSinceEpoch
                                ..title = contentDetail?.contentTitle ?? contentInfo.contentTitle
                                ..sourceTitle = subjectTitle
                                ..sourceID = contentInfo.sourceID
                                ..bangumiSurfTimelineType = BangumiSurfTimelineType.fromPostCommentType(getPostCommentType())
                                ..replies = contentDetail?.contentRepliedComment?.length ?? 0
                                ..commentDetails = (
                            CommentDetails()
                                ..userInformation = contentDetail?.userInformation ?? contentInfo.userInformation
                            )
                        );

                    }

                }

                default:{}

            }

        }

    }

    Widget authorContent(I contentInfo, D? contentDetail) {

        return Column(
            key: authorContentKey,
            spacing: 12,
            children: [

                EpCommentView(
                    contentID: contentInfo.id ?? 0,
                    postCommentType: getPostCommentType(),
                    //epCommentData: authorEPCommentData,
                    epCommentData: EpCommentDetails.fromContentDetail(
                        contentDetail,
                        getSubContentID() ?? contentInfo.id
                    ),

                    themeColor: readableThemeColor,
                ),

                ...List.generate(
                    getTrailingPhotosUri()?.length ?? 0,
                    (index) {
                        return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: CachedNetworkImage(
                                imageUrl: getTrailingPhotosUri()![index],
                                httpHeaders: HttpApiClient.broswerHeader,
                            ),
                        );
                    }
                ),

                GeneralRepliedLine(
                    repliedCount: max(0, resultFilterCommentList.length) + userCommentMap.length,
                    commentFilterTypeNotifier: commentFilterTypeNotifier,
                    isUserContent: true,
                    onCommentFilter: (filterCommentType) {

                        resultFilterCommentList = filterCommentList(
                            filterCommentType,
                            contentDetail!.contentRepliedComment!,
                            referID: contentDetail.userInformation?.userID
                        );

                        debugPrint("filter content resultFilterCommentList: ${resultFilterCommentList.length}");

                    },
                ),

                Divider(color: Colors.grey.withValues(alpha: 0.8)),

                //无评论的显示状态
                if(resultFilterCommentList.isEmpty && userCommentMap.isEmpty)
                const SizedBox(
                    height: 64,
                    child: Center(
                        child: ScalableText("暂无评论..."),
                    ),
                )

            ],
        );

    }

    Widget repliedContent(
        int contentCommentIndex,
    ) {

      final currentEpCommentDetails = resultFilterCommentList[contentCommentIndex];

        debugPrint(
          "[CommentIndex:$contentCommentIndex Rebuild]"
          "[commentID:${currentEpCommentDetails.commentID}}]"
        );

        return Column(
            children: [

              BangumiGeneralContentComment(
                currentEpCommentDetails: currentEpCommentDetails, 
                postCommentType: getPostCommentType(),
                contentID: currentEpCommentDetails.contentID ?? getContentInfo().id ?? 0,
                authorID: getContentInfo().userInformation?.userID,
                themeColor: readableThemeColor,
                onUpdateComment: (content) {
                    if (content == null) {
                      removeCommentAction(contentCommentIndex, currentEpCommentDetails);
                    }

                    else {
                      userCommentMap[contentCommentIndex] = content;
                    }
                },
              ),

                if(contentCommentIndex < max(0, resultFilterCommentList.length) + userCommentMap.length - 1)
                Divider(
                    thickness: 0.5,
                    height: 1,
                    color: 
                      judgeDarknessMode(context) ? 
                      getcurrentSubjectThemeColor() : 
                      readableThemeColor
                ),

            ],
        );

    }

    Widget newRepliedContent(
        int contentCommentIndex,
        I contentInfo,
        Animation<double> animation
    ) {

        bool isFiltered = false;

        final D? contentDetail = getContentModel().contentDetailData[getSubContentID() ?? contentInfo.id] as D?;
        int commentListCount = (getCommentCount(contentDetail, false) ?? 0);

        if (resultFilterCommentList.length != commentListCount) isFiltered = true;

        int newFloor = isFiltered ? 
            commentListCount + contentCommentIndex + 1 :
            contentCommentIndex + 1
        ;

        int newCommentID = isFiltered ?
            userCommentMap.keys.elementAt(newFloor - (commentListCount + contentCommentIndex + 1)) :
            userCommentMap.keys.elementAt(newFloor - (contentCommentIndex + 1))
        ;

        final currentEpCommentDetails = EpCommentDetails()
            ..userInformation = AccountModel.loginedUserInformations.userInformation
            ..contentID = contentInfo.id
            ..commentID = newCommentID
            ..comment = userCommentMap[newCommentID]
            ..epCommentIndex = "$newFloor"
            ..commentTimeStamp = DateTime.now().millisecondsSinceEpoch ~/ 1000
        ;

        return fadeSizeTransition(
            animation: animation,
            child: Column(
                children: [

                    EpCommentView(
                        contentID: contentInfo.id ?? 0,
                        postCommentType: getPostCommentType(),
                        onUpdateComment: (content) {
                            if (content == null) {
                                userCommentMap.remove(currentEpCommentDetails.commentID);
                                removeCommentAction(contentCommentIndex, currentEpCommentDetails);
                            }

                            else {
                                userCommentMap[currentEpCommentDetails.commentID ?? 0] = content;
                            }      
                        },
                        epCommentData: currentEpCommentDetails,
                        themeColor: getcurrentSubjectThemeColor(),
                    ),

                    if(contentCommentIndex != resultFilterCommentList.length + userCommentMap.length - 1)
                    Divider(color: getcurrentSubjectThemeColor())
                ],
            )

        );
    }

    void removeCommentAction(
        int contentCommentIndex,
        EpCommentDetails currentEpCommentDetails,
    ) {

        final accountModel = context.read<AccountModel>();

        accountModel.toggleComment(
            contentID: currentEpCommentDetails.contentID,
            commentID: currentEpCommentDetails.commentID,
            actionType: UserContentActionType.delete,
            postCommentType: getPostCommentType(),
            fallbackAction: (message) {
                showRequestSnackBar(requestStatus: false, message: message, backgroundColor: judgeCurrentThemeColor(context));
            },
        ).then((resultID) {
                    if (resultID != 0) {

                        animatedSliverListKey.currentState?.removeItem(
                            contentCommentIndex,
                            duration: const Duration(milliseconds: 300),
                            (_, animation) {            
                                return fadeSizeTransition(
                                    animation: animation,
                                    child: EpCommentView(
                                        key: ValueKey(currentEpCommentDetails.commentID),
                                        contentID: getContentInfo().id ?? 0,
                                        epCommentData: currentEpCommentDetails,
                                        themeColor: getcurrentSubjectThemeColor(),
                                    ),
                                );
                            }
                        );

                    }
                });

    }

}



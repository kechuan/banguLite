import 'dart:math';

import 'package:bangu_lite/internal/bangumi_define/bangumi_social_hub.dart';
import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/lifecycle.dart';
import 'package:bangu_lite/internal/proxy_cache.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/internal/services/history_recorder.dart';
import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/internal/utils/convert.dart';
import 'package:bangu_lite/internal/utils/get.dart';
import 'package:bangu_lite/internal/utils/judge.dart';
import 'package:bangu_lite/models/informations/subjects/base_details.dart';
import 'package:bangu_lite/models/informations/subjects/base_info.dart';
import 'package:bangu_lite/models/informations/subjects/comment_details.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/models/providers/base_model.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:bangu_lite/widgets/components/general_replied_line.dart';
import 'package:bangu_lite/widgets/fragments/animated/animated_transition.dart';
import 'package:bangu_lite/widgets/fragments/bangumi_content_appbar.dart';
import 'package:bangu_lite/widgets/fragments/comment_filter.dart';
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

/// 组合式帖子/日志详情通用视图，替代原先 4 泛型 14 钩子的 `BangumiContentPageState` 继承体系。
class BangumiGeneralContentView<
    M extends BaseModel,
    I extends ContentInfo,
    D extends ContentDetails> extends StatefulWidget {
  const BangumiGeneralContentView({
    super.key,
    required this.contentModel,
    required this.contentInfo,
    required this.createEmptyDetailData,
    required this.getWebUrl,
    required this.postCommentType,
    required this.loadContent,
    this.themeColor,
    this.subContentID,
    this.sourceTitle,
    this.referPostContentID,
    this.isContentLoading,
    this.getCommentCount,
    this.getTrailingPhotosUri,
  });

  final M contentModel;
  final I contentInfo;
  final D Function() createEmptyDetailData;
  final String Function(int? contentID) getWebUrl;
  final PostCommentType postCommentType;
  final Future<void> Function(int contentID, {bool isRefresh}) loadContent;

  final Color? themeColor;
  final int? subContentID;
  final String? sourceTitle;
  final int? referPostContentID;

  final bool Function(M model, int? contentID)? isContentLoading;
  final int? Function(D? contentDetail, bool isLoading)? getCommentCount;
  final List<String>? Function(M model)? getTrailingPhotosUri;

  @override
  State<BangumiGeneralContentView<M, I, D>> createState() =>
  _BangumiGeneralContentViewState<M, I, D>();
}

class _BangumiGeneralContentViewState<
    M extends BaseModel,
    I extends ContentInfo,
    D extends ContentDetails> extends LifecycleRouteState<BangumiGeneralContentView<M, I, D>> {

  bool isContentInitialed = false;
  Future? contentFuture;

  final scrollController = ScrollController();
  final GlobalKey<SliverAnimatedListState> animatedSliverListKey = GlobalKey();
  final GlobalKey authorContentKey = GlobalKey();

  final refreshNotifier = ValueNotifier(0);

  late final commentFilterTypeNotifier = ValueNotifier(
    widget.referPostContentID != null
      ? BangumiCommentRelatedType.id
      : BangumiCommentRelatedType.normal,
  );

  List<EpCommentDetails> resultFilterCommentList = [];

  // 仅记录本页面新发布的评论，避免与全局 IndexModel.userCommentMap 串扰
  final Map<int, String> userCommentMap = {};

  Color? readableThemeColor;

  int? get targetContentID => widget.subContentID ?? widget.contentInfo.id;

  bool checkContentLoading(int? contentID) {
    if (widget.isContentLoading != null) {
      return widget.isContentLoading!(widget.contentModel, contentID);
    }

    return widget.contentModel.isDetailLoading(contentID);
  }

  int? readCommentCount(D? contentDetail, bool isLoading) {
    if (widget.getCommentCount != null) {
      return widget.getCommentCount!(contentDetail, isLoading);
    }

    if (isLoading || contentDetail == null) return null;

    return contentDetail.contentRepliedComment?.length ?? 0;
  }

  Color getSubjectThemeColor(BuildContext context) =>
    getDetailRenderColor(context, widget.themeColor);

  @override
  void initState() {
    debugPrint(
      '[GeneralContent] ${widget.contentInfo.runtimeType} ID / subContentID: ${widget.contentInfo.id} / ${widget.subContentID}',
    );

    contentFuture = widget.contentInfo.loadInterceptionCallback?.call() ??
      widget.loadContent(targetContentID ?? 0);

    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    refreshNotifier.dispose();
    commentFilterTypeNotifier.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contentModel = widget.contentModel;
    final contentInfo = widget.contentInfo;

    final bool isDarkMode = judgeDarknessMode(context);
    final Color? darkSurfaceColor = isDarkMode ? getDarkContentSurfaceColor(context) : null;
    final Color subjectThemeColor = getSubjectThemeColor(context);

    readableThemeColor = convertFineTuneColor(
      subjectThemeColor,
      darkMode: isDarkMode,
      lumiScaleType: ScaleType.min,
    );

    return ChangeNotifierProvider<M>.value(
      value: contentModel,
      builder: (_, __) {
        return EasyRefresh.builder(
          //跨越这个context读取 ChangeNotifierProvider<M>.value 之内的 context
          childBuilder: (context, physic) {
            return Theme(
              data: Theme.of(context).copyWith(
                scaffoldBackgroundColor: isDarkMode
                  ? darkSurfaceColor
                  : convertFineTuneColor(
                    subjectThemeColor,
                    lumiScaleType: ScaleType.min,
                  ),
              ),
              child: Scaffold(
                body: Selector<M, D>(
                  selector: (_, model) =>
                    (model.contentDetailData[targetContentID] as D?) ??
                    widget.createEmptyDetailData(),
                  shouldRebuild: (previous, next) => previous != next,
                  builder: (_, contentDetailData, contentComment) => Scrollbar(
                    thumbVisibility: true,
                    interactive: true,
                    thickness: 3,
                    controller: scrollController,
                    child: SelectionArea(
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
                                    contentID: targetContentID,
                                    titleText: contentDetailData.contentTitle ?? contentInfo.contentTitle,
                                    webUrl: widget.getWebUrl(targetContentID),
                                    postCommentType: widget.postCommentType,
                                    surfaceColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
                                    onSendMessage: (content) {
                                      userCommentMap.addAll({content.$1 ?? 0: content.$2 as String});
                                      final insertIndex = max(0, resultFilterCommentList.length + userCommentMap.length - 1);

                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                        animatedSliverListKey.currentState?.insertItem(insertIndex);
                                      });
                                    },
                                  ),
                                ),
                              ),

                              FutureBuilder(
                                future: contentFuture,
                                builder: (_, snapshot) {
                                  final bool isCommentLoading =
                                    checkContentLoading(targetContentID) && contentInfo.id != unExistID;

                                  if (snapshot.hasError) {
                                    return SizedBox(
                                      height: MediaQuery.sizeOf(context).height,
                                      width: MediaQuery.sizeOf(context).width,
                                      child: ErrorLoadPrompt(
                                        message: snapshot.error,
                                        onRetryAction: () {
                                          contentFuture = widget
                                            .loadContent(targetContentID ?? 0, isRefresh: true)
                                            .then((_) => initContent());
                                          refreshNotifier.value += 1;
                                        },
                                      ),
                                    );
                                  }

                                  if (!isContentInitialed) initContent();

                                  return isCommentLoading
                                    ? Skeletonizer.sliver(
                                      enabled: true,
                                      child: SliverList(
                                        delegate: SliverChildBuilderDelegate((_, index) {
                                          if (index == 0) {
                                            return const Padding(
                                              padding: EdgeInsetsGeometry.only(top: 50, bottom: 125),
                                              child: SkeletonListTileTemplate(scaleType: ScaleType.medium),
                                            );
                                          }

                                          return const SkeletonListTileTemplate(scaleType: ScaleType.min);
                                        }),
                                      ),
                                    )
                                    : authorContent(contentInfo, contentDetailData);
                                },
                              ),

                              contentComment!,
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  child: ValueListenableBuilder(
                    valueListenable: refreshNotifier,
                    builder: (_, __, ___) {
                      return FutureBuilder(
                        future: contentFuture,
                        builder: (_, snapshot) {
                          final bool isCommentLoading =
                            checkContentLoading(targetContentID) && contentInfo.id != unExistID;
                          final D? contentDetail = contentModel.contentDetailData[targetContentID] as D?;

                          if (snapshot.data == false && contentDetail?.detailID == 0) {
                            return const Center(child: SizedBox.shrink());
                          }

                          if (isCommentLoading) return const SizedBox.shrink();

                          final int resultCommentCount = resultFilterCommentList.length;

                          return SliverSafeArea(
                            top: false,
                            sliver: SliverPadding(
                              padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + 20),
                              sliver: ValueListenableBuilder(
                                valueListenable: commentFilterTypeNotifier,
                                builder: (_, commentFilterType, __) {
                                  return SliverAnimatedList(
                                    key: animatedSliverListKey,
                                    initialItemCount: contentDetail?.contentRepliedComment?.length ?? 0,
                                    itemBuilder: (_, contentCommentIndex, animation) {
                                      if (contentCommentIndex >= resultCommentCount) {
                                        if (contentCommentIndex >= resultCommentCount + userCommentMap.length) {
                                          return const SizedBox.shrink();
                                        }

                                        debugPrint("[contentComment Rebuild]: Floor #$contentCommentIndex");

                                        return newRepliedContent(
                                          contentCommentIndex,
                                          contentInfo,
                                          animation,
                                        );
                                      }

                                      return RepaintBoundary(
                                        child: repliedContent(contentCommentIndex, contentDetail),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void initContent() {
    final contentModel = widget.contentModel;
    final contentInfo = widget.contentInfo;
    final D? contentDetail = contentModel.contentDetailData[targetContentID] as D?;
    final currentEpCommentDetails = contentDetail?.contentRepliedComment;

    debugPrint(
      "contentDetail?.detailID: ${contentDetail?.detailID} currentEpCommentDetails:${currentEpCommentDetails?.length} ",
    );

    if (currentEpCommentDetails != null) {
      resultFilterCommentList = [...currentEpCommentDetails];

      HistoryRecorder.recordContentVisit(
        contentInfo: contentInfo,
        contentDetail: contentDetail,
        postCommentType: widget.postCommentType,
        subContentID: widget.subContentID,
        sourceTitle: widget.sourceTitle,
        modelSubjectID: contentModel.subjectID,
      );

      isContentInitialed = true;

      if (commentFilterTypeNotifier.value == BangumiCommentRelatedType.id) {
        debugPrint("trigged referContentID: ${widget.referPostContentID}");

        resultFilterCommentList = filterCommentList(
          commentFilterTypeNotifier.value,
          resultFilterCommentList,
          referID: widget.referPostContentID,
        );

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || !scrollController.hasClients) return;

          debugPrint(
            "measure height:${authorContentKey.currentContext?.size?.height},result:${(authorContentKey.currentContext?.size?.height ?? 300) - kToolbarHeight - scrollController.offset}",
          );

          scrollController.animateTo(
            max(0, (authorContentKey.currentContext?.size?.height ?? 300) - kToolbarHeight - MediaQuery.sizeOf(context).height / 3),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        });
      }
    }
  }

  Widget authorContent(I contentInfo, D? contentDetail) {
    final trailingPhotos = widget.getTrailingPhotosUri?.call(widget.contentModel);

    return Column(
      key: authorContentKey,
      spacing: 12,
      children: [
        MultiProvider(
          providers: [
            Provider<EpCommentDetails>.value(
              value: EpCommentDetails.fromContentDetail(
                contentDetail,
                contentDetail?.firstPostID ?? targetContentID,
              ),
            ),
            Provider<EpCommentViewConfig>.value(
              value: EpCommentViewConfig(
                contentID: contentInfo.id ?? 0,
                postCommentType: widget.postCommentType,
                authorID: contentDetail?.userInformation?.userID,
                themeColor: readableThemeColor,
              ),
            ),
          ],
          child: const EpCommentView(),
        ),

        ...List.generate(
          trailingPhotos?.length ?? 0,
          (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: CachedNetworkImage(
                imageUrl: trailingPhotos![index],
                httpHeaders: HttpApiClient.browserHeader,
                cacheManager: judgeIsProxyMode(context)
                  ? ProxyCacheManager(proxyAddress: HttpApiClient.currentProxyAddress)
                  : null,
              ),
            );
          },
        ),

        GeneralRepliedLine(
          repliedCount: max(0, resultFilterCommentList.length) + userCommentMap.length,
          commentFilterTypeNotifier: commentFilterTypeNotifier,
          isUserContent: true,
          onCommentFilter: (filterCommentType) {

            resultFilterCommentList = filterCommentList(
              filterCommentType,
              contentDetail!.contentRepliedComment!,
              referID: contentDetail.userInformation?.userID,
            );

            debugPrint("filter content resultFilterCommentList: ${resultFilterCommentList.length}");
          },
        ),

        Divider(color: Colors.grey.withValues(alpha: 0.8)),

        if (resultFilterCommentList.isEmpty && userCommentMap.isEmpty)
        const SizedBox(
          height: 64,
          child: Center(
            child: ScalableText("暂无评论..."),
          ),
        ),
      ],
    );
  }

  Widget repliedContent(int contentCommentIndex, D? contentDetail) {
    final currentEpCommentDetails = resultFilterCommentList[contentCommentIndex];
    final int uiFloorIndex =
      (contentCommentIndex + 1) + (widget.postCommentType == PostCommentType.replyEpComment ? 0 : 1);
    final subjectThemeColor = getSubjectThemeColor(context);

    debugPrint(
      "[postCommentType]: ${widget.postCommentType}"
      "[Floor data:$contentCommentIndex ui:$uiFloorIndex] "
      "[commentID:${currentEpCommentDetails.commentID}] "
      "[state]: ${currentEpCommentDetails.state} "
      "[text length]: ${currentEpCommentDetails.comment?.length} ",
    );

    return Column(
      children: [
        MultiProvider(
          key: ValueKey(currentEpCommentDetails.commentID),
          providers: [
            Provider<EpCommentDetails>.value(
              value: currentEpCommentDetails..epCommentIndex = "$uiFloorIndex",
            ),
            Provider<EpCommentViewConfig>.value(
              value: EpCommentViewConfig(
                contentID: currentEpCommentDetails.contentID ?? widget.contentInfo.id ?? 0,
                postCommentType: widget.postCommentType,
                onUpdateComment: (content) {
                  if (content != null) {
                    context.read<IndexModel>().updateUserCommentMap(
                      currentEpCommentDetails.commentID ?? 0,
                      content,
                    );
                  }

                  else {
                    removeCommentAction(contentCommentIndex, currentEpCommentDetails);
                  }
                },
                authorID: contentDetail?.userInformation?.userID,
                themeColor: readableThemeColor,
              ),
            ),
          ],
          child: const EpCommentView(),
        ),

        if (contentCommentIndex < max(0, resultFilterCommentList.length) + userCommentMap.length - 1)
        Divider(
          thickness: judgeDarknessMode(context) ? 0.5 : 0.75,
          height: 1,
          color: judgeDarknessMode(context) ? subjectThemeColor : Colors.grey,
        ),
      ],
    );
  }

  Widget newRepliedContent(
    int contentCommentIndex,
    I contentInfo,
    Animation<double> animation,
  ) {
    bool isFiltered = false;

    final D? contentDetail = widget.contentModel.contentDetailData[targetContentID] as D?;
    final int commentListCount = readCommentCount(contentDetail, false) ?? 0;

    if (resultFilterCommentList.length != commentListCount) isFiltered = true;

    final int localIndex = contentCommentIndex - resultFilterCommentList.length;

    if (localIndex < 0 || localIndex >= userCommentMap.length) {
      return const SizedBox.shrink();
    }

    final int newFloor = isFiltered
      ? commentListCount + localIndex + 1
      : contentCommentIndex + 1;

    final int newCommentID = userCommentMap.keys.elementAt(localIndex);
    final subjectThemeColor = getSubjectThemeColor(context);

    final currentEpCommentDetails = EpCommentDetails()
      ..userInformation = AccountModel.loginedUserInformations.userInformation
      ..contentID = contentInfo.id
      ..commentID = newCommentID
      ..comment = userCommentMap[newCommentID]
      ..epCommentIndex = "$newFloor"
      ..commentTimeStamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    return fadeSizeTransition(
      animation: animation,
      child: Column(
        children: [
          MultiProvider(
            providers: [

              Provider<EpCommentDetails>.value(value: currentEpCommentDetails),
              Provider<EpCommentViewConfig>.value(
                value: EpCommentViewConfig(
                  contentID: contentInfo.id ?? 0,
                  postCommentType: widget.postCommentType,
                  onUpdateComment: (content) {
                    if (content == null) {
                      userCommentMap.remove(currentEpCommentDetails.commentID);
                      removeCommentAction(contentCommentIndex, currentEpCommentDetails);
                    }

                    else {
                      final targetCommentID = currentEpCommentDetails.commentID ?? 0;
                      userCommentMap[targetCommentID] = content;
                      context.read<IndexModel>().updateUserCommentMap(targetCommentID, content);
                    }
                  },
                  themeColor: subjectThemeColor,
                ),
              ),

            ],
            child: const EpCommentView(),
          ),

          if (contentCommentIndex != resultFilterCommentList.length + userCommentMap.length - 1)

          Divider(
            thickness: 0.25,
            height: 1,
            color: subjectThemeColor,
          ),
        ],
      ),
    );
  }

  void removeCommentAction(
    int contentCommentIndex,
    EpCommentDetails currentEpCommentDetails,
  ) {

    final accountModel = context.read<AccountModel>();
    final subjectThemeColor = getSubjectThemeColor(context);

    accountModel.toggleComment(
      contentID: currentEpCommentDetails.contentID,
      commentID: currentEpCommentDetails.commentID,
      actionType: UserContentActionType.delete,
      postCommentType: widget.postCommentType,
      fallbackAction: (message) {

        showRequestSnackBar(
          requestStatus: false,
          message: message,
          backgroundColor: getCurrentThemeColor(context),
        );

      },
    ).then((resultID) {
        if (resultID != 0) {

          animatedSliverListKey.currentState?.removeItem(
            contentCommentIndex,
            duration: const Duration(milliseconds: 300),
            (_, animation) {
              return fadeSizeTransition(
                animation: animation,
                child: MultiProvider(
                  providers: [
                    Provider<EpCommentDetails>.value(value: currentEpCommentDetails),
                    Provider<EpCommentViewConfig>.value(
                      value: EpCommentViewConfig(
                        contentID: widget.contentInfo.id ?? 0,
                        postCommentType: widget.postCommentType,
                        themeColor: subjectThemeColor,
                      ),
                    ),
                  ],
                  child: const EpCommentView(),
                ),
              );
            },
          );

        }
      });
  }
}

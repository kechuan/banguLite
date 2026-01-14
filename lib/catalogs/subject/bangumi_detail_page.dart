
import 'package:bangu_lite/internal/bangumi_define/bangumi_social_hub.dart';
import 'package:bangu_lite/internal/hive.dart';
import 'package:bangu_lite/models/informations/subjects/comment_details.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/models/providers/relation_model.dart';
import 'package:bangu_lite/models/providers/review_model.dart';
import 'package:bangu_lite/models/informations/surf/surf_timeline_details.dart';
import 'package:bangu_lite/models/informations/surf/user_details.dart';
import 'package:bangu_lite/widgets/components/bangumi_detail_recent_review.dart';
import 'package:bangu_lite/widgets/components/bangumi_detail_relations.dart';
import 'package:bangu_lite/widgets/fragments/refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';

import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:url_launcher/url_launcher_string.dart';

import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/internal/lifecycle.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/providers/comment_model.dart';
import 'package:bangu_lite/models/providers/ep_model.dart';
import 'package:bangu_lite/models/providers/topic_model.dart';
import 'package:bangu_lite/widgets/components/bangumi_detail_topics.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/fragments/toggle_theme_mode_button.dart';
import 'package:bangu_lite/models/informations/subjects/bangumi_details.dart';
import 'package:bangu_lite/models/providers/bangumi_model.dart';
import 'package:bangu_lite/widgets/components/bangumi_detail_intro.dart';
import 'package:bangu_lite/widgets/components/bangumi_hot_comment.dart';
import 'package:bangu_lite/widgets/components/bangumi_summary.dart';


@FFRoute(name: '/subjectDetail')

class BangumiDetailPage extends StatefulWidget {
    const BangumiDetailPage({
        super.key,
        required this.subjectID,
        this.injectBangumiInfoDetail
    });

    final int subjectID;

    //预先信息注入 只会在直接在首页等已拥有部分info信息的渠道触发
    final BangumiDetails? injectBangumiInfoDetail;

    @override
    State<BangumiDetailPage> createState() => _BangumiDetailPageState();
}


class _BangumiDetailPageState extends LifecycleRouteState<BangumiDetailPage> with RouteLifecycleMixin  {

    final ValueNotifier<String> appbarTitleNotifier = ValueNotifier<String>("");
    final ValueNotifier<bool> reviewsCollaspeStatusNotifier = ValueNotifier(false);
    final ValueNotifier<bool> topicsCollaspeStatusNotifier = ValueNotifier(false);

    @override
    Widget build(BuildContext context) {
        return MultiProvider(
            providers: [
                ChangeNotifierProvider(
                    create: (_) => BangumiModel(
                        subjectID: widget.subjectID,
                        bangumiDetails: widget.injectBangumiInfoDetail
                    )
                ),
                ChangeNotifierProvider(create: (_) => EpModel(subjectID: widget.subjectID, selectedEp: 1)),
                ChangeNotifierProvider(create: (_) => RelationModel(subjectID: widget.subjectID)),
                ChangeNotifierProvider(create: (_) => ReviewModel(subjectID: widget.subjectID)),
                ChangeNotifierProvider(create: (_) => TopicModel(subjectID: widget.subjectID)),
                ChangeNotifierProvider(create: (_) => CommentModel(subjectID: widget.subjectID)),
            ],
            child: Selector<BangumiModel, Color?>(
                selector: (_, bangumiModel) => bangumiModel.bangumiThemeColor,
                shouldRebuild: (previous, next) => previous != next,

                builder: (innerProviderContext, linearColor, detailScaffold) {          

                    debugPrint("linear color:$linearColor");

                    //EPModel 同步跟随
                    final epModel = innerProviderContext.read<EpModel>();
                    epModel.bangumiThemeColor = linearColor;

                    return Theme(
                      data: Theme.of(context).copyWith(
                        primaryColor: judgeDetailRenderColor(context, linearColor),
                        scaffoldBackgroundColor: judgeDetailRenderColor(context, linearColor),
                      ),

                      child: detailScaffold!,
                    );
                },
                child: Builder(
                    builder: (innerContext) {

                        //因为sliver的原因 commentModel 的 loadComments 会直到我触发了 HotComment 区域才开始加载。
                        //因此无法把用户评论获取放到那个页面 里 那么久只能直接放进这里了

                        final bangumiModel = innerContext.read<BangumiModel>();
                        final commentModel = innerContext.read<CommentModel>();

                        commentModel.loadUserComment(
                            currentUserInformation: AccountModel.loginedUserInformations.userInformation
                        );

                        return Scaffold(
                            appBar: AppBar(
                                backgroundColor: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.6),
                                title: ValueListenableBuilder(
                                    valueListenable: appbarTitleNotifier, 
                                    builder: (_, appbarTitle, __) => ScalableText(appbarTitle, style: const TextStyle(color: Colors.black, fontSize: 20))),
                                leading: IconButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    icon: const Icon(Icons.arrow_back)
                                ),
                                actions: [

                                    ToggleThemeModeButton(
                                        onThen: () {
                                            bangumiModel.getThemeColor(
                                                judgeDetailRenderColor(context, bangumiModel.imageColor),
                                                darkMode: !judgeDarknessMode(context) 
                                            //这里是为了 切换。是 target! 而不是状态 因此得取反向的值。
                                            );
                                        }
                                    ),

                                    const Padding(padding: PaddingH6),

                                    IconButton(
                                        onPressed: () async {
                                            if (await canLaunchUrlString(BangumiWebUrls.subject(widget.subjectID))) {
                                                await launchUrlString(BangumiWebUrls.subject(widget.subjectID));
                                            }
                                        },
                                        icon: Transform.rotate(
                                            angle: -45,
                                            child: const Icon(Icons.link),
                                        )
                                    )
                                ],
                            ),

                            body: NotificationListener<ScrollNotification>(
                                onNotification: (notification) {

                                    final double offset = notification.metrics.pixels; //scrollview 的 offset : 注意不要让更内层的scrollView影响到它监听

                                    if (offset >= 60) { 

                                        if (appbarTitleNotifier.value.isNotEmpty) return false;

                                        WidgetsBinding.instance.addPostFrameCallback((_) {
                                                appbarTitleNotifier.value = bangumiModel.bangumiDetails?.name ?? "";
                                            });
                                    }

                                    else {

                                        if (appbarTitleNotifier.value.isEmpty) return false;

                                        WidgetsBinding.instance.addPostFrameCallback((_) {
                                                appbarTitleNotifier.value = "";
                                            });

                                    }

                                    return false;
                                },

                                child: Selector<BangumiModel, int?>(
                                    selector: (_, bangumiModel) => bangumiModel.subjectID,
                                    shouldRebuild: (previous, next) {
                                        if (next == null) return false;
                                        //debugPrint("previous/next : $previous/$next");
                                        return previous != next;
                                    },
                                    builder: (_, subjectID, child) {

                                        debugPrint("subjectID: $subjectID => ${widget.subjectID}");

                                        return FutureBuilder(
                                            future: bangumiModel.loadDetails(),
                                            builder: (_, snapshot) {

                                                if (snapshot.connectionState == ConnectionState.done) {
                                                    debugPrint("parse ${widget.subjectID} done ,builderStamp: ${DateTime.now()}");

                                                    MyHive.historySurfDataBase.put(
                                                        widget.subjectID,
                                                        SurfTimelineDetails(
                                                            detailID: widget.subjectID
                                                        )
                                                            ..updatedAt = DateTime.now().millisecondsSinceEpoch
                                                            ..title = bangumiModel.bangumiDetails?.name ?? ""
                                                            ..bangumiSurfTimelineType = BangumiSurfTimelineType.subject
                                                            ..commentDetails = (
                                                        CommentDetails()
                                                            ..userInformation = (
                                                        UserInformation()
                                                            ..avatarUrl = bangumiModel.bangumiDetails?.coverUrl
                                                        )
                                                        )

                                                    );
                                                }

                                                /// 预先信息注入(假设有) 可以获取少量信息进入布局页面
                                                /// 通常注入信息会缺失summary 因此可用此进行判断?
                                                BangumiDetails? currentSubjectDetail = bangumiModel.bangumiDetails ?? widget.injectBangumiInfoDetail; //dependency

                                                return EasyRefresh(
                                                    header: const TextHeader(),
                                                    footer: const TextFooter(),
                                                    onRefresh: () {
                                                        bangumiModel.loadDetails(isRefresh: true);
                                                        context.read<CommentModel>().loadComments(isReloaded: true);
                                                        context.read<TopicModel>().loadSubjectContentList(isReloaded: true);
                                                        context.read<ReviewModel>().loadSubjectContentList(isReloaded: true);
                                                    },

                                                    child: CustomScrollView(
                                                        cacheExtent: 1000,
                                                        slivers: [
                                                            Skeletonizer.sliver(
                                                                enabled: currentSubjectDetail?.summary == null,
                                                                //enabled: bangumiModel.bangumiDetails == null,
                                                                child: Selector<BangumiModel, Color?>(
                                                                    selector: (_, bangumiModel) => bangumiModel.bangumiThemeColor,
                                                                    shouldRebuild: (previous, next) => previous != next,
                                                                    builder: (_, linearColor, detailChild) {

                                                                        return TweenAnimationBuilder<Color?>(
                                                                            tween: ColorTween(
                                                                                begin: judgeCurrentThemeColor(context),
                                                                                end: judgeDarknessMode(context) ? Colors.black : judgeDetailRenderColor(context, linearColor),
                                                                            ),
                                                                            duration: const Duration(milliseconds: 500),
                                                                            builder: (_, linearColor, __) {

                                                                                return DecoratedSliver(
                                                                                    decoration: BoxDecoration(
                                                                                        gradient: LinearGradient(
                                                                                            begin: Alignment.topCenter,
                                                                                            end: Alignment.bottomCenter,
                                                                                            colors: [
                                                                                                judgeDarknessMode(context) ? Colors.black : Colors.white,
                                                                                                judgeDarknessMode(context) ? Colors.black.withValues(alpha: 0.6) : linearColor!.withValues(alpha: 0.8),
                                                                                                
                                                                                            ]
                                                                                        )
                                                                                    ),
                                                                                    sliver: detailChild,

                                                                                );

                                                                            },

                                                                        );

                                                                    },
                                                                    child: SliverPadding(
                                                                        padding: Padding16,
                                                                        sliver: SliverList(
                                                                            delegate: SliverChildListDelegate(
                                                                                [
                                                                                    const BangumiDetailIntro(),

                                                                                    const BangumiSummary(),

                                                                                    const BangumiDetailRecentReview(),

                                                                                    const BangumiDetailRelations(),

                                                                                    const BangumiDetailTopics(),

                                                                                    NotificationListener<ScrollNotification>(
                                                                                        onNotification: (_) => true,
                                                                                        child: const BangumiHotComment()
                                                                                    ),
                                                                                ]
                                                                            )
                                                                        ),
                                                                    )

                                                                ),

                                                            ),
                                                        ],
                                                    )
                                                );

                                            },

                                        );

                                    },
                                ),
                            )

                        );
                    }
                )

            ),
        );

    }


}

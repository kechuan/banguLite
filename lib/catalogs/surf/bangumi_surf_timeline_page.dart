
import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/internal/bangumi_define/bangumi_social_hub.dart';
import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/lifecycle.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:bangu_lite/widgets/fragments/request_snack_bar.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/views/timeline_list_view.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


@FFRoute(name: '/Timeline')
class BangumiTimelinePage extends StatefulWidget {
  const BangumiTimelinePage({
      super.key,
  });

  @override
  State<BangumiTimelinePage> createState() => _BangumiTimelinePageState();
}

class _BangumiTimelinePageState extends LifecycleRouteState<BangumiTimelinePage> with SingleTickerProviderStateMixin, RouteLifecycleMixin  {

    final ValueNotifier<BangumiSurfGroupType> groupTypeNotifier = ValueNotifier(BangumiSurfGroupType.all);
    final PageController timelinePageController = PageController();
    final EasyRefreshController topicListViewEasyRefreshController = EasyRefreshController();
    late TabController tabController; // 新增TabController声明

    double residualOffset = 0.0;

    @override
    void initState() {

        super.initState();

        tabController = TabController(
            initialIndex: BangumiTimelineType.all.index,
            vsync: this,
            length: BangumiTimelineType.values.length,
        );

        tabController.addListener(() {

          debugPrint('[tabController] 差值:$residualOffset');
          if(residualOffset != 0.0) return;

          if (tabController.indexIsChanging && residualOffset.abs() < 0.5) {

              timelinePageController.animateToPage(
                  tabController.index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
              );

          }

      });

    }

    @override
    void dispose() {
        tabController.dispose();
        timelinePageController.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {

        return Scaffold(
            appBar: AppBar(
                title: const Text('浏览时间线'),
            ),
            floatingActionButton: 
              FloatingActionButton.extended(
                onPressed: () {

                  final accountModel = context.read<AccountModel>();
				          final indexModel = context.read<IndexModel>();

                  invokeRequestSnackBar({String? message,bool? requestStatus}) => showRequestSnackBar(
                    context,
                    message: message,
                    requestStatus: requestStatus,
                  );

                  invokeSendComment(String message) => accountModel.postContent(
                    content: message,
                    postContentType: PostCommentType.postTimeline,
                    actionType : UserContentActionType.post,
                    fallbackAction: (errorMessage)=> invokeRequestSnackBar(message: errorMessage,requestStatus: false)
                  );

                  onPostContent(int timelineID,String message) => Navigator.pushNamed(
                    context,
                    Routes.timelineChat,
                    arguments: {
                      'timelineID':timelineID, //时间线独有ID
                      'comment':message,
                    }
                  );

                  Navigator.pushNamed(
                    context,
                    Routes.sendComment,
                    arguments: {
                      'contentID':0, //时间线独有ID
                      'postCommentType':PostCommentType.postTimeline,
                      'title': '发表时间线吐槽',
                      'preservationContent': indexModel.draftContent[0]
                    }
                  ).then((content) async {

                    if(content is String){

                                          
                      //invokeRequestSnackBar(message: "UI回帖成功",requestStatus: true);
                      //onSendMessage?.call(content);
                      //  await accountModel.getTrunsTileToken().then((result){
                      //    debugPrint("$result");
                      //  });
                        

                      invokeRequestSnackBar();

                      //网络层 Callback
                      await invokeSendComment(content).then((resultID){
                        debugPrint("[PostContent] sendMessageresultID:$resultID SendContent: $content");
                        if(resultID != 0){
                          onPostContent(resultID,content);
                        }
                        
                      });

                    }
                    
                  });

                },
                label: const Row(
                  spacing: 6,
                  children: [
                    Icon(Icons.edit, color: Colors.black),
                    ScalableText("发帖",style: TextStyle(color: Colors.black)),
                  ],
                ),
            ),
            
            body: Column(
                children: [
                    TabBar( // 直接使用显式控制器
                        controller: tabController, // 关联控制器
                        onTap: (value) {

                            tabController.animateTo(value);

                            if ((value - timelinePageController.page!).abs() > 1) {
                                timelinePageController.jumpToPage(
                                    value,
                                );
                            }

                            else {
                                timelinePageController.animateToPage(
                                    value,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut
                                );
                            }

                        },
                        indicatorSize: TabBarIndicatorSize.tab,
                        tabs: List.generate(
                            BangumiTimelineType.values.length, (index) {

                                if (index == BangumiTimelineType.group.index) {
                                    return Tab(

                                        child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [

                                                ValueListenableBuilder(
                                                    valueListenable: groupTypeNotifier,
                                                    builder: (_, groupType, child) {
                                                        if (groupType == BangumiSurfGroupType.all) return const SizedBox.shrink();
                                                        return ScalableText(groupTypeNotifier.value.typeName, style: const TextStyle(fontSize: 12));
                                                    }
                                                ),

                                                Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                    spacing: 6,
                                                    children: [
                                                        ScalableText(BangumiTimelineType.values[index].typeName),

                                                        PopupMenuButton<BangumiSurfGroupType>(
                                                            padding: EdgeInsets.zero,
                                                            initialValue: BangumiSurfGroupType.all,
                                                            itemBuilder: (_) {
                                                                return BangumiSurfGroupType.values.map(
                                                                    (currentGroupType) {
                                                                        return PopupMenuItem<BangumiSurfGroupType>(
                                                                            value: currentGroupType,
                                                                            child: Text(currentGroupType.typeName),
                                                                        );
                                                                    }).toList();
                                                            },
                                                            onSelected: (value) {

                                                                timelinePageController.animateToPage(
                                                                    index,
                                                                    duration: const Duration(milliseconds: 300),
                                                                    curve: Curves.easeOut
                                                                ).then((_) {
                                                                  groupTypeNotifier.value = value;
                                                                  topicListViewEasyRefreshController.callRefresh();
                                                                });

                                                            },
                                                            child: const Icon(Icons.arrow_drop_down),

                                                        )

                                                    ],
                                                ),
                                            ],
                                        ),
                                    );
                                }

                                return Tab(text: BangumiTimelineType.values[index].typeName);
                            }
                        )
                    ),

                    Expanded(
                        child: EasyRefresh(
                            child: PageView.builder(
                                itemCount: BangumiTimelineType.values.length,
                                controller: timelinePageController,
                                onPageChanged: (value) {

                                    residualOffset = tabController.index - timelinePageController.page!;

                                    //debugPrint('差值:$residualOffset');

                                    if (residualOffset.abs() < 0.5) {
                                        return;
                                    }

                                    //EasyRefresh 手势 与 pageView 通病 无法同时使用

                                    timelinePageController.jumpToPage(tabController.index);
                                    

                                    tabController.animateTo(value);

                                },
                                itemBuilder: (_, timelineIndex) {
                                    return ValueListenableBuilder(
                                        valueListenable: groupTypeNotifier,
                                        builder: (_, currentGroupType, __) {

                                            return BangumiTimelineContentView(
                                                tabController: tabController, 
                                                timelinePageController: timelinePageController,
                                                groupTypeNotifier: groupTypeNotifier,
                                                topicListViewEasyRefreshController: topicListViewEasyRefreshController,

                                            );

                                        }
                                    );
                                },
                            ),
                        ),
                    )
                ],
            ),
        );
    }

}
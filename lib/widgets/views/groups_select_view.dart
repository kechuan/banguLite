import 'dart:math';

import 'package:bangu_lite/internal/bangumi_define/bangumi_social_hub.dart';
import 'package:bangu_lite/internal/custom_toaster.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/internal/utils/callback.dart';
import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/internal/utils/get.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/models/providers/groups_model.dart';
import 'package:bangu_lite/widgets/fragments/cached_image_loader.dart';
import 'package:bangu_lite/widgets/fragments/refresh_indicator.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupsSelectView extends StatefulWidget {
  const GroupsSelectView({
    super.key,
    //required this.animatedGroupsListController,
    required this.sliverAnimatedListKey,
    required this.expansibleController,
    required this.groupTitleNotifier, 

    this.loadGroupTopicCallback,

  });

  //final ScrollController animatedGroupsListController;
  final GlobalKey<SliverAnimatedListState> sliverAnimatedListKey;
  final ExpansibleController expansibleController;
  final ValueNotifier<String?> groupTitleNotifier;

  final Function(BuildContext, String?)? loadGroupTopicCallback;

  @override
  State<GroupsSelectView> createState() => _GroupsSelectViewState();
}

class _GroupsSelectViewState extends State<GroupsSelectView> with SingleTickerProviderStateMixin {

  final animatedGroupListController = ScrollController();
  final groupPageController = PageController();
  late TabController tabController;

  @override
  void initState() {

    super.initState();

    tabController = TabController(length: BangumiSurfGroupType.values.length - 1, vsync: this);

    tabController.addListener(() {
      groupPageController.animateToPage(
        tabController.index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      loadGroupsContent(context, tabController.index);
    });

  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [

        TabBar(
          controller: tabController,
          tabs: List.generate(
            BangumiSurfGroupType.values.length - 1,
            (index) => Tab(text: BangumiSurfGroupType.values[index].groupsType)
          ),
          indicatorSize: TabBarIndicatorSize.tab,
        ),

        SizedBox(
          height: 300,
          child: PageView.builder(
            controller: groupPageController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: BangumiSurfGroupType.values.length - 1,
            itemBuilder: (_, index) {
              return Padding(
                padding: Padding6,
                child: Consumer<GroupsModel>(
                  builder: (_, groupsModel, child) {
                    //GridView 与 PageView 冲突 
                    // 滑动的时候无法 滑动到外界的 PageView

                    //EasyRefresh 配合 滚动 onPageChanged 冲突 
                    int currentGroupCount = groupsModel.groupsData[BangumiSurfGroupType.values[index]]?.length ?? 0;
                    int displayCrossAxisCount = MediaQuery.sizeOf(context).width >= 800 ? 4 : 2;

                    return EasyRefresh(
                      footer: const TextFooter(),
                      onLoad: () => loadGroupsContent(context, tabController.index, isAppend: true),
                      triggerAxis: Axis.vertical,
                      child: 
                      currentGroupCount == 0 ? 
                      const Center(child: Text("¯\\_(ツ)_/¯")) :

                      GridView.builder(
                        scrollDirection: Axis.vertical,
                        primary: false,
                        controller: animatedGroupListController,
                        itemCount: 
                        currentGroupCount == 0 ? 
                        1 : 
                        currentGroupCount,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: displayCrossAxisCount,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                          mainAxisExtent: 100
                        ),
                        itemBuilder: (_, index) {

                          int currentRow = (index / displayCrossAxisCount).floor();
                          int currentColumn = index % displayCrossAxisCount;

                          return Container(
                            color: (currentRow + currentColumn) % 2 == 0 ? Colors.grey.withValues(alpha: 0.3) : null,
                            child: Column(

                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [

                                ListTile(

                                  onTap: () {

                                    String recordGroupTitle = widget.groupTitleNotifier.value ?? "";

                                    widget.groupTitleNotifier.value = groupsModel.groupsData[BangumiSurfGroupType.values[tabController.index]]?[index].groupTitle;
                                    groupsModel.selectedGroupInfo = groupsModel.groupsData[BangumiSurfGroupType.values[tabController.index]]?[index];
                                    widget.loadGroupTopicCallback?.call(context, recordGroupTitle);
                                  },

                                  leading: SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: CachedImageLoader(
                                      imageUrl: groupsModel.groupsData[BangumiSurfGroupType.values[tabController.index]]?[index].groupAvatar,
                                      borderDecoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),

                                  title: Row(
                                    spacing: 6,
                                    children: [

                                      Flexible(
                                        child: ScalableText(
                                          "${groupsModel.groupsData[BangumiSurfGroupType.values[tabController.index]]?[index].groupTitle}",
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),

                                ),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  spacing: 3,
                                  children: [
                                    const Icon(Icons.people, size: 16, color: Colors.grey),

                                    Text(
                                      "${groupsModel.groupsData[BangumiSurfGroupType.values[tabController.index]]?[index].membersCount}",

                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );

                        }
                      ),

                    );
                  },

                )
              );
            }
          ),
        ),
      ],
    );
  }

  void loadGroupsContent(
    BuildContext context,
    int index,
    {bool? isAppend}
  ) {
    invokeToaster({String? message}) => fadeToaster(color: getCurrentThemeColor(context), context: context, message: message ?? "没有更多内容了");

    final groupsModel = context.read<GroupsModel>();
    final accountModel = context.read<AccountModel>();

    final selectedGroupData = groupsModel.groupsData[BangumiSurfGroupType.values[index]];

    if (accountModel.isLogined() == false) {
      if (BangumiSurfGroupType.values[index] != BangumiSurfGroupType.all) {
        invokeToaster(message: "登录以获取更多内容");
        return;
      }
    }

    groupsModel.loadGroups(
      mode: BangumiSurfGroupType.values[index],
      offset: isAppend == true ? selectedGroupData!.length : 0,
      accessQuery: accountModel.isLogined() ? BangumiQuerys.bearerTokenAccessQuery(AccountModel.loginedUserInformations.accessToken) : null,
      fallbackAction: (message) {
        invokeToaster(message: message);
      },
    ).then((result) {

        List newSelectedGroupData = groupsModel.groupsData[BangumiSurfGroupType.values[index]]!;

        final int receiveLength = max(0, newSelectedGroupData.length);

        animatedListAppendContentCallback(
          result,
          isAppend == true ? selectedGroupData!.length : 0,
          receiveLength,
          fallbackAction: invokeToaster,
          animatedListController: animatedGroupListController
        );

        groupsModel.notifyListeners();

      });

  }

}

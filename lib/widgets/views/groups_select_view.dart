import 'dart:math';

import 'package:bangu_lite/internal/bangumi_define/bangumi_social_hub.dart';
import 'package:bangu_lite/internal/utils/callback.dart';
import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/internal/custom_toaster.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/models/providers/groups_model.dart';
import 'package:bangu_lite/widgets/fragments/cached_image_loader.dart';
import 'package:bangu_lite/widgets/fragments/refresh_indicator.dart';
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

  final Function(BuildContext)? loadGroupTopicCallback;

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

    tabController = TabController(length: BangumiSurfGroupType.values.length-1, vsync: this);
    
    tabController.addListener((){
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
            BangumiSurfGroupType.values.length-1,
            (index)=> Tab(text: BangumiSurfGroupType.values[index].groupsType)
          ),
          indicatorSize: TabBarIndicatorSize.tab,
        ),

        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: groupPageController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: BangumiSurfGroupType.values.length-1,
            itemBuilder: (_,index){
              return Padding(
                padding: Padding6,
                child: Consumer<GroupsModel>(
                builder: (_, groupsModel, child) {
                 //GridView 与 PageView 冲突 
                 // 滑动的时候无法 滑动到外界的 PageView

                  //EasyRefresh 配合 滚动 onPageChanged 冲突 
                  return EasyRefresh(
                    footer: const TextFooter(),
                    onLoad: () => loadGroupsContent(context, tabController.index,isAppend: true),
                    triggerAxis: Axis.vertical,
                    child: GridView.builder(
                      scrollDirection: Axis.vertical,
                      primary: false,
                      controller:animatedGroupListController,
                      itemCount: groupsModel.groupsData.values.elementAt(tabController.index).length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          mainAxisExtent: 180
                        ),
                      itemBuilder: (_,index){
                        return Column(
                          spacing: 20,
                          children: [
                          
                            Expanded(
                              child: InkResponse(
                              containedInkWell: true,
                              onTap: (){

                                widget.groupTitleNotifier.value = groupsModel.groupsData[BangumiSurfGroupType.values[tabController.index]]?[index].groupTitle;
                                groupsModel.selectedGroupInfo = groupsModel.groupsData[BangumiSurfGroupType.values[tabController.index]]?[index];
                                widget.loadGroupTopicCallback?.call(context);
                              },
                              
                              highlightColor: Colors.transparent,
                              child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                minWidth: 100,
                                minHeight: 120,
                              ),
                              
                              child: CachedImageLoader(
                                imageUrl: groupsModel.groupsData[BangumiSurfGroupType.values[tabController.index]]?[index].groupAvatar,
                                borderDecoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                              ),
                              ),
                            ),
                            ),
                          
                            SizedBox(
                              height: 65,
                              child: Center(
                                              
                                child: Text(
                                  "${groupsModel.groupsData[BangumiSurfGroupType.values[tabController.index]]?[index].groupTitle}"
                                  "\n(${groupsModel.groupsData[BangumiSurfGroupType.values[tabController.index]]?[index].membersCount}成员)",
                                  textAlign: TextAlign.center,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              
                            )
                            ),
                          
                          ],
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
    invokeToaster({String? message}) => fadeToaster(context: context, message: message ?? "没有更多内容了");

    final groupsModel = context.read<GroupsModel>();
    final accountModel = context.read<AccountModel>();

    final selectedGroupData = groupsModel.groupsData[BangumiSurfGroupType.values[index]];

    if(accountModel.isLogined() == false){
      if(BangumiSurfGroupType.values[index] != BangumiSurfGroupType.all){
        invokeToaster(message: "登录以获取更多内容");
        return;
      }
    }

    groupsModel.loadGroups(
      mode: BangumiSurfGroupType.values[index],
      offset: isAppend == true ? selectedGroupData!.length : 0,
      accessQuery: accountModel.isLogined() ? BangumiQuerys.bearerTokenAccessQuery(AccountModel.loginedUserInformations.accessToken) : null,
      fallbackAction: (message){
        invokeToaster(message: message);
      },
    ).then((result){
      
      List newSelectedGroupData = groupsModel.groupsData[BangumiSurfGroupType.values[index]]!;

      final int receiveLength = max(0,newSelectedGroupData.length);

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
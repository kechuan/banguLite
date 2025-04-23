import 'dart:math';

import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/internal/custom_toaster.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/internal/lifecycle.dart';
import 'package:bangu_lite/models/base_info.dart';
import 'package:bangu_lite/models/providers/base_model.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

abstract class BangumiGeneralMoreContentPageState<
  T extends StatefulWidget,
  M extends BaseModel,
  I extends ContentInfo
> extends LifecycleRouteState<T> with RouteLifecycleMixin {

    M getContentModel();

    Future<void> loadSubjectTopics({int? offset});

    String? title;

    Color? bangumiThemeColor;

    Function(int)? onTap;

    GlobalKey<AnimatedListState> animatedListKey = GlobalKey();
    ScrollController scrollController = ScrollController();

    @override
    Widget build(BuildContext context) {

      final contentModel = getContentModel();

      return Theme(
        data: ThemeData(
          brightness: Theme.of(context).brightness,
          colorSchemeSeed: judgeDetailRenderColor(context,bangumiThemeColor),
          fontFamily: 'MiSansFont',
        ),
        child: Scaffold(
          appBar: AppBar(
            title: ScalableText("$title"),
          ),
          body: EasyRefresh(
            scrollController: scrollController,
            footer: const MaterialFooter(),
            onLoad: (){

              invokeToaster({String? message}) => fadeToaster(context: context, message: message ?? "没有更多内容了");

              final initalLength = getContentModel().contentListData.length;
              loadSubjectTopics(offset: getContentModel().contentListData.length).then((_){

                final int receiveLength = max(0,getContentModel().contentListData.length - initalLength);

                if(receiveLength == 0){
                  invokeToaster();
                  return;

                }

                else{

                  animatedListKey.currentState?.insertAllItems(
                    getContentModel().contentListData.isEmpty ? 0 : initalLength-1, 
                    receiveLength,
                    duration: const Duration(milliseconds: 300),
                  );

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    scrollController.animateTo(
                      scrollController.offset+120,
                      duration: const Duration(milliseconds: 500), 
                      curve: Curves.easeOutCubic
                    );
                  });

                  

                  //height大约为 77 .

                  
                }


              });

            },
            child: ChangeNotifierProvider.value(
              value: contentModel,
              builder: (context, child) {
                return Column(
                  children: [
                    Expanded(
                      child: Selector<M,int>(
                        selector: (_, model) => contentModel.contentListData.length,
                        shouldRebuild: (previous, next) => previous != next,
                        builder: (_,contentListDataLength,child) {
                      
                          final List<ContentInfo> contentList = contentModel.contentListData as List<I>;
                      
                          return AnimatedList(
                            controller:scrollController,
                            key: animatedListKey,
                            shrinkWrap: true,
                            initialItemCount: contentListDataLength,
                            itemBuilder: (_,index,animation){
                              
                              return Card(
                                color: judgeDetailRenderColor(context,bangumiThemeColor),
                                child: ListTile(
                                  onTap: (){
                                    //不能直接写成 onTap: ()=> onTap?.call(index) 否则不知道为何 会被 直接执行!
                                    onTap?.call(index);
                                    
                                  },
                                  //onTap: onTap?.call(index),
                                  title: ScalableText("${contentList[index].contentTitle}",maxLines: 2,overflow: TextOverflow.ellipsis,),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Row(
                                      children: [
                                    
                                        ScalableText("${contentList[index].userInformation?.nickName}"),
                                    
                                        const Spacer(),
                                    
                                        Wrap(
                                          spacing: 6,
                                          crossAxisAlignment: WrapCrossAlignment.center,
                                          children: [
                                            ScalableText(convertDateTimeToString(DateTime.fromMillisecondsSinceEpoch(contentList[index].createdTime!*1000))),
                                            Wrap(
                                              crossAxisAlignment: WrapCrossAlignment.center,
                                              spacing: 3,
                                              children: [
                                                Icon(MdiIcons.chat,size: 12),
                                                ScalableText("${contentList[index].repliesCount}"),
                                              ],
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                          );
                        }
                      ),
                    ),
                  ],
                );
              }
            )
          ),
        ),
      );
    }

}
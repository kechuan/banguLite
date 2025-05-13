import 'package:bangu_lite/delegates/star_sort_strategy.dart';
import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/internal/custom_toaster.dart';
import 'package:bangu_lite/internal/hive.dart';
import 'package:bangu_lite/models/informations/surf/surf_timeline_details.dart';
import 'package:bangu_lite/widgets/fragments/bangumi_timeline_tile.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';

//Map<DateTime, SurfTimelineDetails> testMap = {
//  ...Map.fromIterables(
//    List.generate(30, (index) => DateTime.now().add(Duration(hours: -index*2))),
//    List.generate(30, (index) => SurfTimelineDetails(
//      detailID: (485936+index).toInt()  
//    ) 
//      ..commentDetails = (
//          CommentDetails()..userInformation = (
//            UserInformation(userID: 0)..nickName = 'NPC $index'
//          )
//        )
//      ..bangumiTimelineType = BangumiTimelineType.subject
//    )
   
//  )

//};


@FFRoute(name: '/history')

/// 默认最多只加载前50项
/// 透过下滑以加载更旧的消息 届时恐怕需求重新构建... 
/// 以 2025.1.1 格式 以每日划分进行排序
/// 最短的连续时间点以 10min 进行划分
/// 信息来源为 SurfTimelineDetails 
/// 当用户点击某个项目时 应被封装成 SurfTimelineDetails 记录在内
/// 如果直接点击时间线上的内容 则可以直接搬运至此 挺好

/// [逻辑]
/// 1.如果 [SurfTimelineDetails] 中没有 [sourceTitle] 则直接导向 [subejct]
/// 2.如果 10min 内重复记录了同一项目(以detailID为准) 则不再进行记录
/// 要做到这一点... 恐怕需要写入之前 查询写入范围的key值内 是否存在相同的 detailID
/// 这是一般性的磁盘思维 。。 否则恐怕需要使用 indexModel 进行内存内的记录 但这种恐怕更麻烦
/// 
/// 直接写入 [detailID] 对大家都好...


class BangumiHistoryPage extends StatefulWidget {
  const BangumiHistoryPage({super.key});

  @override
  State<BangumiHistoryPage> createState() => _BangumiHistoryPageState();
}

class _BangumiHistoryPageState extends State<BangumiHistoryPage> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('历史记录'),
        actions: [
          IconButton(
            onPressed: () {
              MyHive.historySurfDataBase.clear();
              setState(() {
                
              });
              //indexModel.surfHistory.clear();
            },
            icon: const Icon(Icons.delete),
          ),

          IconButton(
            onPressed: () {

              //debugPrint("last:${testMap.values.last.detailID}");
              //context.read<IndexModel>().updateStarDetail();
              //setState(() {
              //  testMap = Map.of(testMap);
              //  debugPrint("last:${testMap.values.last.detailID}");
              //});
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: EasyRefresh(
        onRefresh: () => setState(() {}),
        header: const MaterialHeader(),
        child: CustomScrollView(
          slivers: buildSection(context)
        ),
      ),
    );
  }
}



List<Widget> buildSection(
  BuildContext context, 
) {

  final Map<String, int> groupIndices = {};

  List<SurfTimelineDetails> dataSource = 
    MyHive.historySurfDataBase.values.toList();

  dataSource.sort((prev, next) => next.updatedAt!.compareTo(prev.updatedAt!));

  

  for (int starIndex = 0; starIndex < dataSource.length; starIndex++) {

    String headerText = "";

    headerText = SurfTimeSortStrategy().generateHeaderText(
      //sortStrategy.getSort(dataSource[starIndex].updatedAt ?? 0)
      dataSource[starIndex].updatedAt ?? 0
    );

    groupIndices[headerText] ??= starIndex;

  }


  final List<int> groupCounts = calculateGroupCounts(groupIndices, dataSource.length);

  return List.generate(groupIndices.length, (index) {

    String headerText = "";
    int startIndex = 0;
    int itemCount = 0;

    

    headerText = groupIndices.keys.elementAt(index); //当前所属组别
    startIndex = groupIndices.values.elementAt(index); //dataSource的起始下标
    itemCount = groupCounts[index]; //这个组别一共有多少个

    return MultiSliver(
      pushPinnedChildren: true,
      children: [
        buildSectionHeader(context, headerText),
        buildSectionList(
          context,
          data:dataSource,
          startIndex:startIndex,
          itemCount:itemCount,

        ),
      ],
    );
  });

}


// 构建分区标题
Widget buildSectionHeader(BuildContext context, String text) {
  return SliverPinnedHeader(
    child: Container(
      padding: PaddingH12,
      decoration: BoxDecoration(
        border: Border(bottom: Divider.createBorderSide(context)),
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
      ),
      child: SizedBox(
        height: 50,
        child: Align(
          alignment: Alignment.centerLeft,
          child: ScalableText(text, style: const TextStyle(fontSize: 14))
        )
      ),
    ),
  );
}

Widget buildSectionList(
  BuildContext context,
  {
    required List<SurfTimelineDetails> data,
    required int startIndex,
    required int itemCount,
  }
) {

  DateTime recordTime = DateTime(0);

  List<SurfTimelineDetails> rangeData = data.sublist(startIndex, startIndex + itemCount);
  //rangeData.sort((a, b) => b.updatedAt!.compareTo(a.updatedAt!));

  return Padding(
    padding: PaddingH6V12,
    child: ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      shrinkWrap: true,
      itemBuilder: (_, index) {


        return Row(
          spacing: 6,
          
          children: [

            Padding(
              padding: Padding16+PaddingH16,
              child: Builder(
                builder: (_) {
              
                  final currentTime = DateTime.fromMillisecondsSinceEpoch(rangeData[index].updatedAt ?? 0);

                  //15分钟为节点
                  if(currentTime.difference(recordTime).inMinutes.abs() > 15){
                    recordTime = currentTime;
                  }
                  
                  return ScalableText(
                    '${convertDigitNumString(currentTime.hour)}:${convertDigitNumString(currentTime.minute)}',
                    //'${currentTime}',
                    style:  TextStyle(
                      color: recordTime == currentTime ?Colors.grey : Colors.transparent,
                      //color: Colors.grey,
                      fontWeight: FontWeight.bold
                    ),
                  );
                  
                }
              ),
            ),

            Expanded(
              child: Padding(
                padding: PaddingH12,
                child: BangumiTimelineTile(
                  surfTimelineDetails: rangeData[index],
                  isRecordMode: true,
                ),
              ),
            ),

            IconButton(
              onPressed: (){
                //onDelete?.call(currentIndex);
                MyHive.historySurfDataBase.delete(rangeData[index].detailID);
                fadeToaster(context: context, message: '记录已删除');
              }, 
              icon: const Icon(Icons.close)
            )


          ],
        );

      },
    ),
  );
}


// 分组数量计算逻辑
List<int> calculateGroupCounts(Map<String, int> groups, int total) {
  final indices = groups.values.toList()..add(total);
  return List.generate(groups.length, (i) => indices[i+1] - indices[i]);
}
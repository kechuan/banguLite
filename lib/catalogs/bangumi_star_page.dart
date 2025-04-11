
import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/delegates/star_sort_strategy.dart';
import 'package:bangu_lite/internal/bangumi_define/content_status_const.dart';
import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/hive.dart';
import 'package:bangu_lite/models/bangumi_details.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:bangu_lite/models/star_details.dart';
import 'package:bangu_lite/widgets/fragments/bangumi_tile.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/dialogs/general_transition_dialog.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';

class BangumiStarPage extends StatelessWidget {
  const BangumiStarPage({super.key});

  @override
  Widget build(BuildContext context) {

    final ValueNotifier<SortType> sortTypeNotifier = ValueNotifier<SortType>(SortType.joinTime);
    final ValueNotifier<bool> reversedSortNotifer = ValueNotifier<bool>(false);

    final indexModel = context.read<IndexModel>();

    return Scaffold(
      
      appBar: AppBar(
		    surfaceTintColor: Colors.transparent,
        toolbarHeight: 60,
        title: const Padding(
          padding: PaddingH6,
          child: ScalableText("番剧收藏",style: TextStyle(fontSize: 18),),
        ),
        
        actions: [

          ValueListenableBuilder(
            valueListenable: sortTypeNotifier,
             builder: (_,currentSortType,child) {

                List<SortType> valueList = const [
                  SortType.joinTime,
                  SortType.updateTime,
                  SortType.airDate,
                  SortType.score,
                  SortType.rank,
                ];

                List<Icon> iconList =  [
                  Icon(MdiIcons.calendarImport),
                  const Icon(Icons.history),
                  const Icon(Icons.calendar_month),
                  const Icon(Icons.numbers),
                  const Icon(Icons.leaderboard_outlined),
                ];

               return SizedBox(
                width: 60,
                 child: PopupMenuButton<SortType>(
                  tooltip: "排序方式",
                  initialValue: currentSortType,
                  position:PopupMenuPosition.under,
                  itemBuilder: (_) {
                    return List.generate(
                      valueList.length, 
                      (index) => PopupMenuItem(
                        value: valueList[index],
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            iconList[index],
                            Text(valueList[index].label)
                          ],),
                      ),
                    );
                  },
                                    
                  onSelected: (selectedValue)=>sortTypeNotifier.value = selectedValue,
                                    
                  child: SizedBox(
                    height: 50,
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: PaddingH6,
                            child: iconList[valueList.indexOf(currentSortType)],
                          ),
                        ),
                    
                        const Icon(Icons.arrow_drop_down)
                    
                      ],
                    ),
                  ),
                                    
                  ),
               );
             }
           ),

          const Padding(padding: PaddingH6),

          ValueListenableBuilder(
            valueListenable: reversedSortNotifer,
             builder: (_,reversedStatus,__) {
               return IconButton(
                onPressed: ()=> reversedSortNotifer.value = !reversedSortNotifer.value,
                icon: reversedStatus ? const Icon(Icons.history_outlined) : const Icon(Icons.history_outlined,color: Colors.grey,)
              );
             }
           ),

          const Padding(padding: PaddingH6),

          IconButton(
            onPressed: (){

              showTransitionAlertDialog(
                context,
                title: "重置确认",
                content: "要清空所有的订阅信息吗?",
                cancelAction: ()=>debugPrint("stars List: ${MyHive.starBangumisDataBase.keys.length}"),
                confirmAction: (){
                  MyHive.starBangumisDataBase.clear();
                  indexModel.starsUpdateRating.clear();
                  indexModel.updateStar();
                }
              );

            },
            icon: const Icon(Icons.delete_forever_outlined)
          ),

          const Padding(padding: PaddingH6),

        ],
        leading: const SizedBox.shrink(),
        leadingWidth: 0,
      ),
      body: Selector<IndexModel,int>(
        selector: (_, indexModel) => indexModel.starUpdateFlag,
        shouldRebuild: (previous, next) => previous!=next,
        builder: (_,__,___){
          return EasyRefresh(
            child: ValueListenableBuilder(
              valueListenable: reversedSortNotifer,
              builder: (_,reversedStatus,child) {
                return ValueListenableBuilder(
                  valueListenable: sortTypeNotifier,
                  builder: (_, sortType, __) {
                
                    SortStrategy currentStrategy = AirDateSortStrategy();
                    
                    switch(sortType){
                      case SortType.airDate: {currentStrategy = AirDateSortStrategy(); break;}
                			case SortType.joinTime: {currentStrategy = JoinTimeSortStrategy(); break;}
                      case SortType.updateTime: {currentStrategy = UpdateTimeSortStrategy(); break;}
                      case SortType.rank: {currentStrategy = RankSortStrategy(); break;}
                      case SortType.score: {currentStrategy = ScoreSortStrategy(); break;}
                      
                      default: {}
                
                    }
                
                    return CustomScrollView(
                      slivers: seasonTypeSort(
                        context:context,
                        sortStrategy: currentStrategy,
                        sortType: sortType,
                        isReversed: reversedStatus
                      )
                    );
                  },
                  
                );
              }
            ),
          );
      
        },
        
        
        ),

    );
  }
}


// 重构后的主函数
List<Widget> seasonTypeSort({
  required BuildContext context,
  required SortStrategy sortStrategy,
  required SortType sortType,
  bool? isReversed
}) {
  	final indexModel = context.read<IndexModel>();
  	List<StarBangumiDetails> dataSource = MyHive.starBangumisDataBase.values.toList();

	if(
		sortType == SortType.rank || 
		sortType == SortType.score
	){
		dataSource = List.generate(
			dataSource.length,
			(index){
				//indexModel.starsUpdateRating[startIndex + index]["rank"]!.toInt()

				return dataSource[index]
					..rank = indexModel.starsUpdateRating[index]["rank"]!.toInt()
					..score = indexModel.starsUpdateRating[index]["score"]!.toDouble()
				;
			}
		);
	}

  // 使用策略进行排序
  dataSource.sort((prev, next) => 
    sortStrategy.getSort(prev)
      .compareTo(sortStrategy.getSort(next))
  );

  // 根据排序内容 生成的分组信息(headerText) 其记录着排序过后的 每个分组的起始下标
  final Map<String, int> groupIndices = {};


  for (int starIndex = 0; starIndex < dataSource.length; starIndex++) {

    String headerText = "";

    headerText = sortStrategy.generateHeaderText(
      sortStrategy.getSort(dataSource[starIndex])
    );

    groupIndices[headerText] ??= starIndex;

  }

  // 计算各分组数量
  final List<int> groupCounts = calculateGroupCounts(groupIndices, dataSource.length);

  // 构建Sliver列表
  return List.generate(groupIndices.length, (index) {

    String headerText = "";
    int startIndex = 0;
    int itemCount = 0;

    if(isReversed == true){
      headerText = groupIndices.keys.elementAt(((groupIndices.length-1) - index)); //当前所属组别
      startIndex = groupIndices.values.elementAt(((groupIndices.length-1) - index)); //dataSource的起始下标
      itemCount = groupCounts[((groupIndices.length-1) - index)]; //这个组别一共有多少个
    }

    else{
      headerText = groupIndices.keys.elementAt(index); //当前所属组别
      startIndex = groupIndices.values.elementAt(index); //dataSource的起始下标
      itemCount = groupCounts[index]; //这个组别一共有多少个
    }

    return MultiSliver(
      pushPinnedChildren: true,
      children: [
        buildSectionHeader(context, headerText),
        buildSectionList(
          context,
          data:dataSource,
          startIndex:startIndex,
          itemCount:itemCount,
          indexModel:indexModel,
          sortType:sortStrategy.currentSort,
          isReversed: isReversed
        ),
      ],
    );
  });
}

// 分组数量计算逻辑
List<int> calculateGroupCounts(Map<String, int> groups, int total) {
  final indices = groups.values.toList()..add(total);
  return List.generate(groups.length, (i) => indices[i+1] - indices[i]);
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
          child: ScalableText(text, style: const TextStyle(fontSize: 18))
        )
      ),
    ),
  );
}

// 构建分区列表
Widget buildSectionList(
  BuildContext context,
  {
    required List<StarBangumiDetails> data,
    required int startIndex,
    required int itemCount,
    required IndexModel indexModel,
    required SortType sortType,
    bool? isReversed
  }
) {

  return Padding(
    padding: PaddingH6V12,
    child: ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      shrinkWrap: true,
      itemBuilder: (_, index) {

        StarBangumiDetails starBangumiDetail = StarBangumiDetails();

        if(isReversed == true){
          starBangumiDetail = data[startIndex + (itemCount-1) - index];
        }

        else{
          starBangumiDetail = data[startIndex + index];
        }

        
        return BangumiListTile(
          imageSize: const Size(100, 150),
          bangumiDetails: loadStarDetailsData(starBangumiDetail),

          trailing: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 12,
            children: [
                  
              Builder(
                builder: (_) {
          
                  String resultText = getUpdateText(
                    starsUpdateRating:indexModel.starsUpdateRating,
                    item:starBangumiDetail,
                    sortType:sortType,
                    resultIndex:startIndex + index
                  );
          
                  if(resultText.isEmpty){
                    return const SizedBox();
                  }
                    
        
                  return ScalableText(
                    resultText,
                    style: TextStyle(fontSize: resultText.length > 6 ? 12 : null),
                    maxLines: 2,
                  );
                }
              ),
          
          
              IconButton(
                icon: const Icon(Icons.star),
                onPressed: () {
                  MyHive.starBangumisDataBase.delete(starBangumiDetail.bangumiID);
                  indexModel.updateStar();
                },
              ),
          
          
            ],
          ),
          onTap: () => Navigator.pushNamed(
            context,
            Routes.subjectDetail,
            arguments: {"subjectID": starBangumiDetail.bangumiID},
          ),
        );
      },
    ),
  );
}


String getUpdateText(
  {
    required List<Map<String, num>> starsUpdateRating,
    required StarBangumiDetails item,
    required SortType sortType,
    required int resultIndex,
  }
){
  String resultContent = "";

  switch(sortType){
                    
    case SortType.rank:{

      debugPrint("resultIndex:$resultIndex item: ${item.name}/${item.rank}/${item.score} => ${starsUpdateRating[resultIndex]} ");

      int starRank = MyHive.starBangumisDataBase.values.elementAt(resultIndex).rank!;

      if(starsUpdateRating[resultIndex]["rank"] == item.rank){
        resultContent="${item.rank}";
      }

      else{
        resultContent="收藏时: $starRank\n现在时: ${item.rank}"; 
      }

      break;
    }

    case SortType.score:{

      double starScore = MyHive.starBangumisDataBase.values.elementAt(resultIndex).score!;
      
      if(starsUpdateRating[resultIndex]["score"] == item.score){
        resultContent="${item.score}";
      }

      else{
        resultContent="收藏时: $starScore\n现在时: ${item.score}"; 
      }


      break;
    }

    case SortType.joinTime:{resultContent="${item.joinDate}"; break;}
    case SortType.airDate:{resultContent="${item.airDate}"; break;}
    
    default:{}
  }

  return resultContent;
}
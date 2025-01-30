
import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/delegates/star_sort_strategy.dart';
import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/internal/custom_toaster.dart';
import 'package:bangu_lite/internal/hive.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:bangu_lite/models/star_details.dart';
import 'package:bangu_lite/widgets/fragments/bangumi_tile.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/general_transition_dialog.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';

class BangumiStarPage extends StatelessWidget {
  const BangumiStarPage({super.key});

  @override
  Widget build(BuildContext context) {

    ValueNotifier<SortType> sortTypeNotifier = ValueNotifier<SortType>(SortType.joinTime);

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
					sortType: sortType
                  )
                );
              },
              
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
  required SortType sortType
}) {
  	final indexModel = context.read<IndexModel>();
  	List<StarBangumiDetails> dataSource = MyHive.starBangumisDataBase.values.toList();

	//debugPrint("${indexModel.starsUpdateRating[0]["rank"]}/${indexModel.starsUpdateRating[0]["score"]}");
	//debugPrint("${indexModel.starsUpdateRating[1]["rank"]}/${indexModel.starsUpdateRating[1]["score"]}");

	//debugPrint("timestamp: ${DateTime.now()} seasonTypeSort rebuild");

	if(
		sortType == SortType.rank || 
		sortType == SortType.score
	){
		dataSource = List.generate(
			indexModel.starsUpdateRating.length,
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
  dataSource.sort((prev, next) => sortStrategy.getSort(prev)
      .compareTo(sortStrategy.getSort(next)));

  // 根据排序内容 生成的分组信息(headerText) 其记录着排序过后的 每个分组的起始下标
  final Map<String, int> groupIndices = {};

  for (int starIndex = 0; starIndex < dataSource.length; starIndex++) {
    final headerText = sortStrategy.generateHeaderText(
      sortStrategy.getSort(dataSource[starIndex])
    );
	groupIndices[headerText] ??= starIndex;
  }

  // 计算各分组数量
  final List<int> groupCounts = calculateGroupCounts(groupIndices, dataSource.length);

  // 构建Sliver列表
  return List.generate(groupIndices.length, (index) {
    final headerText = groupIndices.keys.elementAt(index); //当前所属组别
    final startIndex = groupIndices.values.elementAt(index); //dataSource的起始下标
    final itemCount = groupCounts[index]; //这个组别一共有多少个

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
			sortType:sortStrategy.currentSort
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
	required SortType sortType
  }
) {
  return Padding(
    padding: PaddingH6V12,
    child: ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      shrinkWrap: true,
      itemBuilder: (_, index) {
        final item = data[startIndex + index];
        return BangumiListTile(
          imageSize: const Size(100, 150),
          bangumiTitle: item.name,
          imageUrl: item.coverUrl,
          trailing: SizedBox(
			width: 250,
			child: Row(
			  mainAxisAlignment: MainAxisAlignment.end,
			  spacing: 12,
			  children: [
							
				Builder(
					builder: (_){

						String resultContent = "";
						switch(sortType){
							
							case SortType.rank:{

								int starRank = MyHive.starBangumisDataBase.values.elementAt(startIndex + index).rank!;

								if(indexModel.starsUpdateRating[startIndex + index]["rank"] == item.rank){
									resultContent="${item.rank}";
								}

								else{
									resultContent="收藏时: $starRank -> ${item.rank}"; 
								}

								break;
							}

							case SortType.score:{

								double starScore = MyHive.starBangumisDataBase.values.elementAt(startIndex + index).score!;
								
								if(indexModel.starsUpdateRating[startIndex + index]["score"] == item.score){
									resultContent="${item.score}";
								}

								else{
									resultContent="收藏时: $starScore -> ${item.score}"; 
								}


								break;
							}

							case SortType.joinTime:{resultContent="${item.joinDate}"; break;}
							case SortType.airDate:{resultContent="${item.airDate}"; break;}
							
							default:{}
						}

						

						return ScalableText(resultContent);
					}
				),

				//Builder(
				//  builder: (_) {

				//	if(
				//		sortType == SortType.updateTime && 
				//		DateTime.now().compareTo(convertDateTime(item.finishedDate)) < 0 //连载中才显示
				//	){
				//		final ValueNotifier<bool> subscribeNotifier = ValueNotifier<bool>(false);

				//		return ValueListenableBuilder(
				//		  valueListenable: subscribeNotifier,
				//		  builder: (_,subscribeStatus,child) {
				//		    return IconButton(
				//		    	icon: subscribeStatus ? const Icon(Icons.notifications) : const Icon(Icons.notifications_outlined),
				//		    	onPressed: () async {

				//					invokeAsyncCreateToaser()=> fadeToaster(context: context, message: "已将该番剧设置为更新通知提醒");
				//					invokeAsyncCancelToaser()=> fadeToaster(context: context, message: "已取消通知提醒");

				//					subscribeNotifier.value ? invokeAsyncCancelToaser() : invokeAsyncCreateToaser();

				//					subscribeNotifier.value = !subscribeNotifier.value;

									
				//		    	},
				//		    );
				//		  }
				//		);
				//	}

				//	return const SizedBox.shrink();

				//  }
				//),

				IconButton(
					icon: const Icon(Icons.star),
					onPressed: () {
						MyHive.starBangumisDataBase.delete(item.bangumiID);
						indexModel.updateStar();
					},
				),

			
			  ],
			),
		  ),
          onTap: () => Navigator.pushNamed(
            context,
            Routes.subjectDetail,
            arguments: {"subjectID": item.bangumiID},
          ),
        );
      },
    ),
  );
}
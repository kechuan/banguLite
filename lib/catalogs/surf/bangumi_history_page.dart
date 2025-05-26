 

import 'package:bangu_lite/delegates/star_sort_strategy.dart';
import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/internal/utils/convert.dart';
import 'package:bangu_lite/internal/custom_toaster.dart';
import 'package:bangu_lite/internal/hive.dart';
import 'package:bangu_lite/models/informations/surf/surf_timeline_details.dart';
import 'package:bangu_lite/widgets/dialogs/general_transition_dialog.dart';
import 'package:bangu_lite/widgets/fragments/bangumi_timeline_tile.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';


///依赖省略

@FFRoute(name: '/history')

class BangumiHistoryPage extends StatefulWidget {
  const BangumiHistoryPage({super.key});	

  @override
  State<BangumiHistoryPage> createState() => BangumiHistoryPageState();
}

class BangumiHistoryPageState extends State<BangumiHistoryPage>
    with TickerProviderStateMixin {

	late AnimationController bottomBarController;

	final ValueNotifier<int> multiSelectCountNotifier = ValueNotifier(0);
	final ValueNotifier<bool> multiSelectModeNotifier = ValueNotifier(false);

  	final Set<int> selectedItems = <int>{};
  
	// 删除动画控制器
	final Map<int, AnimationController> deleteControllers = {};
	final Map<int, Animation<double>> deleteAnimations = {};
	
	// 正在删除的项目
	final Set<int> deletingItems = <int>{};

  @override
  void initState() {
    bottomBarController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    super.initState();
  }

  @override
  void dispose() {
    // 清理所有动画控制器
    for (final controller in deleteControllers.values) {
      controller.dispose();
    }


	bottomBarController.dispose();
    super.dispose();
  }

  // 创建删除动画控制器
  void createDeleteAnimation(int itemID) {
    if (deleteControllers.containsKey(itemID)) return;
    
    final controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    final animation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    ));
    
    deleteControllers[itemID] = controller;
    deleteAnimations[itemID] = animation;
  }

  // 删除单个项目
  Future<void> deleteSingleItem(int itemID) async {
    if (deletingItems.contains(itemID)) return;
    
    setState(() {
      deletingItems.add(itemID);
    });
    
    createDeleteAnimation(itemID);
    
    // 开始动画
    await deleteControllers[itemID]!.forward();
    
    // 执行删除
    MyHive.historySurfDataBase.delete(itemID);
    
    // 清理
    deleteControllers[itemID]!.dispose();
    deleteControllers.remove(itemID);
    deleteAnimations.remove(itemID);
    
    setState(() {
      deletingItems.remove(itemID);
    });
    
    if (mounted) {
      fadeToaster(context: context, message: '记录已删除');
    }
  }

  // 批量删除选中项目
  Future<void> deleteSelectedItems() async {
    if (selectedItems.isEmpty) return;

    final itemsToDelete = List<int>.from(selectedItems);
    
    // 开始删除动画
	setState(() {
		for (final itemID in itemsToDelete) {
			deletingItems.add(itemID);
			createDeleteAnimation(itemID);
		}
	});

    // 并行执行所有动画
    await Future.wait(
      itemsToDelete.map((itemID) => deleteControllers[itemID]!.forward())
    ).then((_){
		for (final itemID in itemsToDelete) {
		  MyHive.historySurfDataBase.delete(itemID);
		}

		// 清理资源
		for (final itemID in itemsToDelete) {
			deleteControllers[itemID]?.dispose();
		}

		deleteControllers.clear();
		deleteAnimations.clear();
		deletingItems.clear();
		selectedItems.clear();

		setState(() {
			toggleMultiSelectMode();
			multiSelectCountNotifier.value = 0;
		});

		if (mounted) {
			fadeToaster(
				context: context, 
				message: '已删除 ${itemsToDelete.length} 条记录'
			);
		}
	});


  }

  // 切换多选模式
  void toggleMultiSelectMode() async {
	
	multiSelectModeNotifier.value = !multiSelectModeNotifier.value;

	multiSelectModeNotifier.value ? 
	await bottomBarController.forward() : 
	await bottomBarController.reverse();

	selectedItems.clear();

  }

  // 切换项目选中状态
  void toggleItemSelection(int itemID) {
	if (selectedItems.contains(itemID)) {
		selectedItems.remove(itemID);
	} 
	
	else {
		selectedItems.add(itemID);
	}

	multiSelectCountNotifier.value = selectedItems.length;
  }

  // 全选/取消全选
  void toggleSelectAll() {
    final dataSource = MyHive.historySurfDataBase.values.toList();

	if (multiSelectCountNotifier.value == dataSource.length) {
		selectedItems.clear();
	}

	else{
		selectedItems.clear();
        selectedItems.addAll(dataSource.map((item) => item.detailID!));
	}

	multiSelectCountNotifier.value = selectedItems.length;

  }

  @override
  Widget build(BuildContext context) {

	debugPrint("bangumi_history_page build");

    return Scaffold(
      appBar: AppBar(
		title: const ScalableText('历史记录'),
        leading: ValueListenableBuilder(
			valueListenable: multiSelectModeNotifier,
			builder: (_,multiSelectModeNotifier,child) {
				return IconButton(
					onPressed: (){
						multiSelectModeNotifier ? toggleMultiSelectMode() : Navigator.of(context).pop();
					},
					icon: multiSelectModeNotifier ? const Icon(Icons.close) : const Icon(Icons.arrow_back),
				);
			}
        ),
        actions: buildAppBarActions(),
      ),
      body: EasyRefresh(
        onRefresh: () => setState(() {}),
        header: const MaterialHeader(),
        child: SafeArea(
          child: CustomScrollView(
            slivers: buildSection(context)
          ),
        ),
      ),
      bottomNavigationBar: buildBottomActionBar()

    );
  }


  ///很抽象的写法 
  ///但这也让我明白有些写法的意义究竟会在哪里
  List<Widget> buildAppBarActions() {

	return [
		ValueListenableBuilder(
			valueListenable: multiSelectModeNotifier,
			builder: (_,multiSelectMode,child){
				return Row(
					spacing: 6,
					children: [
						if (multiSelectMode) 
							IconButton(
								onPressed: ()=> toggleSelectAll(),
								icon: Icon(
									selectedItems.length == MyHive.historySurfDataBase.length
									? Icons.deselect
									: Icons.select_all
								),
							),
				
						if(!multiSelectMode) 
							
							...[
								IconButton(
								onPressed: ()=> toggleMultiSelectMode(),
								icon: const Icon(Icons.checklist),
								tooltip: '多选模式',
								),
								IconButton(
								onPressed: (){
									showTransitionAlertDialog(
										context,
										title: "清空全部历史记录",
										content: "确定要清空全部历史记录吗？",
										confirmAction: (){
											//MyHive.historySurfDataBase.clear();
											toggleMultiSelectMode();
				
											//fadeToaster(context: context, message: '历史记录已清空');
										}
				
									);
				
								},
								icon: const Icon(Icons.delete_sweep),
								tooltip: '清空全部',
								),
							]
							
				
					],
				);
			},
		)
	];


    
  }

  // 构建底部操作栏
  Widget buildBottomActionBar() {
	
    return AnimatedBuilder(
		animation: bottomBarController,
      	builder: (_,child) {

			if(bottomBarController.value < 0.1) return const SizedBox.shrink();
			if(bottomBarController.value > 0.9) return child!;

			return Offstage(
				offstage: bottomBarController.value == 0,
				child: Opacity(
					opacity: bottomBarController.value,
					child: Transform.translate(
					offset: Offset(0, 60 - bottomBarController.value*60),
					child: child!,
					),
				),
			);
		},
		
		child: Container(
			padding: PaddingH16V12,
			decoration: BoxDecoration(
				color: Theme.of(context).colorScheme.surface,
				border: Border(
				top: BorderSide(
				color: Theme.of(context).dividerColor,
				width: 0.5,
				),
			),
			),
			child: SafeArea(
				child: Row(
				children: [
					
					Expanded(
						child: ValueListenableBuilder(
							valueListenable: multiSelectCountNotifier,
							builder: (_,multiSelectCount,__) {
								return ScalableText(
									'已选择 $multiSelectCount 项',
								);
							}
						),
					),
					
					ElevatedButton.icon(
					onPressed: (){

						if (selectedItems.isEmpty) return;

						showTransitionAlertDialog(
							context,
							title: '历史记录删除',
							content: '确定要删除选中的 ${selectedItems.length} 条记录吗？',
							confirmAction: () {
								deleteSelectedItems();
							},
						);
						
						
					},
					icon: const Icon(Icons.delete),
					label: const ScalableText('删除'),
					style: ElevatedButton.styleFrom(
					foregroundColor: Theme.of(context).colorScheme.error,
					),
				),
				],
			),
			),
		)
	
      
    );
  }

  // 构建分区列表
  List<Widget> buildSection(BuildContext context) {
    final Map<String, int> groupIndices = {};

    List<SurfTimelineDetails> dataSource = 
      MyHive.historySurfDataBase.values.toList();

    dataSource.sort((prev, next) => next.updatedAt!.compareTo(prev.updatedAt!));

    for (int starIndex = 0; starIndex < dataSource.length; starIndex++) {
      String headerText = "";

      headerText = SurfTimeSortStrategy().generateHeaderText(
        dataSource[starIndex].updatedAt ?? 0
      );

      groupIndices[headerText] ??= starIndex;
    }

    final List<int> groupCounts = calculateGroupCounts(groupIndices, dataSource.length);

    return List.generate(groupIndices.length, (index) {
      String headerText = "";
      int startIndex = 0;
      int itemCount = 0;

      headerText = groupIndices.keys.elementAt(index);
      startIndex = groupIndices.values.elementAt(index);
      itemCount = groupCounts[index];

      return MultiSliver(
        pushPinnedChildren: true,
        children: [
          buildSectionHeader(context, headerText),
          buildSectionList(
            context,
            data: dataSource,
            startIndex: startIndex,
            itemCount: itemCount,
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

  // 构建分区列表
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

    return Padding(
      padding: PaddingH6V12,
      child: ListView.builder(
        padding: const EdgeInsets.all(0),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        shrinkWrap: true,
        itemBuilder: (_, index) {
          final item = rangeData[index];
          final itemID = item.detailID!;
          final isDeleting = deletingItems.contains(itemID);
        //  final isSelected = selectedItems.contains(itemID);

          // 如果有删除动画，使用动画包装
          Widget itemWidget = buildHistoryItem(
            item,
            recordTime,
          );

          if (isDeleting && deleteAnimations.containsKey(itemID)) {
            itemWidget = AnimatedBuilder(
              animation: deleteAnimations[itemID]!,
              builder: (context, child) {
                return SizeTransition(
					sizeFactor: deleteAnimations[itemID]!,
					child: FadeTransition(
						opacity: deleteAnimations[itemID]!,
						child: child,
					),
                );
              },
              child: itemWidget,
            );
          }

          return itemWidget;
        },
      ),
    );
  }

  // 构建单个历史记录项
  Widget buildHistoryItem(
    SurfTimelineDetails item,
    DateTime recordTime,
  ) {

    final currentTime = DateTime.fromMillisecondsSinceEpoch(item.updatedAt ?? 0);
    
    // 15分钟为节点
    if (currentTime.difference(recordTime).inMinutes.abs() > 15) {
      recordTime = currentTime;
    }

    return GestureDetector(

    	onLongPress: () {
    		if (!multiSelectModeNotifier.value) toggleMultiSelectMode();
    	},
    	onTap: (){
    		if(multiSelectModeNotifier.value) toggleItemSelection(item.detailID!);
    	},
		
    	child: Stack(
    		children: [
    
    			Positioned.fill(
    				child: ValueListenableBuilder(
    				valueListenable: multiSelectCountNotifier,
    				builder: (_,__,___) {
    					return Container(
    						decoration: BoxDecoration(
    							color: selectedItems.contains(item.detailID) ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1): null,
    							borderRadius: BorderRadius.circular(8),
    						),
    					);
    				}
    				),
    			),
    
    		    Row(
    				spacing: 6,
    				children: [
    		    	// 多选模式下显示复选框
    		    	
					AnimatedBuilder(
						animation: bottomBarController,
						builder: (_,child) {

							if(bottomBarController.value < 0.1) return const SizedBox.shrink();
							if(bottomBarController.value > 0.9) return child!;

							return Offstage(
								offstage: bottomBarController.value == 0,
								child: SizedBox(
								width: bottomBarController.value*60,
								child: Opacity(
									opacity: bottomBarController.value,
									child: Transform.translate(
									offset: Offset(bottomBarController.value*60 - 60, 0),
									child: child!,
									),
								),
								),
							);


						},
						child: ValueListenableBuilder(
								valueListenable: multiSelectCountNotifier,
								builder: (_,__,___) {
									return Checkbox(
									value: selectedItems.contains(item.detailID),
									onChanged: (value) => toggleItemSelection(item.detailID!),
								);
							}),
					),
    		    				
    		    	// 时间显示
    		    	Padding(
    		    		padding: Padding16 + PaddingH16,
    		    		child: ScalableText(
    		    			'${convertDigitNumString(currentTime.hour)}:${convertDigitNumString(currentTime.minute)}',
    		    			style: TextStyle(
    		    			color: recordTime == currentTime ? Colors.grey : Colors.transparent,
    		    			fontWeight: FontWeight.bold
    		    			),
    		    		),
    		    	),
    		    				
    		    	// 主要内容
    		    	Expanded(
    		    		child: Padding(
    		    			padding: PaddingH12,
    		    			child: BangumiTimelineTile(
    							onTap: () {
    								if(multiSelectModeNotifier.value){ 
    									toggleItemSelection(item.detailID!);
    									return false;
    								}
    
    								return true;
    							  
    							},
    							surfTimelineDetails: item,
    							isRecordMode: true,
    		    			),
    		    		),
    		    	),
    		    				
    		    	// 删除按钮（非多选模式下显示）
    		    	
    		    	ValueListenableBuilder(
						valueListenable: multiSelectModeNotifier,
						builder: (_,multiSelectModeNotifier,child) {
							if(multiSelectModeNotifier) return child!;
							return const SizedBox.shrink();
    		    	  },
					  child: IconButton(
							onPressed: () => deleteSingleItem(item.detailID!),
							icon: const Icon(Icons.close),
						),
    		    	),
    		    ],
    		    ),
    
    		],
    	),
    );
  }
}

// 分组数量计算逻辑
List<int> calculateGroupCounts(Map<String, int> groups, int total) {
  final indices = groups.values.toList()..add(total);
  return List.generate(groups.length, (i) => indices[i+1] - indices[i]);
}

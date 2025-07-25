import 'dart:async';
import 'dart:math';

import 'package:bangu_lite/catalogs/about_page.dart';
import 'package:bangu_lite/internal/bus_register_method.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/internal/event_bus.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/internal/lifecycle.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/widgets/components/bangumi_tab_content_select.dart';
import 'package:bangu_lite/widgets/dialogs/new_update_dialog.dart';
import 'package:bangu_lite/widgets/fragments/request_snack_bar.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/fragments/unvisible_response.dart';
import 'package:bangu_lite/widgets/views/bangutile_grid_view.dart';
import 'package:bangu_lite/widgets/dialogs/warp_season_dialog.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';

import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/models/informations/subjects/bangumi_details.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:bangu_lite/widgets/fragments/cached_image_loader.dart';
import 'package:infinite_carousel/infinite_carousel.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';

class BangumiCalendarPage extends StatefulWidget {
  const BangumiCalendarPage({super.key});

  @override
  State<BangumiCalendarPage> createState() => _BangumiCalendarPageState();
}

class _BangumiCalendarPageState extends LifecycleState<BangumiCalendarPage> {

  Future? calendarLoadFuture;
  Timer? carouselTimer;

  final InfiniteScrollController infiniteScrollController = InfiniteScrollController();
  
  final ValueNotifier<bool> transitionalSeasonNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> weekdaySelectOffstageNotifier = ValueNotifier<bool>(true);
  final ValueNotifier<bool> weekdaySelectOffstageAnimatedNotifier = ValueNotifier<bool>(false);

  Timer generateScrollList(){
    return Timer.periodic(const Duration(milliseconds: 3600), (timer) {
      
      if(!infiniteScrollController.hasClients) {
        carouselTimer?.cancel();
        return;
      }

      infiniteScrollController.nextItem(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );


    });
  }

  void carouselSpinTimer(){
    if(carouselTimer!=null){ carouselTimer?.cancel(); }
    carouselTimer = generateScrollList();
  }

  @override
  void initState(){

    invokeShowUpdateDialog(latestRelease) => showUpdateDialog(context,latestRelease);

    getContext() => context;

    carouselSpinTimer();
    calendarLoadFuture = context.read<IndexModel>().loadCalendar();

    //real init For provider context
    context.read<AccountModel>().initModel(context);

    //由 轮换页进行 监听 AppRoute 
    bus.on('AppRoute', (link) {
      if (!mounted) return;
      appRouteMethodListener(context, link);
    });

    bus.on('LoginRoute', (link) {
      appLoginMethodListener(context, link);
    });

    pullLatestRelease().then((latestRelease){
      cleanInstalledPackageCache(latestRelease?.tagName);
      if(latestRelease == null) return;

      if(APPInformationRepository.version == latestRelease.tagName){
        return;
      }

      Future.delayed(
        const Duration(seconds: 3), 
        ()=> showRequestSnackBar(
          message: "检测到新版本",
          trailingWidget: TextButton(
            onPressed: ()=> invokeShowUpdateDialog(latestRelease),
            child: const Text('去更新',style: TextStyle(color: Colors.black))
            
          ),
          
          backgroundColor: judgeCurrentThemeColor(getContext())
        )
      );
    });
    
    super.initState();
  }

  @override
  void onPause() {
    debugPrint("caleandar pause");
    if(carouselTimer!=null){
      carouselTimer?.cancel();
    }
    FocusScope.of(context).unfocus();
    super.onPause();
  }

  @override
  void onResume() {
	debugPrint("caleandar resume");
	carouselSpinTimer();
	super.onResume();

  }


  @override
  Widget build(BuildContext context) {
    final indexModel = context.read<IndexModel>();

    return EasyRefresh.builder(
      header: const MaterialHeader(),
      onRefresh: (){

       if(
          indexModel.selectedYear == DateTime.now().year &&
          indexModel.selectedSeason.seasonText == judgeSeasonRange(DateTime.now().month).seasonText
        ){
          calendarLoadFuture = indexModel.reloadCalendar();
        }

      },
      
      childBuilder: (_,physic){

        if(calendarLoadFuture==null){
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
  
        return Scaffold(
          body: Selector<IndexModel, DateTime>(
            selector: (_, indexModel) => indexModel.dataTime,
            shouldRebuild: (previous, next) => previous!=next,
            builder: (_, updateTime, child) {
              return FutureBuilder(
                future: calendarLoadFuture,
                builder: (_, snapshot) {
            
                  //debugPrint("index rebuild: screenWidth:${MediaQuery.sizeOf(context).width}");
                  final calendarBangumis = indexModel.calendarBangumis;
            
                  return CustomScrollView(
                    physics: ClampingScrollPhysics(),
                    slivers: [
          
                      MultiSliver(
                        pushPinnedChildren: true,
                        children: [
                            
                          SliverPinnedHeader(
                            child: Container(
                              padding: const EdgeInsets.only(left: 24),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: Divider.createBorderSide(context) //
                                ),
          
                                color: Theme.of(context).colorScheme.surface.withValues(alpha:0.6),
                                
                              ),
                              
                              height: 60,
                              child: Row(
                                spacing: 12,
                                children: [

                                  const ScalableText("本季热番",style: TextStyle(fontSize: 24)),
                                  //const Spacer(),
                                  InkResponse(
                                    containedInkWell: true,
									                  onTap: ()=> showSeasonDialog(context,calendarLoadFuture),
                                    focusColor: Colors.transparent,
                                    child: Row(
                                      children: [
                                        //重建代价低
                                        Consumer<IndexModel>(
                                          builder: (_,indexModel,child) {
                                            return ScalableText("${indexModel.selectedYear} ${indexModel.selectedSeason.seasonText}",style:const TextStyle(fontSize: 24));
                                          }
                                        ),
                                        const Icon(Icons.arrow_drop_down)
                                      ],
                                    ),
                                  )
                                  
                                          
                                ],
                              )
                            )
                          ),

                          SliverPadding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            sliver: SliverFixedExtentList( 
                              itemExtent:MediaQuery.sizeOf(context).height/4, //原本滚动组件主轴约束无限 锁定InfiniteCarousel的交叉轴高度
                              delegate: SliverChildListDelegate(
                                [

                                  Stack(
                                    children: [

                                      Positioned.fill(
                                        child: InfiniteCarousel.builder(
                                          center: false,
                                          loop: true,
                                          itemCount: calendarBangumis["最热门"]!.isEmpty ? 1 : calendarBangumis["最热门"]!.length,
                                          itemExtent: calendarBangumis["最热门"]!.isEmpty ? MediaQuery.sizeOf(context).width : max(200,MediaQuery.sizeOf(context).width/4), //主轴约束
                                          velocityFactor: 0.8 , //滚动速度
                                          controller: infiniteScrollController,
                                          itemBuilder: (_, currentIndex, itemCount){
                                            
                                            List<BangumiDetails>? weeklyBangumisRecommend = calendarBangumis["最热门"];

                                            if(weeklyBangumisRecommend!.isEmpty){
                                               return const Center(
                                                child: ScalableText("暂无热门番剧"),
                                              );
                                            }
                                                              
                                            return Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 12),
                                                child: UnVisibleResponse( 

                                                  containedInkWell: true,
                                                  
                                                  onTap: (){
                                                                    
                                                    debugPrint("$currentIndex => ${weeklyBangumisRecommend[currentIndex].name} ");
                                                      
                                                    Navigator.pushNamed(
                                                      context,
                                                      Routes.subjectDetail,
                                                      arguments: {"subjectID":weeklyBangumisRecommend[currentIndex].id},
                                                    );
                                                            
                                                  },
                                                  child: DecoratedBox(
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(24),
                                                      border: Border.all(width: 1)
                                                    ),
                                                    child: Stack(
                                                                    
                                                      children: [
                                                        
                                                        Positioned.fill(
                                                          child: CachedImageLoader(imageUrl: weeklyBangumisRecommend[currentIndex].coverUrl!)
                                                        ),
                                                        
                                                        Positioned.fill(
                                                          
                                                            child: LayoutBuilder(
                                                              builder: (_,constriant) {
                                                                return DecoratedBox(
                                                                  decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.circular(16),
                                                                    gradient: const LinearGradient(
                                                                      begin:Alignment.bottomCenter,
                                                                      end:Alignment(0, 0.2),
                                                                      
                                                                      colors:[Color.fromARGB(255, 35, 35, 35),Colors.transparent]
                                                                    ),
                                                                  ),
                                                                  child: Row(
                                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: [
                                                                                                                          
                                                                      SizedBox(
                                                                        width: constriant.maxWidth,
                                                                        child: ListTile(
                                                                          title: ScalableText(
                                                                            weeklyBangumisRecommend[currentIndex].name ?? "loading",
                                                                            maxLines: 2,
                                                                            style: const TextStyle(color: Colors.white),
                                                                            overflow: TextOverflow.ellipsis,
                                                                          ),
                                                                          trailing: Container(
                                                                            decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(12),
                                                                              color: AppThemeColor.macha.color
                                                                            ),
                                                                            child: Padding(
                                                                              padding: const EdgeInsets.symmetric(horizontal: 4,vertical: 2),
                                                                              child: ScalableText(
                                                                                "${weeklyBangumisRecommend[currentIndex].ratingList["score"]?.toDouble() ?? "-.-"}",
                                                                                style: const TextStyle(fontSize: 14,color: Colors.black)
                                                                              ),
                                                                            )
                                                                          ),
                                                                        ),
                                                                      )
                                                                                                                          
                                                                    ],
                                                                  ),
                                                                );
                                                              }
                                                            ),
                                                          
                                                        ),
                                                        
                                                      ]
                                                      
                                                    ),
                                                  )
                                                ),
                                              );
                                          }
                                        ),
                                      ),
                                      
                                      ValueListenableBuilder(
                                        valueListenable: transitionalSeasonNotifier,
                                        builder: (_,noticeStatus,child) {
                                          return Offstage(
                                            offstage: !judgeTransitionalSeason() || noticeStatus,
                                              child: Transform.translate( 
                                                //妥协产物 毕竟再写一次SliverStack是需要重编排非常多的事情
                                                offset: const Offset(0, -12),
                                                child: Container(
                                                  height: 50,
                                                  color: judgeCurrentThemeColor(context).withValues(alpha: 0.6),
                                                  
                                                  child: Row(
                                                                                            
                                                    children: [
                                                      const Spacer(),
                                                      const ScalableText("番剧信息正值刚换季,可能会带来频繁的榜单变化"),
                                                      const Spacer(),
                                                      IconButton(
                                                        onPressed: ()=> transitionalSeasonNotifier.value = true,
                                                        icon: const Icon(Icons.close)
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              )
                                            );
                                        }
                                      ),
                                        
                                    ],
                                  ),
                                  
                                ]
                                
                              )
                            ),
                          ),
            
                        ]
                      ),
            
                      Selector<IndexModel, int>(
                        selector: (_, indexModel) => indexModel.selectedWeekDay,
                        shouldRebuild: (previous, next){
                          debugPrint("receive rebuild day:$previous => $next");
                          return previous!=next;
                        },
                        builder: (_, weekday, selectChild) {
                          
                          final selectedDay = indexModel.selectedWeekDay;
            
                          return MultiSliver(
                            pushPinnedChildren: true,
                            children: [
                          
                              SliverPinnedHeader(
                                child: ValueListenableBuilder(
                                  valueListenable: weekdaySelectOffstageNotifier,
                                  builder: (_, weekDayOffstage, child) {
                                  return SizedBox(
                                    height: !weekDayOffstage ? 120 : 60,
                                    child: child!
                                  );
                                },
                                child: DecoratedBox(
                                    
                                  decoration: BoxDecoration(
                                    border: Border(
                                    bottom: Divider.createBorderSide(context)
                                    ),
                                    color: Theme.of(context).colorScheme.surface.withValues(alpha:0.6),
                                  ),
                                  
                                                    
                                  child: Column(
                                    children: [
                                  
                                      Padding(
                                        padding: PaddingH12,
                                        child: SizedBox(
                                          height: 59, // Border:bottom = 1
                                          child: Row(
                                            children: [
                                          
                                              ScalableText("星期${WeekDay.values[selectedDay - 1].dayText}",style: const TextStyle(fontSize: 18)),
                                              selectChild!
                                                              
                                            ],
                                          ),
                                        ),
                                      ),

                                      BangumiTabContentSelect(
                                        selectOffstageNotifier: weekdaySelectOffstageNotifier,
                                        selectOffstageAnimatedNotifier: weekdaySelectOffstageAnimatedNotifier,
                                        selectedList: WeekDay.values,
                                        initalIndex: indexModel.selectedWeekDay - 1,
                                        onTap:  (selectedIndex) {
                                          indexModel.updateSelectedWeekDay(selectedIndex+1);
                                        },
                                        
                                      )

                                    
                                    ],
                                  ),
                                ),
                                ),
                                
                                  
                              ),
                        
                              SliverToBoxAdapter(
                                child: BanguTileGridView(
                                  bangumiLists: calendarBangumis.isEmpty ? [] : calendarBangumis.values.elementAt(selectedDay-1),
                                ),
                              )
            
                            ]
                              
                          );
                        },
                        child: InkResponse(
                          borderRadius: BorderRadius.circular(24),
                          containedInkWell: true,
                          hoverColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: (){
                            debugPrint("show seasons Select");

                            if(weekdaySelectOffstageNotifier.value){
                              weekdaySelectOffstageNotifier.value = false;
                            }

                            if(weekdaySelectOffstageAnimatedNotifier.value){
                              weekdaySelectOffstageAnimatedNotifier.value = false;
                            }

                            else{
                              weekdaySelectOffstageAnimatedNotifier.value = true;
                            }

                          },
							            child: const Icon(Icons.arrow_drop_down,size: 32),
                        ),
                        
                      ),
          
                      
                    ],
                  );
            
                }
              );
          
            },
            
          ),
        );
  
      }
      
    );
  }
}




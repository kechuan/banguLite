
import 'dart:math';

import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/models/eps_info.dart';
import 'package:bangu_lite/models/providers/ep_model.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class EpSelect extends StatefulWidget {
  const EpSelect({
    super.key,
    required this.totalEps,
    required this.airedEps,
    this.name,
    this.portialMode,
	  this.bangumiThemeColor
  });

  final int totalEps;
  final int airedEps;
  final String? name;
  final bool? portialMode;
  final Color? bangumiThemeColor;
  

  @override
  State<EpSelect> createState() => _EpSelectState();
}

class _EpSelectState extends State<EpSelect> with TickerProviderStateMixin {

  ValueNotifier<int> epSegementsIndexNotifier = ValueNotifier<int>(0);

  Future? epsInformationFuture;
  TabController? epTabController;

  

  @override
  Widget build(BuildContext context) {

    final epModel = context.read<EpModel>();

    int segements = convertSegement(widget.totalEps,100);

    epsInformationFuture ??= epModel.getEpsInformation();
    epTabController ??= TabController(length: segements, vsync: this);

    DateTime currentTime = DateTime.now();

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) => true,
      child: LayoutBuilder(
        builder: (_,constraint) {
          return Column(
            children: [
          
                segements >= 2 ?
                  //Tabbar
                  Theme(
                    data: Theme.of(context).copyWith(
                      scrollbarTheme: const ScrollbarThemeData(
                        thickness: WidgetStatePropertyAll(0.0) //it work
                      )
                    ),
                    child: SizedBox(
                      height: 60,
                      child: TabBar(
                        indicatorColor: Theme.of(context).scaffoldBackgroundColor,
                        controller: epTabController,
                        onTap: (index){
                          epSegementsIndexNotifier.value = index;
                          epsInformationFuture = epModel.getEpsInformation(offset: index+1);
                        },
                        isScrollable: true,
                        tabs: List.generate(
                          segements, 
                          (index) => SizedBox(
                            height: 60,
                            width: 100,
                            child: Center(child: ScalableText("${(index*100)+1}~${min((index+1)*100,widget.totalEps)}"))
                          )
                          
                        ),
                          
                      ),
                    ),
                  ):
      
                  widget.portialMode == true ? 
                    Center(
                      child: Padding(
                        padding: PaddingV12,
                        child: ScalableText("${widget.name}"),
                      )
                    ):
                  const SizedBox.shrink(),
          
                //TabView
                SizedBox(
                  height: widget.portialMode == true ? constraint.maxHeight - 80 : MediaQuery.sizeOf(context).width/6,
                  child: ValueListenableBuilder(
                  valueListenable: epSegementsIndexNotifier,
                  builder: (_,currentSegment,child) {
                        
                    int currentSegementRange = (currentSegment)*100; //范围 区域300 这个意思
                    int currentSegmentEps = min(100,widget.totalEps - (currentSegementRange)).abs();
                      
                    //context.read区域	
                    return FutureBuilder(
                      future: epsInformationFuture, //通知器 并不传递信息
                      builder: (_,snapshot) {
                      
                        //epModel => context.watch区域
                        return Selector<EpModel,bool>(
                          selector: (_, epModel)=> epModel.epsData[(currentSegementRange)+1]?.epID == null,
                          shouldRebuild: (previous, next) => previous!=next,
                          builder: (_,loadingStatus,child) {
                          //debugPrint(" inside enabled: ${(currentSegementRange)+1}  ${epModel.epsData[(currentSegementRange)+1]?.epID == null}");
                            return Skeletonizer(
                              enabled: loadingStatus,
                              child: child!
                            );
                          },
                          child: GridView.builder(
                            shrinkWrap: true,
                            itemCount: currentSegmentEps,
                            gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: widget.portialMode == true ? 1 : 3,
                              mainAxisExtent: 60,
                              mainAxisSpacing: 6,
                              crossAxisSpacing: 6
                            ),
                            
                            itemBuilder: (_,index){
                                  
                              Color currentEpsColor = Colors.grey ; //默认灰 未放送
                              int currentEpIndex = (currentSegementRange)+(index)+1;
                          
                              EpsInfo? currentInfo = epModel.epsData[currentEpIndex];
                          
                              //对于时间跨度很大的番剧。像海贼王这种的 我处理方式就是最简单的 air_date 判断了 
                              //不可能做到百分百准确 但没办法 已经没有更好的思路了
                          
                              DateTime? currentEpAirDate = DateTime.tryParse(currentInfo?.airDate ?? "");
                          
                              if(currentEpAirDate!=null){
                                currentTime.difference(currentEpAirDate) > const Duration(hours: 1) ?
                                currentEpsColor = Theme.of(context).scaffoldBackgroundColor: //已放送
                                //currentEpsColor = Colors.indigo: //已放送
                                null ;
                              }
                          
                              if(widget.airedEps < widget.totalEps){ //如果还有未放送的
                                if(widget.airedEps == currentEpIndex) currentEpsColor = AppThemeColor.macha.color; //标注当前放送中最新的一集
                              }
                          
                              return SizedBox(
                                height: 60,
                                child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border(
                                    bottom: BorderSide(
                                      width: 3, 
                                      color:  Colors.grey.withValues(alpha:0.2),
                                    ),
                                  ),
                                  color: currentEpsColor
                                  
                                ),
                                  child: InkResponse(
                                    containedInkWell: true,
                                    hoverColor: Colors.transparent,     // 悬浮时圆点
                                    highlightColor: Colors.transparent, // 点击时的圆点
                                    
                                    onTap: (){
                              
                                      debugPrint("selected Ep:$currentEpIndex");
                                      epModel.updateSelectedEp(currentEpIndex);
                                    
                                      Navigator.pushNamed(
                                        context, Routes.subjectEp,
                                        arguments: {
                                          "subjectID":epModel.subjectID,
                                          "totalEps": widget.totalEps,
                                          "epModel": epModel,
                                          "bangumiThemeColor": widget.bangumiThemeColor
                                        }
                                      );
                                  
                                    
                                    },
                                            
                                    child: Center(
                                      child: ScalableText(
                                        convertCollectionName(currentInfo,currentEpIndex),
                                        style: const TextStyle(color: Colors.black),
                                        textAlign: TextAlign.center,
                                        maxLines: 2 ,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ) 
                                  ),
                                ),
                              );
                                  
                            }
                          ),
                          
                        );
                      }
                    );
                        
                  }
                        
                  ),
                )
          
            ],
          );
        }
      ),
    );
    	  
        
    	
  }
}
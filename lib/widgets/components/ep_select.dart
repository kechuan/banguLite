
import 'dart:math';

import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/models/eps_info.dart';
import 'package:bangu_lite/models/providers/ep_model.dart';
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
  });

  final int totalEps;
  final int airedEps;
  final String? name;
  final bool? portialMode;
  

  @override
  State<EpSelect> createState() => _EpSelectState();
}

class _EpSelectState extends State<EpSelect> with TickerProviderStateMixin {

  ValueNotifier<int> epSegementsIndexNotifier = ValueNotifier<int>(0);
  Future? epsInformationFuture;

  @override
  Widget build(BuildContext context) {

    final EpModel epModel = context.read<EpModel>();


    epsInformationFuture ??= epModel.getEpsInformation();

    int segements = convertSegement(widget.totalEps,100);

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) => true,
      child: LayoutBuilder(
        builder: (_,constraint) {
          return Column(
            children: [
          
          			segements >= 2 ?
          				//Tabbar
          				Theme(
          					data: ThemeData(
          						scrollbarTheme: const ScrollbarThemeData(
                        thickness: WidgetStatePropertyAll(0.0) //it work
                      )
                    ),
                    child: SizedBox(
                      height: 60,
                      child: TabBar(
                        indicatorColor: Theme.of(context).scaffoldBackgroundColor,
                        controller: TabController(length: segements, vsync: this),
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
                            child: Center(child: Text("${(index*100)+1}~${min((index+1)*100,widget.totalEps)}"))
                          )
                          
                        ),
                          
                      ),
                    ),
                  ):

                  widget.portialMode == true ? 
                    Center(
                      child: Padding(
                        padding: PaddingV12,
                        child: Text("${widget.name}"),
                      )
                    ):
                  const SizedBox.shrink(),
          
          			//TabView
          			SizedBox(
                  height: widget.portialMode == true ? constraint.maxHeight -50 : 250,
                  //height: 250,
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
                                  
                              Color currentEpsColor = Colors.white;
                              int currentEpIndex = (currentSegementRange)+(index)+1;
                          
                              //放送中
                              if(widget.airedEps <= widget.totalEps){ 
                                if(widget.airedEps == currentEpIndex) currentEpsColor = const Color.fromARGB(255, 219, 245, 223);
                                if(widget.airedEps > currentEpIndex)  currentEpsColor = Theme.of(context).scaffoldBackgroundColor;
                              }
                          
                              //已完结
                              else{
                                //currentEpsColor = const Color.fromARGB(255, 217, 231, 255);
                                currentEpsColor = Theme.of(context).scaffoldBackgroundColor;
                              }
                            
                                    
                              return SizedBox(
                                height: 60,
                                child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border(
                                   
                                    bottom: BorderSide(
                                      width: 3, 
                                      //color: widget.airedEps >= currentEpIndex ? Theme.of(context).scaffoldBackgroundColor.withValues(alpha:0.2) : Colors.grey,
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
                                        }
                                      );
                                  
                                    
                                    },
                                            
                                    
                                    child: Center(
                                      //child: Text("Ep. $currentEpIndex ${epModel.epsData[currentEpIndex]?.nameCN ?? epModel.epsData[currentEpIndex]?.name }"),
                                      child: Builder(
                                        builder: (_) {

                                          //Color lisibleColor = Theme.of(context).scaffoldBackgroundColor;
                                          
                                          //if(Theme.of(context).scaffoldBackgroundColor.computeLuminance() > 0.5){
                                          //  lisibleColor = Colors.black;
                                          //}
                          
                                          EpsInfo? currentInfo = epModel.epsData[currentEpIndex];
                            
                                          String currentEpText = currentInfo?.nameCN ?? currentInfo?.name ?? ""; 
                          
                                          return Text(
                                            "Ep. $currentEpIndex ${currentEpText.isEmpty ? currentInfo?.name : currentEpText}",
                                            style: const TextStyle(color: Colors.black)
                                          );
                                        }
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
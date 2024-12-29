

import 'dart:math';

import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:flutter/material.dart';

import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:provider/provider.dart';


class WeekDaySelectOverlay{

  WeekDaySelectOverlay._internal(
    this.context,
    this.buttonLayerLink,
    
  );

  factory WeekDaySelectOverlay({
    required BuildContext context,
    required LayerLink buttonLayerLink,
    
  }){
    if(weekDaySelectOverlay!=null){
      return weekDaySelectOverlay!..showWeekDaySelectFieldOverlay();
    }

    else{
      return weekDaySelectOverlay ??= WeekDaySelectOverlay._internal(context,buttonLayerLink)..showWeekDaySelectFieldOverlay();
    }
    
  }

  static WeekDaySelectOverlay? weekDaySelectOverlay;
  OverlayEntry? currentEntry;

  final BuildContext context;
  final LayerLink buttonLayerLink;
  

  final opacityListenable = ValueNotifier<double>(0.0);
  
  

  bool isOverlayActived = false;

  void showWeekDaySelectFieldOverlay(){

    OverlayState overlayState = Overlay.of(context); //refresh OverlayState?

    if(isOverlayActived){
      opacityListenable.value = 0.0;
    }

    else{
      OverlayEntry weekDaySelectOverlay = createOverlay(context);
      overlayState.insert(weekDaySelectOverlay);
      isOverlayActived = true;
    }
    

  }

  void closeWeekDaySelectFieldOverlay(){

    if(isOverlayActived){
      currentEntry?.remove();
      isOverlayActived = false;
    }

  }

  OverlayEntry createOverlay(BuildContext context){
    return currentEntry = OverlayEntry(
      
      builder: (_){

        debugPrint("overlay rebuild");

        //perfect work.
        WidgetsBinding.instance.addPostFrameCallback((timeStamp){
          opacityListenable.value = 1.0;
        });

        return ValueListenableBuilder(
          valueListenable: opacityListenable,
          builder: (_, opacityDegree, child) {
            return AnimatedOpacity(
              opacity: opacityDegree,
              duration: const Duration(milliseconds: 300),
              child: child!,
              onEnd: () {
                if(opacityDegree == 1.0){
                  debugPrint("triged Show End,hashCode:$hashCode");
                }
            
                else{
                  closeWeekDaySelectFieldOverlay();
                  debugPrint("triged Close End");
                }
                
                
              },
            );
          },
          
          child: Stack(
            children: [

              Positioned(
                height: 100,
                width:  min(350, MediaQuery.sizeOf(context).width),
                child: CompositedTransformFollower(
                  showWhenUnlinked:false,
                  offset: Offset(
                    MediaQuery.orientationOf(context) == Orientation.portrait ? -60 : 0,
                    30
                  ),
                  link: buttonLayerLink,
                  child: ClipRRect(
                    borderRadius:BorderRadius.circular(16),
                    child: Material(
                      color: BangumiThemeColor.macha.color,
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                        
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children:  [
                                 const SizedBox.shrink(),
                                 const ScalableText("天数选择"),
                                 IconButton(onPressed: ()=> opacityListenable.value = 0.0, icon: const Icon(Icons.close))
                              ],
                            ),
                        
                            Expanded(
                              child: ListView.builder(
                                scrollDirection :Axis.horizontal,
                                itemCount: 7,
                                itemExtent: 50, 
                                itemBuilder: (_,index){
                                  return DecoratedBox(
                                    decoration: BoxDecoration(
                                      border: WeekDay.values[index].dayIndex == DateTime.now().weekday ? 
                                      Border.all(width: 1.5,color:  const Color.fromARGB(255, 220, 194, 156)) :
                                      null
                                    ),
                                    child: ListTile(
                                      selectedTileColor: const Color.fromARGB(255, 147, 220, 149),
                                      selected: index == context.read<IndexModel>().selectedWeekDay - 1,
                                      title: ScalableText(WeekDay.values[index].dayText),
                                      onTap: () {

                                        opacityListenable.value = 0.0;

                                        debugPrint("weekDaySelect click:${index+1}");
                                        
 
                                        context.read<IndexModel>().updateSelectedWeekDay(index+1);
                                      },
                                      
                                    ),
                                  );
                                }
                              ),
                            ),
                          
                          ],
                        ),
                    ),
                  ),
                  ),
              ),
            
              
            ]
          ),
        );

      }
    );
  }

}


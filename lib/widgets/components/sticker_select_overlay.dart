

import 'dart:math';

import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/internal/utils/convert.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/widgets/fragments/request_snack_bar.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class StickerSelectOverlay{

  StickerSelectOverlay(
    {
      required this.context,
      this.buttonLayerLink,
      this.postCommentType,
      this.onStick,
    }
  );

  final BuildContext context;
  final LayerLink? buttonLayerLink;
  final PostCommentType? postCommentType;
  final Function(int)? onStick;

  final opacityListenable = ValueNotifier<double>(0.0);

  static const double overlayHeight = 150;

  OverlayEntry? currentEntry;
  bool isOverlayActived = false;

  bool measurePopUpDirection(){
    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    //屏幕高度 - 按钮底部的 Y 坐标
    double spaceBelow = MediaQuery.sizeOf(context).height - (offset.dy + renderBox.size.height);

    return spaceBelow < overlayHeight;
    
  }

  void showStickerSelectOverlay(int? commentID){

    if(commentID==null) return;

    if(isOverlayActived){
      opacityListenable.value = 0.0;
    }

    else{
      
      OverlayState overlayState = Overlay.of(context); //refresh OverlayState?      
      overlayState.insert( currentEntry ?? createOverlay(commentID));

      isOverlayActived = true;
    }
    

  }

  void closeStickerSelectFieldOverlay(){

    if(isOverlayActived){
      currentEntry?.remove();
      isOverlayActived = false;
    }

  }

  OverlayEntry createOverlay(
    int commentID
  ){
    return currentEntry ??= OverlayEntry(
      
      
      builder: (_){

        debugPrint("overlay rebuild");

        //perfect work.
        WidgetsBinding.instance.addPostFrameCallback((timeStamp){
          opacityListenable.value = 1.0;
        });

        return TapRegion(
          groupId: 'stickerSelectOverlay',
          consumeOutsideTaps: true,
          onTapOutside: (event) {
            opacityListenable.value = 0.0;
          },
          child: ValueListenableBuilder(
            valueListenable: opacityListenable,
            builder: (_, opacityDegree, child) {
              return AnimatedOpacity(
              
                opacity: opacityDegree,
                
                duration: const Duration(milliseconds: 300),
                child: child!,
                onEnd: () {
                  if(opacityDegree == 1.0){
                    debugPrint("trigged stickerOverlay Show,hashCode:$hashCode");
                  }
              
                  else{
                    closeStickerSelectFieldOverlay();
                    debugPrint("trigged stickerOverlay Close");
                  }
                  
                  
                },
              );
            },
          
          
            
            child: Stack(
              children: [
            
                Positioned(
                  height: 150,
                  width: min(250, MediaQuery.sizeOf(context).width),
                  child: CompositedTransformFollower(
                    showWhenUnlinked:true,
                    offset:  Offset(-250, measurePopUpDirection() ? -overlayHeight : 45),
                    //offset: Offset(-250,),
                    //offset:buttonLayerLink!.leaderSize!.topLeft( Offset.zero),
                    link: buttonLayerLink!,
                    child: ClipRRect(
                      borderRadius:BorderRadius.circular(16),
                      child: Material(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: judgeDarknessMode(context) ? Colors.white : Colors.transparent,
                            ),
                            borderRadius: BorderRadius.circular(16)
                            
                          ),
                          child: Column(
                            spacing: 6,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                    
                                  const SizedBox.shrink(),
                                    
                                  const ScalableText("贴纸选择"),
                                    
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () => opacityListenable.value = 0.0,
                                  )
                                ]
                                
                              ),
                                    
                              Expanded(
                                child: GridView(
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4
                                  ),
                                  children: List.generate(
                                    12, ((index){
                                      return GridTile(
                                        child: InkResponse(
                                          onTap: () {
          
                                            invokeRequestSnackBar({String? message,bool? requestStatus}) => showRequestSnackBar(
                                              message: message,
                                              requestStatus: requestStatus,
                                              backgroundColor: judgeCurrentThemeColor(context)
                                            );
          
                                            final accountModel = context.read<AccountModel>();
                          
                                            debugPrint("dataIndex:${stickerDataLike[index]}, postCommentType:$postCommentType, subject:$commentID");
          
                                            invokeRequestSnackBar();
                                    
                                            accountModel.toggleCommentLike(
                                              commentID, 
                                              stickerDataLike[index],
                                              postCommentType,
                                              fallbackAction: (message){
                                                invokeRequestSnackBar(message: message,requestStatus: false);
                                              }
                                            ).then((result){
                                              //这里就没办法联动了。。毕竟是overlay
                                              if(result){
          
                                                onStick?.call(stickerDataLike[index]);
          
                                                invokeRequestSnackBar(message: "贴条成功", requestStatus: true);
          
                                              }
                                              
                                            });
                          
                                            opacityListenable.value = 0.0;
                          
                                          },
                                          child: Image.asset(
                                            convertBangumiStickerPath(convertStickerDatalike(stickerDataLike[index])),
                                            scale: 0.8,
                                          ),
                                        )
                                      );
                                    })
                                  ),
                                ),
                              ),
                            
                            ],
                          ),
                        )
                      
                      ),
                    ),
                    ),
                ),
              
                
              ]
            ),
          
          ),
        );

      }
    );
  }

}


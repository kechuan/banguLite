

import 'dart:math';

import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';


class StickerSelectOverlay{

  StickerSelectOverlay(
    {
      required this.context,
      this.buttonLayerLink,
      this.postCommentType
    }
  );


  final BuildContext context;
  final LayerLink? buttonLayerLink;
  final PostCommentType? postCommentType;

  final opacityListenable = ValueNotifier<double>(0.0);

  OverlayEntry? currentEntry;

  bool isOverlayActived = false;

  void showStickerSelectOverlay(int? commentID){

    if(commentID==null) return;

    if(isOverlayActived){
      opacityListenable.value = 0.0;
    }

    else{
      OverlayState overlayState = Overlay.of(context); //refresh OverlayState?
      OverlayEntry stickerSelectOverlay = createOverlay(context,commentID,postCommentType);
      overlayState.insert(stickerSelectOverlay);
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
    BuildContext context,
    int commentID,
    PostCommentType? postCommentType
  ){
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
                  closeStickerSelectFieldOverlay();
                  debugPrint("triged Close End");
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
                  offset: const Offset(-250,30),
                  link: buttonLayerLink!,
                  child: ClipRRect(
                    borderRadius:BorderRadius.circular(16),
                    child: Material(
                    
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
                                        final accountModel = context.read<AccountModel>();

                                        debugPrint("postCommentType:$postCommentType");
          
                                        accountModel.toggleCommentLike(
                                          commentID, 
                                          stickerDataLike[index],
                                          postCommentType,
                                        );

                                        opacityListenable.value = 0.0;

                                      },
                                      child: Image.asset(
                                        "assets/bangumiSticker/bgm${convertStickerDatalike(stickerDataLike[index])}.gif",
                                        scale: 0.8,
                                      ),
                                    )
                                  );
                                })
                              ),
                            ),
                          ),
                        
                        ],
                      )
                    
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


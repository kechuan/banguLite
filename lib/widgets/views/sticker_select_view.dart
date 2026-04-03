import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/internal/utils/convert.dart';
import 'package:bangu_lite/widgets/fragments/unvisible_response.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';

class StickerSelectView extends StatelessWidget {
    StickerSelectView({
        super.key,
        required this.contentEditingController,
    });

    final TextEditingController contentEditingController;
    final PageController stickerPageController = PageController();

    final ValueNotifier stickerSelectNotifier = ValueNotifier(0);

    void insertBgmSticker(int index,{bool? isMusume}) {
        int currentPostion = contentEditingController.selection.start;

        String prefix = switch(isMusume){
          true => 'musume_',
          false => 'blake_',
          _ => 'bgm',
        };

        contentEditingController.text = 
        convertInsertContent(
            originalText: contentEditingController.text,
            insertText: '($prefix${convertDigitNumString(index)})',
            insertOffset: currentPostion
        );

        //(bgm01)=>(bgm1xx)
        contentEditingController.selection = TextSelection.fromPosition(
            TextPosition(offset: currentPostion + '($prefix)'.length + (index >= 100 ? 3 : 2))
        );
    }

    @override
    Widget build(BuildContext context) {

      final List<Tab> tabList = [
        Tab(text: 'bgm 01-23(dsm)', icon: Image.asset(convertBangumiStickerPath(1),scale:0.75)),
        Tab(text: 'bgm 24-125(Cinnamor)', icon: Image.asset(convertBangumiStickerPath(24),scale:0.75)),
        Tab(text: 'bgm 200-238(神戶小鳥)', icon: Image.asset(convertBangumiStickerPath(200),scale:0.75)),
        Tab(text: 'bgm 500-529(五行行行行行啊)', icon: Image.asset(convertBangumiStickerPath(500),scale:0.75)),
        Tab(text: 'Bangumi娘 (貓魚)', icon: Image.asset(convertBangumiStickerPath(0),scale:6)),
        Tab(text: 'Blake娘 (貓魚)', icon: Image.asset(convertBangumiStickerPath(-1),scale:6)),
      ];


        return Column(
            children: [

                Expanded(
                    child: EasyRefresh(
                        child: PageView.builder(
                            controller: stickerPageController,
                            itemBuilder: (_, index) {
                        
                              int stickerLength = 0;
                              int stickerOffset = 0;

                              bool? isMusume;
                        
                              switch(index){
                                case 0:{stickerLength = 23; stickerOffset += 1;}
                                case 1:{stickerLength = 102; stickerOffset += 24;}
                                case 2:{stickerLength = 39; stickerOffset += 200;}
                                case 3:{stickerLength = 30; stickerOffset += 500;}
                                case 4:{stickerLength = 96; stickerOffset += 1; isMusume = true;}
                                case 5:{stickerLength = 97; stickerOffset += 1; isMusume = false;}
                              }
                        
                        
                              return GridView(
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: MediaQuery.orientationOf(context) == Orientation.landscape ? 12 : 6
                                  ),
                                  children: List.generate(
                                      stickerLength,
                                      ((index) {
                                          if(isMusume == null){
                                            return UnVisibleResponse(
                                              onTap: () => insertBgmSticker(stickerOffset + index,isMusume:isMusume),
                                              child: Image.asset(
                                                convertBangumiStickerPath(stickerOffset + index),
                                                scale: 0.6,
                                              )
                                            );
                                          }

                                          return UnVisibleResponse(
                                            onTap: () => insertBgmSticker(stickerOffset + index,isMusume:isMusume),
                                            child: CachedNetworkImage(
                                              imageUrl: convertBangumiNetworkGirlStickerPath(stickerOffset + index,pinkVersion: isMusume),
                                              progressIndicatorBuilder: (context, url, progress) => Transform.scale(
                                                scale: 0.4,
                                                child: CircularProgressIndicator(
                                                  value: progress.progress,
                                                  strokeWidth: 12,
                                                ),
                                              ),
                                              scale: 4,
                                            )
                                          );

                                          
                                      })
                                  ),
                              );
                            },
                        
                        ),
                    ),
                ),

                ValueListenableBuilder(
                  valueListenable: stickerSelectNotifier,
                  builder: (_, stickerIndex, child) {

                    return Row(
                      children: List.generate(
                        tabList.length, (index){
                          bool isActive = (stickerIndex == index);
                          return Expanded(
                            // 激活的tab占用更多空间，非激活的占用较少空间
                            flex: isActive ? (judgeLandscapeMode(context) ? 3 : 4) : 1,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              child: UnVisibleResponse(
                                onTap: () {
                                  stickerSelectNotifier.value = index;
                                  stickerPageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                  decoration: BoxDecoration(
                                    //color: isActive ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(isActive ? 16 : 0),
                                      topRight: Radius.circular(isActive ? 16 : 0),
                                    ),
                                  ),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: 
                                        isActive ? 
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          spacing: 12,
                                          children: [
                                            tabList[index].icon!,
                                            Flexible(
                                              child: Text(
                                                "${tabList[index].text}",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        )
                                      : tabList[index].icon!,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      )
                      
                    
                    );

                  }
                ),

            ],
        );
    }
}

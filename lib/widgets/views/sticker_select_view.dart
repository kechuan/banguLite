import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/internal/utils/convert.dart';
import 'package:bangu_lite/widgets/fragments/unvisible_response.dart';
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

    @override
    Widget build(BuildContext context) {

      final List<Tab> tabList = [
        Tab(text: 'bgm 01-23(dsm)', icon: Image.asset(convertBangumiStickerPath(1))),
        Tab(text: 'bgm 24-125(Cinnamor)', icon: Image.asset(convertBangumiStickerPath(24))),
        Tab(text: 'bgm 200-238(神戶小鳥)', icon: Image.asset(convertBangumiStickerPath(200))),
        Tab(text: 'bgm 500-529(五行行行行行啊)', icon: Image.asset(convertBangumiStickerPath(500))),
      ];


        return Column(
            children: [

                Expanded(
                    child: EasyRefresh(
                        child: Builder(
                            builder: (_) {

                                insertBgmSticker(int index) {
                                    int currentPostion = contentEditingController.selection.start;

                                    contentEditingController.text = 
                                    convertInsertContent(
                                        originalText: contentEditingController.text,
                                        insertText: '(bgm${convertDigitNumString(index)})',
                                        insertOffset: currentPostion
                                    );

                                    //(bgm01)=>(bgm1xx)
                                    contentEditingController.selection = TextSelection.fromPosition(
                                        TextPosition(offset: currentPostion + '(bgm)'.length + (index >= 100 ? 3 : 2))
                                    );
                                }

                                return PageView.builder(
                                    controller: stickerPageController,
                                    itemBuilder: (_, index) {

                                      int stickerLength = 0;
                                      int stickerOffset = 0;

                                      switch(index){
                                        case 0:{stickerLength = 23; stickerOffset += 1;}
                                        case 1:{stickerLength = 102; stickerOffset += 24;}
                                        case 2:{stickerLength = 39; stickerOffset += 200;}
                                        case 3:{stickerLength = 30; stickerOffset += 500;}
                                      }


                                      return GridView(
                                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: MediaQuery.orientationOf(context) == Orientation.landscape ? 16 : 8
                                          ),
                                          children: List.generate(
                                              stickerLength,
                                              ((index) {
                                                  return UnVisibleResponse(
                                                      onTap: () => insertBgmSticker(stickerOffset + index),
                                                      child: Image.asset(
                                                          convertBangumiStickerPath(stickerOffset + index),
                                                          scale: 0.8,
                                                      )
                                                  );
                                              })
                                          ),
                                      );
                                    },

                                );

                            }
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
                            flex: isActive ? (judgeLandscapeMode(context) ? 2 : 3) : 1,
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              child: UnVisibleResponse(
                                onTap: () {
                                  stickerSelectNotifier.value = index;
                                  stickerPageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                  decoration: BoxDecoration(
                                    //color: isActive ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(isActive ? 16 : 0),
                                      topRight: Radius.circular(isActive ? 16 : 0),
                                    ),
                                  ),
                                  child: AnimatedSwitcher(
                                    duration: Duration(milliseconds: 200),
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
                                                style: TextStyle(
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

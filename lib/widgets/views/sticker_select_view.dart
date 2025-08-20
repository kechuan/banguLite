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

    @override
    Widget build(BuildContext context) {
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

                DefaultTabController(
                    length: 4,
                    child: TabBar(
                        onTap: (index) {stickerPageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                        },
                        tabs: const[
                            Tab(text: 'bgm 01-23(dsm)'),
                            Tab(text: 'bgm 24-125(Cinnamor)'),
                            Tab(text: 'bgm 200-238(神戶小鳥)'),
                            Tab(text: 'bgm 500-529(五行行行行行啊)'),
                        ]
                    )
                )
            ],
        );
    }
}

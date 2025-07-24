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
                                        insertText: '(bgm${convertDigitNumString(index + 1)})',
                                        insertOffset: currentPostion
                                    );

                                    //(bgm01)=>(bgm1xx)
                                    contentEditingController.selection = TextSelection.fromPosition(
                                        TextPosition(offset: currentPostion + '(bgm)'.length + (index >= 100 ? 3 : 2))
                                    );
                                }

                                return PageView(
                                    controller: stickerPageController,
                                    children: [
                                        GridView(
                                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: MediaQuery.orientationOf(context) == Orientation.landscape ? 16 : 8
                                            ),
                                            children: List.generate(
                                                23,
                                                ((index) {
                                                    return UnVisibleResponse(
                                                        onTap: () => insertBgmSticker(index),
                                                        child: Image.asset(
                                                            convertBangumiStickerPath(index + 1),
                                                            scale: 0.8,
                                                        )
                                                    );
                                                })
                                            ),
                                        ),

                                        GridView(

                                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: MediaQuery.orientationOf(context) == Orientation.landscape ? 16 : 8
                                            ),
                                            children: List.generate(
                                                102,
                                                ((index) {
                                                    return UnVisibleResponse(
                                                        onTap: () => insertBgmSticker(index + 23),
                                                        child: Image.asset(
                                                          convertBangumiStickerPath(index + 24),
                                                          scale: 0.8,
                                                        )
                                                    );
                                                })
                                            ),
                                        ),

                                    ],

                                );
                            }
                        ),
                    ),
                ),

                DefaultTabController(
                    length: 2,
                    child: TabBar(
                        onTap: (index) {stickerPageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                        },
                        tabs: const[
                            Tab(text: 'bgm 01-23(dsm)'),
                            Tab(text: 'bgm 24-125(Cinnamor)'),
                        ]
                    )
                )
            ],
        );
    }
}

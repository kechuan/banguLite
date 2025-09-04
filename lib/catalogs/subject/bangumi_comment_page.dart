
import 'package:bangu_lite/internal/utils/convert.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/dialogs/warp_page_dialog.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';

@FFAutoImport()
import 'package:bangu_lite/models/providers/comment_model.dart';

import 'package:bangu_lite/widgets/components/bangumi_comments.dart';
import 'package:provider/provider.dart';

@FFRoute(name: '/subjectComment')
class BangumiCommentPage extends StatelessWidget  {
  const BangumiCommentPage({
    super.key,
    required this.commentModel,
    required this.subjectID,
    this.bangumiThemeColor,
    this.name
  });

  final CommentModel commentModel;
  final int subjectID;
  final Color? bangumiThemeColor;
  final String? name;

  @override
  Widget build(BuildContext context) {

    final PageController commentPageController = PageController();
    
    //给每个番剧页面都单独拉一个 CommentProvider 避免互相跳转之间打架
    return Theme(
      data: ThemeData(
        brightness: Theme.of(context).brightness,
        colorSchemeSeed: judgeDetailRenderColor(context,bangumiThemeColor),
        
        fontFamilyFallback: convertSystemFontFamily()
      ),
      child: ChangeNotifierProvider.value(
        value: commentModel,
        builder: (context,child) {
          return Scaffold(
            appBar: AppBar(
              title: ScalableText(name ?? "comments Detail"),
              actions: [
                IconButton(
                  onPressed: ()=>showWrapPageDialog(context,commentPageController),
                  icon: const Icon(Icons.wrap_text_outlined)
                )
              ],
              
            ),
            
            body: FutureBuilder(
              future: context.read<CommentModel>().getCommentLength(subjectID), 
              //sideEffect的代价比较低 所以就不专门设立Completer或者State了
              builder: (_,snapshot) {
                switch(snapshot.connectionState){
            
                  case ConnectionState.done:{
                    return CommentView(
                      //totalPageLength: context.read<CommentModel>().commentLength,
                      totalPageLength: convertTotalCommentPage(context.read<CommentModel>().commentLength, 10),
                      commentPageController: commentPageController,
                      bangumiThemeColor: bangumiThemeColor,
                      subjectID: subjectID,
                    );
            
                  }
            
                  default: return const CommentLoading();
                    
                }
              
              }
            )
            
          );
        }
      ),
    );
     
  }

}




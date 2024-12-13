
import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/widgets/warp_page_dialog.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';

import 'package:bangu_lite/models/providers/comment_model.dart';
import 'package:bangu_lite/widgets/components/bangumi_comments.dart';
import 'package:provider/provider.dart';

@FFRoute(name: '/moreComment')
class MoreCommentsPage extends StatelessWidget  {
  const MoreCommentsPage({
    super.key,
    required this.commentModel,
    required this.subjectID,
    this.name
  });

  final CommentModel commentModel;
  final int subjectID;
  final String? name;

  @override
  Widget build(BuildContext context) {

    final PageController commentPageController = PageController();
    
    //给每个番剧页面都单独拉一个 CommentProvider 避免互相跳转之间打架
    return ChangeNotifierProvider.value(
      //create: (_) => CommentModel(),
      value: commentModel,
      builder: (context,child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(name ?? "comments Detail"),
            actions: [
              //when loaded, show more or empty
              //jumpPage

              IconButton(
                onPressed: (){
                  showDialog(
                    
                    context: context,
                    builder: (_){

                      final commentModel = context.read<CommentModel>();

                      final FixedExtentScrollController pageSelectorController = 
                      FixedExtentScrollController(initialItem: commentModel.currentPageIndex - 1);
 
                      final TextEditingController jumpPageEditingController = TextEditingController();

                      return WarpPageDialog(
                        pageSelectorController: pageSelectorController,
                        jumpPageEditingController: jumpPageEditingController,
                        commentTotalPage: convertTotalCommentPage(commentModel.commentLength, 10),
                        onConfirmPressed: () {
                          Navigator.of(context).pop();

                          final int newPageIndex = (int.tryParse(jumpPageEditingController.text) ?? pageSelectorController.selectedItem + 1);

                          commentModel.changePage(newPageIndex - 1);
                          commentPageController.jumpToPage(newPageIndex - 1);
                        },
                      );

                      
                    }
                  );
                },
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
        
                    subjectID: subjectID,
                  );
          
                }
          
                default: return const CommentLoading();
                  
              }
            
            }
          )
          
        );
      }
    );
     
  }

}




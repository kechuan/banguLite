
import 'package:bangu_lite/widgets/warp_page_dialog.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';
import 'package:bangu_lite/models/providers/bangumi_model.dart';

import 'package:bangu_lite/models/providers/comment_model.dart';
import 'package:bangu_lite/widgets/components/bangumi_comments.dart';
import 'package:provider/provider.dart';

@FFRoute(name: '/moreComment')
class MoreCommentsPage extends StatelessWidget  {
  const MoreCommentsPage({
    super.key,
    required this.subjectID
  });

  final int subjectID;

  @override
  Widget build(BuildContext context) {

    final PageController commentPageController = PageController();
    

    return ChangeNotifierProvider(
      create: (_) => CommentModel(),
      builder: (context,child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(context.read<BangumiModel>().bangumiDetails?.name ?? "comments Detail"),
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
                        commentTotalPage: convertTotalToPage(commentModel.commentLength, 10),
                        onConfirmPressed: () {
                          Navigator.of(context).pop();

                          final int newPageIndex = (int.tryParse(jumpPageEditingController.text) ?? pageSelectorController.selectedItem);

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
            future: context.read<CommentModel>().getCommentLength(subjectID), //代价比较低
            builder: (_,snapshot) {
              switch(snapshot.connectionState){
          
                case ConnectionState.done:{
                  return CommentView(
                    //totalPageLength: context.read<CommentModel>().commentLength,
                    totalPageLength: convertTotalToPage(context.read<CommentModel>().commentLength, 10),
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

  int convertTotalToPage(int totalItemsLength,int pageLength){
    int pageCount = 0;

    if(totalItemsLength%pageLength == 0){
      pageCount =  totalItemsLength ~/ pageLength;
    }

    else{
      pageCount = (totalItemsLength ~/ pageLength) + 1;
    }

    return pageCount;
  }

}




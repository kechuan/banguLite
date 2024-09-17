
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bangumi/internal/max_number_input_formatter.dart';
import 'package:flutter_bangumi/models/providers/bangumi_model.dart';

import 'package:flutter_bangumi/models/providers/comment_model.dart';
import 'package:flutter_bangumi/widgets/components/bangumi_comments.dart';
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

                      final FixedExtentScrollController pageSelectorController = 
                      FixedExtentScrollController(initialItem: context.read<CommentModel>().currentPageIndex - 1);

                      final TextEditingController jumpPageEditingController = TextEditingController();

                      final commentTotalPage = convertTotalToPage(context.read<CommentModel>().commentLength, 10);

                      return Dialog(

                        backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.9),
                        
                        child: SizedBox(
                          height: MediaQuery.sizeOf(context).height/3,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                            
                                const Text("跳转到页面..",style: TextStyle(fontSize: 24)),
                            
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [

                                      SizedBox(
                                        height: 120,
                                        width: 150,
                                        child: ListWheelScrollView.useDelegate(
                                          
                                          itemExtent: 50,
                                          controller: pageSelectorController,
                                          physics: const FixedExtentScrollPhysics(),
                                          childDelegate: ListWheelChildBuilderDelegate(
                                            childCount: commentTotalPage,
                                            builder: (_,index){
                                              return Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  Text("${index+1}"),
                                                  const Divider(height: 1)
                                                ],
                                              );
                                            }
                                          ),
                                      
                                        ),
                                      ),
                                    
                                      DecoratedBox(
                                        decoration: BoxDecoration(
                                          border: Border.all(width: 0.5)
                                        ),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 60,
                                              child: TextField(
                                                controller: jumpPageEditingController,
                                                textAlign: TextAlign.center,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter.deny(RegExp(r'^0$'),replacementString: '1'),
                                                  FilteringTextInputFormatter.digitsOnly,
                                                  MaxValueFormatter(commentTotalPage),
                                                  
                                                ],
                                              ),
                                            ),
                                            Text("/$commentTotalPage 页")
                                          ],
                                        ),
                                      )

                                    ],
                                  ),
                                ),
                          
                          
                            
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Row(
                                      children: [
                                        TextButton(
                                          onPressed: ()=> Navigator.of(context).pop(),
                                          child: const Text("取消",style: TextStyle(fontSize: 16),)
                                        ),
                                        TextButton(
                                          onPressed: (){
                                            Navigator.of(context).pop();

                                            commentPageController.jumpToPage( (int.tryParse(jumpPageEditingController.text) ?? pageSelectorController.selectedItem) - 1 );
                                          },
                                          child: const Text("确定",style: TextStyle(fontSize: 16),)
                                        )
                                      ]
                                    )
                                  ],
                                )
                              
                              
                              ],
                            ),
                          ),
                        ),
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




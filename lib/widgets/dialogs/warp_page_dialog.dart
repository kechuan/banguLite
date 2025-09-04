
import 'package:bangu_lite/internal/utils/convert.dart';
import 'package:bangu_lite/internal/max_number_input_formatter.dart';
import 'package:bangu_lite/models/providers/comment_model.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class WarpPageDialog extends StatelessWidget {
  const WarpPageDialog({
    super.key,
    required this.commentTotalPage,
    required this.pageSelectorController,
    required this.jumpPageEditingController,

    this.onConfirmPressed
  });

  final FixedExtentScrollController pageSelectorController;
  final TextEditingController jumpPageEditingController;
  final int commentTotalPage;

  final Function()? onConfirmPressed;

  @override
  Widget build(BuildContext context) {

    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha:0.9),
      
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height/3 > 200 ? MediaQuery.sizeOf(context).height/3 : 200,
          maxWidth: MediaQuery.sizeOf(context).width/3 > 300 ? MediaQuery.sizeOf(context).width/3 : 300,
          minHeight: 200,
          minWidth: 300
        ),
        
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
          
              const ScalableText("跳转到页面..",style: TextStyle(fontSize: 24)),
          
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
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
                                ScalableText("${index+1}"),
                                const Divider(height: 1)
                              ],
                            );
                          }
                        ),
                    
                      ),
                    ),
                  
                    DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(width: 0.5),
                        borderRadius: BorderRadius.circular(16)
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 60,
                            child: TextField(
                              controller: jumpPageEditingController,
                              decoration: const InputDecoration(
                                border: InputBorder.none
                              ),
                              textAlign: TextAlign.center,
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(RegExp(r'^0$'),replacementString: '1'),
                                FilteringTextInputFormatter.digitsOnly,
                                MaxValueFormatter(commentTotalPage),
                              ],
                            ),
                          ),
                          ScalableText("/$commentTotalPage 页")
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
                        child: const ScalableText("取消")
                      ),
                      TextButton(
                        onPressed: (){
                          if(onConfirmPressed!=null){
                              onConfirmPressed!();
                          }
                           
                        },
                        child: const ScalableText("确定")
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
}

void showWrapPageDialog(BuildContext context,PageController commentPageController){
  showGeneralDialog(
    barrierDismissible: true,
    barrierLabel: "'!barrierDismissible || barrierLabel != null' is not true",
    context: context,
    transitionBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation,child: child),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_,inAnimation,outAnimation){

      final commentModel = context.read<CommentModel>();

      final FixedExtentScrollController pageSelectorController = 
        FixedExtentScrollController(initialItem: commentModel.currentPageIndex - 1);

      final TextEditingController jumpPageEditingController = TextEditingController();

      return WarpPageDialog(
        pageSelectorController: pageSelectorController,
        jumpPageEditingController: jumpPageEditingController,
        commentTotalPage: convertTotalCommentPage(commentModel.commentLength, 10),
        onConfirmPressed: () {
          debugPrint("on Confirm Trigged");

          Navigator.of(context).pop();

          final int newPageIndex = (int.tryParse(jumpPageEditingController.text) ?? pageSelectorController.selectedItem + 1);

          commentModel.changePage(newPageIndex - 1);
          commentPageController.jumpToPage(newPageIndex - 1);
        },
      );

      
    }
  );
}

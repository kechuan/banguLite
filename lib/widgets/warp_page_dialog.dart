import 'package:bangu_lite/internal/max_number_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.9),
      
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
          
              const Text("跳转到页面..",style: TextStyle(fontSize: 24)),
          
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
                        onPressed: onConfirmPressed ?? (){},
                        //onPressed: (){
                        //  Navigator.of(context).pop();

                        //  final int newPageIndex = (int.tryParse(jumpPageEditingController.text) ?? pageSelectorController.selectedItem);

                        //  context.read<CommentModel>().changePage(newPageIndex);
                        //  commentPageController.jumpToPage(newPageIndex);
                        //},
                        child: const Text("确定",style: TextStyle(fontSize: 16))
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
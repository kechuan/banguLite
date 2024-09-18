

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/internal/event_bus.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/widgets/fragments/date_range_select.dart';

class Searchfliter extends StatefulWidget {
  const Searchfliter({super.key});

  @override
  State<Searchfliter> createState() => _SearchfliterState();
}

class _SearchfliterState extends State<Searchfliter> {

  RangeValues ratingRange = const RangeValues(0, 1);

  final List<String> tagsList = [
    //"日本","动漫","2D","芳文社","2024年9月","哎！弄一碗面给你尝尝","芝士雪豹"
  ];

  final TextEditingController yearEditingControllerStart = TextEditingController(text: "${DateTime.now().year}");
  final TextEditingController yearEditingControllerEnd = TextEditingController(text: "${DateTime.now().year}");

  final TextEditingController tagsEditingController = TextEditingController();

  final TextEditingController rankEditingControllerStart = TextEditingController();
  final TextEditingController rankEditingControllerEnd = TextEditingController();

  final GlobalKey<AnimatedListState> animatedTagsListKey = GlobalKey<AnimatedListState>();

  Map<String,dynamic> searchFliter = BangumiDatas.sortData;

  Map<int,int> monthSelect = {};

  @override
  void initState() {
    bus.on(const ValueKey("monthStartSelect"),(arg){
      debugPrint("recived start arg:$arg");
      monthSelect[0] = arg;
    });

    bus.on(const ValueKey("monthEndSelect"),(arg){
      debugPrint("recived end arg:$arg");
      monthSelect[1] = arg;
    });
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
      
            //DateRange
            DecoratedBox(
              decoration: const BoxDecoration( 
                border: Border(
                  bottom: BorderSide(width: 1),
              )),
              child: Row(
                children: [

                  DateRangeSelect(
                    key: const ValueKey("monthStartSelect"),
                    dateRangeEditingController: yearEditingControllerStart
                  ),
              
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Text("~"),
                  ),
              
                  DateRangeSelect(
                    key: const ValueKey("monthEndSelect"),
                    dateRangeEditingController: yearEditingControllerEnd
                  ),
              
                ],
              ),
            ),
      
            //RankRange
            DecoratedBox(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 1)
                )
              ),
              child: Row(
                children: [
              
                  const Text("rankRange:"),
              
                  Row(
                    children: [
                                
                      SizedBox(
                        width: 60,
                        child: TextField(
                          controller: rankEditingControllerStart,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            border: InputBorder.none
                          ),
                        ),
                      ),
                                
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text("~"),
                      ),
                                
                                
                      SizedBox(
                        width: 60,
                        child: TextField(
                          controller: rankEditingControllerEnd,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            border: InputBorder.none
                          ),
                        ),
                      ),
                                
                                
                    ],
                  ),
                ],
              ),
            ),
      
      
            //TagsList TextField
            DecoratedBox(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 1),
                )
              ),
              
              child: Row(
                children: [
                  
                  const Text("tagInput:"),
      
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: SizedBox(
                      width: 150,
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (notification) => true, //禁止通知给上层
                        child: TextField(
                          controller: tagsEditingController,
                          decoration: const InputDecoration(
                            border: InputBorder.none
                          ),
                        ),
                      ),
                    ),
                  ),
      
                  //细节: label得到的icon是会顺应 colorSchme主题色的
                  TextButton.icon(
                    onPressed: (){
      
                      tagsList.add(tagsEditingController.text);
                      
                      animatedTagsListKey.currentState?.insertItem(
                        tagsList.isEmpty ? 0 : tagsList.length-1,
                        duration: const Duration(milliseconds: 300)
                      );
                    }, label: const Icon(Icons.upload)
                  )
      
      
                ],
              ),
            ),

            //RankSlider
            Row(
              children: [
                
                const Text("ratingRange:"),
            
                Text("${ratingRange.start*10}"),
      
                //但好在还是可以间接的用Expanded来限制
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    //不能直接使用Expanded 不知道为什么 也许是因为它在layout Inspector里
                    //查看是RangeSlirenderObject吧??
                    child: RangeSlider( 
                      values: ratingRange, 
                      onChanged: (rankValues){
                        setState(() {
                          ratingRange = rankValues;
                        });
                      },
                      divisions: 20,
                                  
                    ),
                  ),
                ),
            
                Text("${ratingRange.end*10}"),
              
              
              ],
            ),
      
      
      
            //TagsList Show
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 55,
              ),
              child: NotificationListener<ScrollUpdateNotification>(
                onNotification: (notification) => true, //捕获冒泡滚动 不要让上层响应
                child: AnimatedList.separated(
                  key: animatedTagsListKey,
                  scrollDirection: Axis.horizontal,
                  initialItemCount: tagsList.length,
                  separatorBuilder: (_,index,animation) => const Padding(padding: EdgeInsets.symmetric(horizontal: 12)),
                  removedSeparatorBuilder: (_, index, animation) => const SizedBox.shrink(),
                  itemBuilder: (listContext,index,animation){

                  if(tagsList.isEmpty) return const SizedBox.shrink();


                   return SlideTransition(
                    position: animation.drive(Tween<Offset>(begin: const Offset(-1, 0),end: Offset.zero)), 
                    // begin/end 是相对于insert状态来说的 如果是remove行为则应该是反向
                     child: FadeTransition(
                      opacity: animation,
                       child: Padding(
                         padding: const EdgeInsets.symmetric(vertical: 5),
                         child: ElevatedButton(
                           onPressed: (){
                         
                            final String recordText = tagsList[index];
                         
                            tagsList.removeAt(index);
                         
                             AnimatedList.of(listContext).removeItem(
                               index,
                               (_,animation){
                                  return FadeTransition(
                                    opacity: animation.drive(Tween<double>(begin: 0,end: 1)),
                                    child: SlideTransition(
                                      position: animation.drive(Tween<Offset>(begin: const Offset(-1, 0),end: Offset.zero)),
                                      child: ElevatedButton(
                                        onPressed: (){},
                                        child: Row(
                                          children: [
                                            Text(recordText),         
                                            const Padding(
                                              padding: EdgeInsets.only(left: 12),
                                              child: Icon(Icons.close),
                                            ),
                                          ],
                                        ),
                                        )
                                    ),
                                  );
                               }
                            );
                           },
                           
                           child: Row(
                             children: [
                               
                              Text(tagsList[index]),
                                             
                               const Padding(
                                 padding: EdgeInsets.only(left: 12),
                                 child: Icon(Icons.close),
                               ),
                             ],
                           ),
                         ),
                       ),
                     ),
                   );
                  }
                ),
              ),
            ),
            
            kDebugMode ? Text("AllData:${searchFliter.toString()}") :const SizedBox.shrink(),
      
            //Submit
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: (){
      
                    bus.emit('sortSubmit',
                      searchFliter['filter'] = {
                        "rank": [
                          ">=${int.tryParse(rankEditingControllerStart.text) ?? 2}",
                          "<${int.tryParse(rankEditingControllerEnd.text) ?? 99999}"
                        ],
                        "rating":[
                          ">=${ratingRange.start*10}",
                          "<${ratingRange.end*10}"
                        ],
                        "air_date": [ //服务器倒是会自动屏蔽无效的air_date 帮大忙了倒是
                          ">=${yearEditingControllerStart.text}-${ monthSelect[0]!= null ? convertDigitNumString(monthSelect.values.first) : '01'}-01",
                          "<=${yearEditingControllerEnd.text}-${monthSelect[0]!= null ? convertDigitNumString(monthSelect.values.last) : '12'}-01",
                        ],
                        "tag": tagsList
                      }
                    );
      
                    setState(() {
                        searchFliter['filter'] = {
                          "rank": [
                            ">=${int.tryParse(rankEditingControllerStart.text) ?? 2}",
                            "<${int.tryParse(rankEditingControllerEnd.text) ?? 99999}"
                          ],
                          "rating":[
                            ">=${ratingRange.start*10}",
                            "<${ratingRange.end*10}"
                          ],
                          "air_date": [ //服务器倒是会自动屏蔽无效的air_date 帮大忙了倒是
                                                      ">=${yearEditingControllerStart.text}-${ monthSelect[0]!= null ? convertDigitNumString(monthSelect.values.first) : '01'}-01",
                          "<=${yearEditingControllerEnd.text}-${monthSelect[0]!= null ? convertDigitNumString(monthSelect.values.last) : '12'}-01",
                          ],
                          "tag": tagsList
                        };
                    });
                    
                  }, child: const Text("submit")
                )
              ]
            ),
       
      
          ],
        ),
      ),
    );
  
  
  }
}
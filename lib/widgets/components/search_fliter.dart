

import 'package:bangu_lite/internal/custom_toaster.dart';
import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bangu_lite/internal/utils/convert.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
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

  final TextEditingController yearEditingControllerStart = TextEditingController(text: "${DateTime.now().year}");
  final TextEditingController yearEditingControllerEnd = TextEditingController(text: "${DateTime.now().year}");

  final TextEditingController tagsEditingController = TextEditingController();

  final TextEditingController rankEditingControllerStart = TextEditingController();
  final TextEditingController rankEditingControllerEnd = TextEditingController();

  final GlobalKey<AnimatedListState> animatedTagsListKey = GlobalKey<AnimatedListState>();

  Map<String,dynamic> searchFliter = BangumiDatas.sortData;
  Map<int,int> monthSelect = {};
  final List<String> tagsList = [];

  bool inputBorderShow = false;

  final ValueNotifier<bool> tagsListEmptyNotifier = ValueNotifier<bool>(false);

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

    judgeDarknessMode(context) ? 
    inputBorderShow = true :
    inputBorderShow = false;

    

    return Theme(
      data: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Theme.of(context).colorScheme.primary,
          brightness: (Theme.of(context).brightness),
          
        ),
        
      ),
      
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
      
            //DateRange
            Row(
              children: [
            
                DateRangeSelect(
                  initMonth: 1,
                  key: const ValueKey("monthStartSelect"),
                  dateRangeEditingController: yearEditingControllerStart
                ),
            
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: ScalableText("~"),
                ),
            
                DateRangeSelect(
                  initMonth: DateTime.now().month,
                  key: const ValueKey("monthEndSelect"),
                  dateRangeEditingController: yearEditingControllerEnd
                ),
            
              ],
            ),
      
            const Divider(height: 1),
            
            //RankRange
            Row(
              children: [
            
                const ScalableText("排名范围:"),
            
                Row(
                  children: [
                              
                    SizedBox(
                      width: 60,
                      child: TextField(
                        controller: rankEditingControllerStart,
                        textAlign: TextAlign.center,
                        decoration:  InputDecoration(
                          border: inputBorderShow ? null : InputBorder.none
                        ),
                      ),
                    ),
                              
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: ScalableText("~"),
                    ),
                              
                              
                    SizedBox(
                      width: 60,
                      child: TextField(
                        controller: rankEditingControllerEnd,
                        textAlign: TextAlign.center,
                        decoration:  InputDecoration(
                          border: inputBorderShow ? null : InputBorder.none
                        ),
                      ),
                    ),
                              
                              
                  ],
                ),
              ],
            ),
      
            const Divider(height: 1),
            
            //TagsList TextField
            Row(
              children: [
                
                const ScalableText("标签:"),
                  
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: SizedBox(
                    width: 150,
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (notification) => true, //禁止通知给上层
                      child: TextField(
                        controller: tagsEditingController,
                        decoration:  InputDecoration(
                          border: inputBorderShow ? null : InputBorder.none
                        ),
                      ),
                    ),
                  ),
                ),
                  
                //细节: label得到的icon是会顺应 colorSchme主题色的
                TextButton.icon(
                  onPressed: (){
      
                    if(tagsEditingController.text.isEmpty) return;
                  
                    tagsList.add(tagsEditingController.text);
                    
                    tagsListEmptyNotifier.value = updateTagsListStatus();
      
                    animatedTagsListKey.currentState?.insertItem(
                      tagsList.isEmpty ? 0 : tagsList.length-1,
                      duration: const Duration(milliseconds: 300)
                    );
                  }, label: const Icon(Icons.upload)
                )
                  
                  
              ],
            ),
            
            const Divider(height: 1),
            
            //RankSlider
            Row(
              children: [
                
                const ScalableText("评分范围:"),
            
                ScalableText("${ratingRange.start*10}"),
      
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
            
                ScalableText("${ratingRange.end*10}"),
              
              
              ],
            ),
      
            //TagsList Show
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: ValueListenableBuilder(
                valueListenable: tagsListEmptyNotifier,
                builder: (_,isEmpty,child) {
                  return SizedBox(
                    height: isEmpty ? 0 : 55,
                    child: NotificationListener<ScrollUpdateNotification>(
                      onNotification: (notification) => true, //捕获冒泡滚动 不要让上层响应
                      child: AnimatedList.separated(
                        key: animatedTagsListKey,
                        scrollDirection: Axis.horizontal,
                        initialItemCount: tagsList.length,
                        separatorBuilder: (_,index,animation) => const Padding(padding: PaddingH12),
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
                                  tagsListEmptyNotifier.value = updateTagsListStatus();
                               
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
                                                  ScalableText(recordText),         
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
                                     
                                    ScalableText(tagsList[index]),
                                                   
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
                  );
                }
              ),
            ),
            
            kDebugMode ? ScalableText("[kDebugMode Show] AllData:${searchFliter.toString()}") : const SizedBox.shrink(),
      
            //Submit
            Row(
              spacing: 12,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
      
                ElevatedButton(
                  onPressed: (){
      
                    fadeToaster(context: context, message: "开始搜索");
      
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
                    
                  }, child: const ScalableText("搜索")
                )
              ]
            ),
       
      
          ],
        ),
      ),
    );
  
  
  }

  bool updateTagsListStatus() => tagsList.isEmpty ? true : false;
}
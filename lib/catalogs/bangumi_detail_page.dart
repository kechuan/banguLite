
import 'package:easy_refresh/easy_refresh.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bangumi/models/bangumi_details.dart';
import 'package:flutter_bangumi/models/providers/bangumi_model.dart';
import 'package:flutter_bangumi/widgets/components/bangumi_detail_intro.dart';
import 'package:flutter_bangumi/widgets/components/bangumi_hot_comment.dart';
import 'package:flutter_bangumi/widgets/components/bangumi_summary.dart';
//import 'package:flutter_bangumi/widgets/components/search_overlay.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

@FFRoute(name: '/subjectDetail')

class BangumiDetailPage extends StatefulWidget {
  const BangumiDetailPage({
    super.key,
    required this.bangumiID
  });

  final int bangumiID;

  @override
  State<BangumiDetailPage> createState() => _BangumiDetailPageState();
}

class _BangumiDetailPageState extends State<BangumiDetailPage> {

  ValueNotifier<String> appbarTitleNotifier = ValueNotifier<String>("");
  BangumiDetails? currentSubjectDetail; //dependence InheritedWidget(Provider). don't turn to stateless.
  ImageProvider? bangumiCover;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 236, 211, 231),
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.8),
        
        title: ValueListenableBuilder(valueListenable: appbarTitleNotifier, builder: (_,appbarTitle,__)=>Text(appbarTitle)),
        leading: IconButton(
          onPressed: (){
            Navigator.of(context).pop();
            //context.read<CommentModel>().resetProp();
    
            //退出时移除ID.
            context.read<BangumiModel>().routesIDList.remove(currentSubjectDetail?.id);
            currentSubjectDetail = null;
    
          }, icon: const Icon(Icons.arrow_back)
        ),
      ),
    
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          final double offset = notification.metrics.pixels; //scrollview 的 offset : 注意不要让更内层的scrollView影响到它监听
          if (offset >= 60) { 
            appbarTitleNotifier.value = currentSubjectDetail?.name ?? "";
            //appbarTitleNotifier.value = currentSubjectDetail?.id.toString() ?? ""; Debug
          }
    
          else{
            appbarTitleNotifier.value = "";
          }
          
          return true;
        },
        
        child: Selector<BangumiModel, int>(
        selector:(_, bangumiModel) => bangumiModel.bangumiID,
        shouldRebuild: (previous, next){
    
          if(next == 0) return false;
    
          final bangumiDetailModel = context.read<BangumiModel>();
    
          if(bangumiDetailModel.routesIDList.contains(bangumiDetailModel.bangumiID)){
            return false;
          }
    
          return previous!=next;
        },
        builder: (_,bangumiID,child) {
      
          debugPrint("BangumiID: ${bangumiID} => ${widget.bangumiID}");
      
          return FutureBuilder(
            future: context.read<BangumiModel>().loadDetails(widget.bangumiID),
            builder: (_,snapshot){
    
              switch(snapshot.connectionState){
                case ConnectionState.done:{
                  if(snapshot.hasData){
                    currentSubjectDetail = snapshot.data;
                  }
    
                  debugPrint("parse done ,builderStamp: ${DateTime.now()}");
      
                }
      
                default: {}
              }
      
              return EasyRefresh.builder(
                header: const MaterialHeader(),
                onRefresh: ()=> context.read<BangumiModel>().loadDetails(bangumiID,refresh:true),
                childBuilder: (_,physic){
                  return SingleChildScrollView(
                    physics: physic,
                    child: Skeletonizer(
                      enabled: currentSubjectDetail==null,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white,
                              Color.fromARGB(183, 236, 211, 231),
                              
                            ]
                          )
                        ),
                        
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
    
                            BangumiDetailIntro(bangumiDetails: currentSubjectDetail ?? BangumiDetails()),
    
                            NotificationListener<ScrollNotification>(
                              onNotification: (_) => true,
                              child: BangumiSummary(summary: currentSubjectDetail?.summary)
                            ),
    
                            NotificationListener<ScrollNotification>(
                              onNotification: (_) => true,
                              child: BangumiHotComment(id: widget.bangumiID) 
                              //内含Future 界面变动的时候 这个也会被rebuild
                              //唯一的办法就是像上面那样 由details创立bangumiModel 只是这样的话就会让原本分割开的 details comment关系又融合进去了
    
                              //不过至少在后端请求数据里做了防rebuild触发的重复处理
                            ),
                            
                          
                          ],
                        ),
                      ),
                    ),
                  );
                }
              );
      
      
            },
            
            
          );
      
        },
      ),
    )
    
      );
      
    
  }
}
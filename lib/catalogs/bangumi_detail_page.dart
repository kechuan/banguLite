
import 'package:bangu_lite/internal/event_bus.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';
import 'package:bangu_lite/models/bangumi_details.dart';
import 'package:bangu_lite/models/providers/bangumi_model.dart';
import 'package:bangu_lite/widgets/components/bangumi_detail_intro.dart';
import 'package:bangu_lite/widgets/components/bangumi_hot_comment.dart';
import 'package:bangu_lite/widgets/components/bangumi_summary.dart';
//import 'package:bangu_lite/widgets/components/search_overlay.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:url_launcher/url_launcher_string.dart';

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
  ValueNotifier<Color> detailImageColorNotifier = ValueNotifier<Color>( const Color.fromARGB(183, 236, 211, 231));

  @override
  void initState() {
    //bus.emit("imageColor",coverScheme.primary);
    bus.on(
      "imageColor",(arg){
        // {ID: imageUrl}
        if(arg is Map<int,Color>){
          if(arg.keys.first == widget.bangumiID){

            Color resultColor = arg.values.first;
            
            debugPrint("[detailPage] ID: ${widget.bangumiID}, Color:$resultColor, Lumi:${resultColor.computeLuminance()}");

            if(resultColor.computeLuminance()<0.5){
              HSLColor hslColor = HSLColor.fromColor(resultColor); //亮度过低 转换HSL色度
              double newLightness = (hslColor.lightness + 0.3).clamp(0.8, 1.0); // 确保不超过 1.0

              double newSaturation = (hslColor.saturation - 0.1).clamp(0.2, 0.4); //偏透明色
              HSLColor newHSLColor = hslColor.withLightness(newLightness).withSaturation(newSaturation);

              resultColor = newHSLColor.toColor();

              debugPrint("result Color:$resultColor,Lumi:${resultColor.computeLuminance()}");

              detailImageColorNotifier.value = resultColor;

            }

            else{
              detailImageColorNotifier.value = arg.values.first;
            }

            
          }
        }
      }
    );
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: detailImageColorNotifier,
      builder: (_,linearColor,detailScaffold) {
        return Theme(
          data: ThemeData(
            primaryColor: linearColor,
            scaffoldBackgroundColor: linearColor,
            fontFamily: 'MiSansFont',
          ),
          child:detailScaffold!,
        );
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.6),
          
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
          actions: [
            IconButton(
              onPressed: () async {
                if(await canLaunchUrlString("https://bgm.tv/subject/${widget.bangumiID}")){
                  await launchUrlString("https://bgm.tv/subject/${widget.bangumiID}");
                }
              },
              icon: Transform.rotate(
                angle: -45,
                child: const Icon(Icons.link),
              )
            )
          ],
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
            
            return false;
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
        
            debugPrint("BangumiID: $bangumiID => ${widget.bangumiID}");
        
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
                        child: ValueListenableBuilder(
                          valueListenable: detailImageColorNotifier,
                          builder: (_,linearColor,child) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              padding: const EdgeInsets.all(16),
                              decoration:  BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.white,
                                    //Color.fromARGB(255, 209, 220, 233)
                                    linearColor,
                                  ]
                                )
                              ),
                              child: child!
                              );
                          },
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
      
            )
        
    );
      
    
  }
}
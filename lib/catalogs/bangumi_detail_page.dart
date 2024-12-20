
import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/providers/comment_model.dart';
import 'package:bangu_lite/models/providers/ep_model.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:bangu_lite/widgets/fragments/toggle_theme_mode_button.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';
import 'package:bangu_lite/models/bangumi_details.dart';
import 'package:bangu_lite/models/providers/bangumi_model.dart';
import 'package:bangu_lite/widgets/components/bangumi_detail_intro.dart';
import 'package:bangu_lite/widgets/components/bangumi_hot_comment.dart';
import 'package:bangu_lite/widgets/components/bangumi_summary.dart';
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



//class _BangumiDetailPageState extends State<BangumiDetailPage> {
class _BangumiDetailPageState extends State<BangumiDetailPage> {

  //bool isPaused = false;
  ValueNotifier<String> appbarTitleNotifier = ValueNotifier<String>("");
 

  //@override
  //void didPushNext() {
  //  isPaused = true;
  //  super.didPushNext();
  //}

  
  //@override
  //void didPopNext() {
  //  isPaused = false;
  //  super.didPopNext();
  //}

  @override
  Widget build(BuildContext context) {

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BangumiModel()),
        ChangeNotifierProvider(create: (_) => EpModel(subjectID: widget.bangumiID,selectedEp: 1)),
        ChangeNotifierProvider(create: (_) => CommentModel())
      ],
      //create: (_) => BangumiModel(),
      child: Selector<BangumiModel,Color?>(
        selector: (_, bangumiModel) => bangumiModel.bangumiThemeColor,
        shouldRebuild: (previous, next) => previous!=next,
        
        builder: (_,linearColor,detailScaffold) {
          debugPrint("linear color:$linearColor");
          return Theme(
            data: ThemeData(
              brightness: Theme.of(context).brightness,
              primaryColor: linearColor,
              scaffoldBackgroundColor: linearColor,
              fontFamily: 'MiSansFont',
            ),
            child:detailScaffold!,
          );
        },
        child: Builder(
          builder: (context) {

            final BangumiModel bangumiModel = context.read<BangumiModel>();
            final IndexModel indexModel = context.read<IndexModel>();

            return Scaffold(
              appBar: AppBar(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor.withValues(alpha:0.6),
                
                title: ValueListenableBuilder(valueListenable: appbarTitleNotifier, builder: (_,appbarTitle,__)=>Text(appbarTitle,style: const TextStyle(color: Colors.black),)),
                leading: IconButton(
                  onPressed: ()=>Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back)
                ),
                actions: [
                  //const ToggleThemeModeButton(),
                  ToggleThemeModeButton(
                    onThen: (){
                      //debugPrint("trigged onThen");
                      bangumiModel.getThemeColor(bangumiModel.imageColor ?? BangumiThemeColor.sea.color,darkMode: indexModel.themeMode == ThemeMode.dark);
                    }
                  ),

                  const Padding(padding: PaddingH6),

                  IconButton(
                    onPressed: () async {
                      if(await canLaunchUrlString(BangumiWebUrls.subject(widget.bangumiID))){
                        await launchUrlString(BangumiWebUrls.subject(widget.bangumiID));
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
                  //final bangumiModel = context.read<BangumiModel>();
                  BangumiDetails? currentSubjectDetail = bangumiModel.bangumiDetails; //dependenc
                  
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
                
                child: Selector<BangumiModel, int?>(
                    selector:(_, bangumiModel) => bangumiModel.bangumiID,
                      shouldRebuild: (previous, next){
                        if(next == null) return false;
                        return previous!=next;
                      },
                      builder: (_,bangumiID,child) {
                  
                        //final bangumiModel = context.read<BangumiModel>();
                    
                        debugPrint("BangumiID: $bangumiID => ${widget.bangumiID}");
                    
                        return FutureBuilder(
                          future: bangumiModel.loadDetails(widget.bangumiID),
                          builder: (_,snapshot){

                            if(snapshot.connectionState == ConnectionState.done){
                              debugPrint("parse ${widget.bangumiID} done ,builderStamp: ${DateTime.now()}");
                            }
                    
                            return EasyRefresh.builder(
                              header: const MaterialHeader(),
                              onRefresh: ()=> bangumiModel.loadDetails(bangumiID,refresh:true),
                              childBuilder: (_,physic){
                  
                                
                                BangumiDetails? currentSubjectDetail = bangumiModel.bangumiDetails; //dependenc
                  
                                return CustomScrollView(
                                  slivers: [
                                    Skeletonizer.sliver(
                                      enabled: currentSubjectDetail==null,
                                      child: 
                                      
                                      
                                      Selector<BangumiModel,Color?>(
                                        selector: (_, bangumiModel) => bangumiModel.bangumiThemeColor,
                                        //selector: (_, bangumiModel) => judgeDarknessMode(context) ? bangumiModel.getThemeColor(context,darkMode: true) : bangumiModel.bangumiThemeColor ,
                                        shouldRebuild: (previous, next) => previous!=next,
                                        builder: (_,linearColor,detailChild) {

                                          return TweenAnimationBuilder<Color?>(
                                            tween: ColorTween(
                                              begin: BangumiThemeColor.sea.color,
                                              //end: linearColor ?? Colors.white,
                                              //begin: Theme.of(context).brightness == Brightness.dark ? Colors.black : const BangumiThemeColor.sea.color,
                                              end: Theme.of(context).brightness == Brightness.dark ? Colors.black : linearColor ?? Colors.white,
                                            ),
                                            duration: const Duration(milliseconds: 500),
                                            builder: (_, linearColor, __) {

                                              return DecoratedSliver(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [
                                                      Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                                                      linearColor!,
                                                    ]
                                                  )
                                                ),
                                                sliver: detailChild,
                                                
                                              );

                                             

                                             
                                            },
                                            
                                            
                                          );

                                        },
                                        child: SliverPadding(
                                          padding: const EdgeInsets.all(16),
                                          sliver: SliverList(
                                            delegate: SliverChildListDelegate(
                                              [
                                                BangumiDetailIntro(bangumiDetails: currentSubjectDetail ?? BangumiDetails()),
                                              
                                                NotificationListener<ScrollNotification>(
                                                  onNotification: (_) => true,
                                                  child: BangumiSummary(summary: currentSubjectDetail?.summary)
                                                ),
                                                
                                                NotificationListener<ScrollNotification>(
                                                  onNotification: (_) => true,
                                                  child: BangumiHotComment(id: widget.bangumiID,name: bangumiModel.bangumiDetails?.name,) 
                                                ),
                                              ]
                                            )
                                          ),
                                        )
                                        
                                       
                                            
                                      ),
                                                      
                                    ),
                                  ],
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
        )
          
      ),
    );
      
    
  }


}
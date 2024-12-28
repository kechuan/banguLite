
import 'dart:math';
import 'package:bangu_lite/internal/bus_register_method.dart';
import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/event_bus.dart';
import 'package:bangu_lite/internal/lifecycle.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/eps_info.dart';

@FFAutoImport()
import 'package:bangu_lite/models/providers/ep_model.dart';

import 'package:bangu_lite/widgets/components/ep_comments.dart';
import 'package:bangu_lite/widgets/fragments/ep_comments_progress_slider.dart';
import 'package:bangu_lite/widgets/fragments/ep_toggle_panel.dart';
import 'package:bangu_lite/widgets/fragments/skeleton_tile_template.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:url_launcher/url_launcher_string.dart';


@FFRoute(name: '/subjectEp')

class BangumiEpPage extends StatefulWidget {
  const BangumiEpPage({
    super.key,
    required this.epModel,
    required this.totalEps
  });

  final EpModel epModel;
  final int totalEps;

  //final Set<GlobalKey> epCommentGlobalKeySet = {};

  @override
  State<BangumiEpPage> createState() => _BangumiEpPageState();
}

class _BangumiEpPageState extends LifecycleRouteState<BangumiEpPage> {

  Future<void>? epsInformationFuture;
  //ValueNotifier<double> opacityNotifier = ValueNotifier<double>(0);
  ValueNotifier<double> offsetNotifier = ValueNotifier<double>(0);

  final ScrollController scrollViewController = ScrollController();

  bool isActived = true; 

  final GlobalKey sliverListKey = GlobalKey();
  final GlobalKey epInfoKey = GlobalKey();


  final List<double> itemOffsets = [];
  
  //在极端状况之下 说不定会出现 (BangumiDetailPageA)EpPage => BangumiDetailPageB => EpPageB...
  //此时 整个路由链存活的 EpPageState 都会触发这个 AppRoute 那就麻烦了, 因此需要加以管控

  @override
  void initState() {
    bus.on(
      'AppRoute',
      (link) {
        if(!isActived) return;
        appRouteMethod(context,link);

      }
    );
    super.initState();
  }

  @override
  void didPushNext() {
    isActived = false;
    super.didPushNext();
  }

  @override
  void didPopNext() {
    isActived = true;
    super.didPopNext();
  }

  @override
  Widget build(BuildContext context) {

   
    return ChangeNotifierProvider.value(
      value: widget.epModel,
      builder: (context,child){

        final epModel = widget.epModel;


        epsInformationFuture ??= epModel.getEpsInformation(offset: epModel.selectedEp~/100 );

        return EasyRefresh.builder(
          header: const MaterialHeader(),

          childBuilder: (_,physics) {
            
            return Scaffold( //Listview need materialDesign

              body: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                    //final double notificationOffset = notification.metrics.pixels; //scrollview 的 offset : 注意不要让更内层的scrollView影响到它监听
                  
                    
                    WidgetsBinding.instance.addPostFrameCallback((timeStamp){
                      //offsetNotifier.value = max(notificationOffset - ((epInfoKey.currentContext?.size!.height ?? 300)+120),0);
                      offsetNotifier.value = notification.metrics.pixels;

                      //debugPrint("notification offset:$notificationOffset, epInfoKey height:${epInfoKey.currentContext?.size!.height}, offsetNotifier:${offsetNotifier.value}");
                      //target 404:start

                    });
                  
                    return false;
                },
                  child: Selector<EpModel,int>(
                    selector: (_, epModel) => epModel.selectedEp,
                    shouldRebuild: (previous, next) => previous != next,
                    builder: (_,selectedEp,commentDetailchild){

                      double sliverViewStartOffset = 0;
                      double opacityDegree = 0;
                      double commentProgress = 0.0;
                
                      return Padding(
                        padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + 20),
                        child: CustomScrollView(
                          controller: scrollViewController,
                          physics:physics,
                          slivers: [
                                      
                            MultiSliver(
                              pushPinnedChildren: true,
                              children: [
                          
                                SliverPinnedHeader(
                                  child: AppBar(
                                    title: Text("第$selectedEp集 ${epModel.epsData[selectedEp]!.nameCN}"),
                                    //backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha:0.6) keep,
                                    backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha:0.6),
                          
                                    actions: [

                                      IconButton(
                                        onPressed: () async {

                                          final RenderSliver? epCommentSliver = sliverListKey.currentContext?.findRenderObject() as RenderSliver? ;

                                          final RenderBox? epInfoBox = epInfoKey.currentContext?.findRenderObject() as RenderBox?;


                                          if(epCommentSliver !=null && epInfoBox != null){

                                            double resultOffset = 
                                            
                                              0.45*(scrollViewController.position.maxScrollExtent) - (AppBar().preferredSize.height + epInfoBox.size.height)
                                            ;

                                            debugPrint("epCommentSliver: ${epCommentSliver.geometry?.scrollExtent}/${scrollViewController.position.maxScrollExtent} epInfoBox:${epInfoBox.size.height}, result:$resultOffset");

                                            scrollViewController.animateTo(
                                              resultOffset,
                                              duration: const Duration(milliseconds: 300),
                                              curve: Curves.fastLinearToSlowEaseIn
                                            ).then((value){
                                              debugPrint("epCommentSliver current Offset:${scrollViewController.offset}/${scrollViewController.position.maxScrollExtent}");
                                            });


                                            
                                          }

                                          
                                        },
                                        icon: const Icon(Icons.wrap_text),
                                      ),
                          
                                      IconButton(
                                        onPressed: () => debugPrint("epCommentSliver current Offset:${scrollViewController.offset}/${scrollViewController.position.maxScrollExtent}"),
                                        icon: const Icon(Icons.record_voice_over),
                                      ),
                          

                                      IconButton(
                                        onPressed: () async {
                                          if(await canLaunchUrlString(BangumiWebUrls.ep(epModel.epsData[epModel.selectedEp]!.epID!))){
                                          await launchUrlString(BangumiWebUrls.ep(epModel.epsData[epModel.selectedEp]!.epID!));
                                          }
                                        },
                                        icon: Transform.rotate(
                                          angle: -45,
                                          child: const Icon(Icons.link),
                                        )
                                      ),
                          
                          
                                    ],
                                  )
                                  
                                  
                          
                                ),
                                
                          
                                EpInfo(
                                  key: epInfoKey,
                                  epsInfo: epModel.epsData,selectedEp: selectedEp
                                ),
                              ],
                            ),
                          
                            MultiSliver(
                              pushPinnedChildren: true,
                              children: [
                          
                                SliverPinnedHeader(
                                  
                                  
                                    child: ValueListenableBuilder(
                                      valueListenable: offsetNotifier,
                                      builder: (_,offset,child) {

                                        WidgetsBinding.instance.addPostFrameCallback((timeStamp){
                                          sliverViewStartOffset = (epInfoKey.currentContext?.size!.height ?? 300)+120;
                                          opacityDegree = min(0.8,offset/sliverViewStartOffset);
                                          debugPrint("opacity: $offset / $sliverViewStartOffset");
                                        });

                                       
                                        return FutureBuilder(
                                          future: epsInformationFuture,
                                          builder: (_,snapshot){

                                            WidgetsBinding.instance.addPostFrameCallback((_){
                                              commentProgress = ((offset-sliverViewStartOffset)/(scrollViewController.position.maxScrollExtent - sliverViewStartOffset)).clamp(0, 1);
                                            });


                                            return AnimatedSize(
                                              duration: const Duration(milliseconds: 300),
                                              child:ColoredBox(
                                                color: BangumiThemeColor.sea.color.withValues(alpha:opacityDegree),
                                                child: SizedBox(
                                                  height: opacityDegree == 0.8 ? 120 : 60,
                                                  child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                
                                                
                                                    SizedBox(
                                                      height: 60,
                                                      child: EpTogglePanel(currentEp: selectedEp,totalEps: widget.totalEps)
                                                    ),
                                                
                                                
                                                    AnimatedSize(
                                                      duration: const Duration(milliseconds: 300),
                                                      child: SizedBox(
                                                          height: opacityDegree == 0.8 ? 60 : 0,
                                                          child: EpCommentsProgressSlider(
                                                            commnetProgress: commentProgress,
                                                            offstage: opacityDegree == 0.8 ? false : true,
                                                            onChanged: (progress){
                                                              scrollViewController.jumpTo(progress*(scrollViewController.position.maxScrollExtent - sliverViewStartOffset) + sliverViewStartOffset);
                                                              debugPrint("maxScrollExtent:${scrollViewController.position.maxScrollExtent}");
                                                            }
                                                          ),
                                                      
                                                      )
                                                    ),
                                                      
                                                
                                                  ],
                                                ),
                                                
                                                ),
                                              )
                   

                                            );
                                          
                                          }
                                        );
                                      }
                                    )
                                    
                                  ),

                          
                                commentDetailchild!
                              ],
                            ),
                                      
                          ],	
                        ),
                      );
                      
                    },

                    child: EpCommentPageDetails(sliverKey: sliverListKey)
              
                  )

              )
            );
          }

        );
      },
    );
    
  }

  //double getItemOffset(int index) {
  //    if (index < 0 || index >= widget.epCommentGlobalKeySet.length) return 0;
      
  //    try {
  //      final context = widget.epCommentGlobalKeySet.elementAt(index).currentContext;
  //      if (context == null) return 0;
        
  //      // 获取RenderBox
  //      final RenderBox box = context.findRenderObject() as RenderBox;
  //      // 转换为全局坐标
  //      final position = box.localToGlobal(Offset.zero);
        
  //      // 计算相对于ScrollView的offset
  //      // 需要减去AppBar和其他固定位置组件的高度
  //      final topPadding = MediaQuery.of(context).padding.top;
  //      final appBarHeight = AppBar().preferredSize.height;
  //      debugPrint("measure offset:${position.dy - topPadding - appBarHeight}");
  //      return position.dy - topPadding - appBarHeight;
  //    } 
    
  //    catch (e) {
  //      debugPrint('Error measuring offset: $e');
  //      return 0;
  //    }
  //  }

}

class EpInfo extends StatelessWidget {
  
  const EpInfo({
    super.key,
    required this.epsInfo,
    required this.selectedEp,
  });

  final Map<int,EpsInfo> epsInfo;
  final int selectedEp;


  @override
  Widget build(BuildContext context) {

    if(epsInfo.isEmpty){
      return const Skeletonizer(
        child: SkeletonListTileTemplate()
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
    
        ListTile(
          title: Row(
            children: [
              Text("${epsInfo[selectedEp]!.nameCN ?? epsInfo[selectedEp]!.name}"),
              const Padding(padding: PaddingH6),
              Text("${epsInfo[selectedEp]!.airDate}",style: const TextStyle(fontSize: 14,color: Colors.grey)),
            ],
          ),
          
        ),
    
        ListTile(
          title:  SelectableText("${epsInfo[selectedEp]!.description}"),
        ),
    
       
      ],
    );
  }
}

class EpCommentPageDetails extends StatelessWidget {
	const EpCommentPageDetails({
		super.key,
    this.sliverKey,
    
	});

  final GlobalKey? sliverKey;

	@override
	Widget build(BuildContext context) {

    final GlobalKey? sliverListKey = sliverKey;

		return Selector<EpModel,List?>(
			selector: (_, epModel) => epModel.epCommentData[epModel.selectedEp],
			shouldRebuild: (previous, next)=> previous!=next,
			
			builder: (_,currentEpCommentData,child){
				
				return FutureBuilder(
					future: context.read<EpModel>().loadEp(),
					builder: (_,snapshot) {

						final epModel = context.read<EpModel>();
						int currentEp = epModel.selectedEp;
				
						debugPrint("currentEp:$currentEp");

						bool isCommentLoading = epModel.epCommentData[currentEp] == null || epModel.epCommentData[currentEp]!.isEmpty;

						return Skeletonizer.sliver(
							enabled: isCommentLoading,
							child: SliverList.separated(
                  key: sliverListKey,
                  
                  itemCount: isCommentLoading ? 3 : epModel.epCommentData[currentEp]!.length+1,
                  itemBuilder: (_,epCommentIndex){
                    //Loading...
                    if(isCommentLoading){
                      return const SkeletonListTileTemplate(scaleType: ScaleType.medium);
                    }

                    if(epCommentIndex == 0){
                      int commentCount = 0;

                      if(epModel.epCommentData[epModel.selectedEp]![0].userId != 0){
                        commentCount = epModel.epCommentData[epModel.selectedEp]!.length;
                      }

                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Text("吐槽箱",style: TextStyle(fontSize: 24)),
                                      
                            const Padding(padding: PaddingH6),
                                      
                            Text("$commentCount",style: const TextStyle(color: Colors.grey)),

                            //BBCode测试
                            //BBCodeText(
                            //  //data: "[img=36]这是一个测试[/img] [color=#FF0000]这是另一个测试[/color]", 
                            //  //data: "[img]https://p.sda1.dev/19/c25b1394330e0a0da6f140ececce3015/1dec650d1b1ee1a139ea09f81246d53d.png[/img]",
                            //  data: "[img]https://i.yusa.me/RwiYjbYD7yGL.webp[/img]",
                              
                            //  stylesheet: BBStylesheet(
                            //    tags: [
                            //      SizeTag(),
                            //      ColorTag(),
                            //      LateLoadImgTag()
                            //    ]
                            //  ),
                            //)

                          ],
                        ),
                      );
                    }
                  
                    //无评论的显示状态
                    if(epModel.epCommentData[currentEp]![0].userId == 0){
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top:64),
                          child: Text("该集数暂无人评论...",style: TextStyle(fontSize: 16)),
                        ),
                      );
                    }

                    return EpCommentView(
                      epCommentData: epModel.epCommentData[currentEp]![epCommentIndex-1]
                    );
                  },
                  separatorBuilder: (_,__,) => const Divider(height: 1), 
                ),
              

            );

					}
				);
			}
		);
	}
}


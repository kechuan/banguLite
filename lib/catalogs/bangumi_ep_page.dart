
import 'dart:math';

import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/eps_info.dart';

@FFAutoImport()
import 'package:bangu_lite/models/providers/ep_model.dart';

import 'package:bangu_lite/widgets/components/ep_comments.dart';
import 'package:bangu_lite/widgets/fragments/ep_toggle_panel.dart';
import 'package:bangu_lite/widgets/fragments/skeleton_tile_template.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';

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

  @override
  State<BangumiEpPage> createState() => _BangumiEpPageState();
}

class _BangumiEpPageState extends State<BangumiEpPage> {

  Future<void>? epsInformationFuture;

  ValueNotifier<double> opacityNotifier = ValueNotifier<double>(0);

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
                    final double offset = notification.metrics.pixels; //scrollview 的 offset : 注意不要让更内层的scrollView影响到它监听

                    double opacityDegree = min(0.8,offset/300);
                  
                    //debugPrint("opacityDegree: $opacityDegree");
                    WidgetsBinding.instance.addPostFrameCallback((timeStamp){
                      opacityNotifier.value = opacityDegree;
                    });
                  
                    return false;
                },
                child:                       Selector<EpModel,int>(
                        selector: (_, epModel) => epModel.selectedEp,
                        shouldRebuild: (previous, next) => previous != next,
                        builder: (_,selectedEp,commentDetailchild){
                    
                          return CustomScrollView(
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
                                  
      
                                  EpInfo(epsInfo: epModel.epsData,selectedEp: selectedEp),
                                ],
                              ),
      
                              MultiSliver(
                                pushPinnedChildren: true,
                                children: [
      
                                  SliverPinnedHeader(
                                    
                                    
                                      child: ValueListenableBuilder(
                                        valueListenable: opacityNotifier,
                                        builder: (_,opacity,child) {
                                          debugPrint("opacity: $opacity");
                                          return FutureBuilder(
                                            future: epsInformationFuture,
                                            builder: (_,snapshot){
                                              return AppBar(
												                        scrolledUnderElevation: 0, // 设置为0来禁用滚动时的阴影效果
                                                leading: const SizedBox.shrink(),
                                                leadingWidth: 0,
											                        	backgroundColor: BangumiThemeColor.sea.color.withValues(alpha:opacity),
                                                titleTextStyle: const TextStyle(fontSize: 16),
                                                title: EpTogglePanel(currentEp: selectedEp,totalEps: widget.totalEps)
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
                          );
                          
                        },
                        
                        child: const EpCommentPageDetails()
                  
                      )

              )
            );
          }

        );
      },
    );
    
  }
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
	});


	@override
	Widget build(BuildContext context) {

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
								itemCount: isCommentLoading ? 3 : epModel.epCommentData[currentEp]!.length+1,
								itemBuilder: (_,epCommentIndex){
									//Loading...
									if(isCommentLoading){
										return const SkeletonListTileTemplate();
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
									
								
									return EpCommentView(epCommentData: epModel.epCommentData[currentEp]![epCommentIndex-1]);
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


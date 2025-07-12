
import 'dart:math';
import 'package:bangu_lite/internal/bangumi_define/bangumi_social_hub.dart';
import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/custom_bbcode_tag.dart';
import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/internal/utils/convert.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/internal/lifecycle.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/informations/subjects/comment_details.dart';
import 'package:bangu_lite/models/informations/subjects/eps_info.dart';

@FFAutoImport()
import 'package:bangu_lite/models/providers/ep_model.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:bangu_lite/widgets/components/custom_bbcode_text.dart';
import 'package:bangu_lite/widgets/fragments/bangumi_content_appbar.dart';
import 'package:bangu_lite/widgets/fragments/comment_filter.dart';
import 'package:bangu_lite/widgets/components/general_replied_line.dart';
import 'package:bangu_lite/widgets/fragments/error_load_prompt.dart';

import 'package:bangu_lite/widgets/views/ep_comments_view.dart';
import 'package:bangu_lite/widgets/fragments/ep_comments_progress_slider.dart';
import 'package:bangu_lite/widgets/fragments/ep_toggle_panel.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/fragments/skeleton_tile_template.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sliver_tools/sliver_tools.dart';


@FFRoute(name: '/subjectEp')
class BangumiEpPage extends StatefulWidget {
  const BangumiEpPage({
    super.key,
    required this.epModel,
    this.bangumiThemeColor,
    this.referPostContentID
  });

  final EpModel epModel;
  final Color? bangumiThemeColor;
  final int? referPostContentID;


  @override
  State<BangumiEpPage> createState() => _BangumiEpPageState();
}

class _BangumiEpPageState extends LifecycleRouteState<BangumiEpPage> with RouteLifecycleMixin {

  Future<void>? epsInformationFuture;
  ValueNotifier<double> offsetNotifier = ValueNotifier<double>(0);

  final ScrollController scrollViewController = ScrollController();

  final GlobalKey sliverListKey = GlobalKey();
  final GlobalKey epInfoKey = GlobalKey();

  final List<double> itemOffsets = [];

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
            
            return Theme(
              data: ThemeData(
                brightness: Theme.of(context).brightness,
                colorSchemeSeed: judgeDetailRenderColor(context,widget.bangumiThemeColor),
                fontFamilyFallback: convertSystemFontFamily(),
              ),
              child: Scaffold( //Listview need materialDesign
              
                body: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    WidgetsBinding.instance.addPostFrameCallback((_)=>offsetNotifier.value = notification.metrics.pixels);
                    return false;
                  },
                  child: Selector<EpModel,num>(
                      selector: (_, epModel) => epModel.selectedEp,
                      shouldRebuild: (previous, next) => previous != next,
                      builder: (_,selectedEp,commentDetailchild){
              
                        double sliverViewStartOffset = 0;
                        double opacityDegree = 0;
                        double commentProgress = 0.0;
                  
                        return Padding(
                          padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
              
                              Positioned.fill(
                                child: CustomScrollView(
                                  controller: scrollViewController,
                                  physics: physics,
                                  slivers: [
                                              
                                    Selector<EpModel,EpsInfo?>(
                                      selector: (_, epModel) => epModel.epsData[epModel.selectedEp],
                                      shouldRebuild: (previous, next)=> previous!=next,
                                      builder: (_,currentEpInfoData,child){
                                        return MultiSliver(
                                          pushPinnedChildren: true,
                                          children: [
                                                                          
                                            SliverPinnedHeader(
                                              child: SafeArea(
                                                bottom: false,
                                                child: buildEpAppBar(currentEpInfoData,selectedEp)
                                              ),
                                            ),
                                            
                                                                          
                                            EpInfo(
                                              key: epInfoKey,
                                              epsInfo: epModel.epsData,selectedEp: selectedEp
                                            ),
                                            
                                          ],
                                        );
                                      }
                                    ),
                                  
                                    MultiSliver(
                                      pushPinnedChildren: true,
                                      children: [
                                  
                                        SliverPinnedHeader(
                                          child: ValueListenableBuilder(
                                            valueListenable: offsetNotifier,
                                            builder: (_,offset,child) {
                                                              
                                              WidgetsBinding.instance.addPostFrameCallback((timeStamp){
                                              
                                                //epInfo范围的总高度 => [120: Appbar+epPanel 高度]
                                                sliverViewStartOffset = (epInfoKey.currentContext?.size?.height ?? 300)+(2*kToolbarHeight); //120
                                              
                                                //越过epInfo时开始激活
                                                opacityDegree = min(0.8,offset/sliverViewStartOffset);
                                              
                                                //剔除 sliverViewStartOffset 的高度进行计算 
                                                commentProgress = ((offset-sliverViewStartOffset)/(scrollViewController.position.maxScrollExtent - sliverViewStartOffset)).clamp(0, 1);
                                                //debugPrint("opacity: $offset / $sliverViewStartOffset");
                                              });
                                                              
                                              
                                              return FutureBuilder(
                                                future: epsInformationFuture,
                                                builder: (_,snapshot){
                                              
                                                  final indexModel = context.read<IndexModel>();
                                              
                                                  return Padding(
                                                    padding: EdgeInsets.only(top:MediaQuery.paddingOf(context).top),
                                                    child: AnimatedContainer(
                                                      duration: const Duration(milliseconds: 300),
                                                      color: indexModel.userConfig.currentThemeColor!.color.withValues(alpha:opacityDegree),
                                                      height: opacityDegree == 0.8 ? 120 : 60,
                                                      child:Column(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: [
                                                                                                            
                                                        Selector<EpModel,EpsInfo?>(
                                                          selector: (_, epModel) => epModel.epsData[epModel.selectedEp],
                                                          shouldRebuild: (previous, next)=> previous!=next,
                                                          builder: (_,currentEpInfoData,child){
                                                            return SizedBox(
                                                              height: 60,
                                                              child: EpTogglePanel(currentEp: selectedEp,totalEps: epModel.epsData.length)
                                                            );
                                                          }
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
                                                                commentProgress = progress;
                                                                debugPrint("maxScrollExtent:${scrollViewController.position.maxScrollExtent}");
                                                              }
                                                            ),
                                                          
                                                          )
                                                        ),
                                                          
                                                                                                            
                                                      ],
                                                                                                            )
                                                    
                                                                                
                                                    ),
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
                              ),
              
                              ValueListenableBuilder(
                                valueListenable: offsetNotifier,
                                builder: (_,offset,appbar) {
                                  return AnimatedPositioned(
                                    duration: const Duration(milliseconds: 300),
                                    bottom: offset <= sliverViewStartOffset ? -60 : 0,
                                    height: 60,
                                    width: MediaQuery.sizeOf(context).width,
                                    child: appbar!
                                  );
                                },
                                child:Selector<EpModel,EpsInfo?>(
                                  selector: (_, epModel) => epModel.epsData[epModel.selectedEp],
                                  shouldRebuild: (previous, next)=> previous!=next,
                                  builder: (_,currentEpInfoData,child){
                                    return buildEpAppBar(currentEpInfoData,selectedEp);
                                  }
                                ),
                                
                              ),
              
              
                            ],
                          ),
                        );
                        
                      },
              
                      child: EpCommentPageDetails(sliverListKey: sliverListKey)
                
                    )
              
                )
              ),
            );
          }

        );
      },
    );
    
  }

  Widget buildEpAppBar(EpsInfo? currentEpInfoData,num selectedEp){
    return BangumiContentAppbar(
      contentID: currentEpInfoData?.epID,
      titleText: convertCollectionName(currentEpInfoData, selectedEp),
      webUrl: BangumiWebUrls.ep(currentEpInfoData?.epID ?? 0),
      postCommentType: PostCommentType.replyEpComment,
      surfaceColor: Theme.of(context).colorScheme.surface.withValues(alpha:0.6)
    );
  }

}

class EpInfo extends StatelessWidget {
  
  const EpInfo({
    super.key,
    required this.epsInfo,
    required this.selectedEp,
  });

  final Map<num,EpsInfo> epsInfo;
  final num selectedEp;


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
          title: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            children: [
              ScalableText("${epsInfo[selectedEp]?.nameCN ?? epsInfo[selectedEp]?.name}"),
              ScalableText("${epsInfo[selectedEp]?.airDate}",style: const TextStyle(fontSize: 14,color: Colors.grey)),
            ],
          ),
          
        ),

        Padding(
          padding: Padding12,
          child: AdapterBBCodeText(
            data: epsInfo[selectedEp]?.description ?? "",
            stylesheet: appDefaultStyleSheet(context,selectableText: true),
          ),
        )
     
      ],
    );
  }
}

class EpCommentPageDetails extends StatefulWidget {
	const EpCommentPageDetails({
		super.key,
    this.sliverListKey,
    
	});

  final GlobalKey? sliverListKey;

  @override
  State<EpCommentPageDetails> createState() => _EpCommentPageDetailsState();
}

class _EpCommentPageDetailsState extends State<EpCommentPageDetails> {

  final ValueNotifier<BangumiCommentRelatedType> commentSurfTypeNotifier = ValueNotifier(BangumiCommentRelatedType.normal);

  List<EpCommentDetails> resultFilterCommentList = [];
  bool isInitaled = false;

  Future? epCommentFuture;

	@override
	Widget build(BuildContext context) {

    

		return Selector<EpModel,List?>(
			selector: (_, epModel) => epModel.epCommentData[epModel.selectedEp],
			shouldRebuild: (previous, next)=> previous!=next,
			
			builder: (_,currentEpCommentData,child){

        final epModel = context.read<EpModel>();

        epCommentFuture ??= epModel.loadEpComment();
				
				return FutureBuilder(
					future: epCommentFuture,
					builder: (_,snapshot) {

            if(snapshot.hasError){

              return Center(
                child: ErrorLoadPrompt(
                  message: snapshot.error,
                  onRetryAction: (){
                    epCommentFuture = epModel.loadEpComment();
                  },
                ),
              );
            }

						num currentEp = epModel.selectedEp;
						//debugPrint("currentEp:$currentEp");

						bool isCommentLoading = epModel.epCommentData[currentEp] == null || epModel.epCommentData[currentEp]!.isEmpty;

						return SliverPadding(
              padding: const EdgeInsets.only(bottom: 50),
              sliver: Skeletonizer.sliver(
                enabled: isCommentLoading,
                child: ValueListenableBuilder(
                  valueListenable: commentSurfTypeNotifier,
                  builder: (_, commentSurfType, __) {

                    final originalCommentList = epModel.epCommentData[currentEp]!;

                    if(!isInitaled){

                      if(epModel.epCommentData[currentEp]?.isNotEmpty == true){
                        if(epModel.epCommentData[currentEp]?.first.epCommentIndex == "1"){
                          resultFilterCommentList = [...originalCommentList];
                        }

                        isInitaled = true;
                      }
                    }

                    return SliverList.separated(
                      key: widget.sliverListKey,
                      itemCount: isCommentLoading ? 3 : resultFilterCommentList.length+1,
                      itemBuilder: (_,epCommentIndex){
                        //Loading...
                        if(isCommentLoading){
                          return const SkeletonListTileTemplate(scaleType: ScaleType.medium);
                        }
                    
                        if(epCommentIndex == 0){
                          int commentCount = 0;
                    
                          if(epModel.epCommentData[epModel.selectedEp]![0].userInformation?.userID != 0){
                            commentCount = resultFilterCommentList.length;
                          }

                          return GeneralRepliedLine(
                            repliedCount: commentCount,
                            commentFilterTypeNotifier: commentSurfTypeNotifier,
                            onCommentFilter: (selectFilter) {
                              resultFilterCommentList = filterCommentList(selectFilter,originalCommentList);
                            },
                          );
                    
                          
                        }
                      
                        //无评论的显示状态
                        if(originalCommentList.first == EpCommentDetails.empty()){
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top:64),
                              child: ScalableText("该集数暂无人评论..."),
                            ),
                          );
                        }
                    
                        return EpCommentView(
                          contentID: epModel.injectEpID != 0 ? epModel.injectEpID : (epModel.epsData[epModel.selectedEp]?.epID ?? 0) ,
                          postCommentType: PostCommentType.replyEpComment,
                          epCommentData: resultFilterCommentList[epCommentIndex-1]
                        );
                      },
                      separatorBuilder: (_,__) => const Divider(height: 1), 
                    );

                  }
                ),
              ),
            );

					}
				);
			}
		);
	}
}


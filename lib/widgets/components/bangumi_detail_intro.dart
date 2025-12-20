

import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/internal/utils/convert.dart';
import 'package:bangu_lite/internal/custom_toaster.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/models/providers/bangumi_model.dart';
import 'package:bangu_lite/models/providers/ep_model.dart';
import 'package:bangu_lite/widgets/components/bangumi_detail_eps.dart';
import 'package:bangu_lite/widgets/components/bangumi_detail_images.dart';
import 'package:bangu_lite/widgets/components/bangumi_detail_infobox.dart';
import 'package:bangu_lite/widgets/components/bangumi_detail_tags.dart';
import 'package:bangu_lite/widgets/fragments/bangumi_rank_box.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/fragments/star_button.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:bangu_lite/models/informations/subjects/bangumi_details.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class BangumiDetailIntro extends StatelessWidget {
  const BangumiDetailIntro({
    super.key,
});

  @override
  Widget build(BuildContext context) {

    return Selector<BangumiModel,BangumiDetails?>(
      selector: (_, bangumiModel)=>bangumiModel.bangumiDetails,
      shouldRebuild: (previous, next) => previous != next,
      builder: (_, bangumiDetails,__) {
        return MediaQuery.orientationOf(context) == Orientation.portrait ?
        IntroPortrait(bangumiDetails: bangumiDetails ?? BangumiDetails()) :
        IntroLandscape(bangumiDetails: bangumiDetails ?? BangumiDetails());
      }, 
    );


  }
}

class IntroPortrait extends StatefulWidget {
  const IntroPortrait({
    super.key,
    required this.bangumiDetails
});

  final BangumiDetails bangumiDetails;

  @override
  State<IntroPortrait> createState() => _IntroPortraitState();
}

class _IntroPortraitState extends State<IntroPortrait> {

  Widget? cachedImages;

  @override
    void initState() {
      super.initState();

      if(widget.bangumiDetails.coverUrl != null){
        cachedImages = BuildDetailImages(
          imageName: widget.bangumiDetails.name,
          imageID: widget.bangumiDetails.id,
          detailImageUrl: widget.bangumiDetails.coverUrl,
        );
      }
      

    }

  @override
  Widget build(BuildContext context) {
    debugPrint("Build IntroPortrait");

    return Column(
      spacing: 12,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
    
          children: [
            //Pic
            Expanded(
              flex: 2,
              child: FittedBox(
                child: cachedImages ?? BuildDetailImages(
                  imageName: widget.bangumiDetails.name,
                  imageID: widget.bangumiDetails.id,
                  detailImageUrl: widget.bangumiDetails.coverUrl,
                )
              )
            ),
    
            //Info
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                
                  //detail——rating
                  children: [
                    
                    Row(
                      children: [
    
                        Expanded(
                          child: ListTile(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: '${widget.bangumiDetails.name}'));
                              fadeToaster(context: context,message: "标题已复制,长按复制别称");
                            },
                            onLongPress: () {
                              Clipboard.setData(ClipboardData(text: '${widget.bangumiDetails.informationList["alias"] ?? ""}'));
                              fadeToaster(context:context,message: "别称已复制");
                            },
                            title: ScalableText(
                              "${widget.bangumiDetails.name}",
                              style: const TextStyle(fontSize: 18),
                            ),
                            subtitle: ScalableText(
                              widget.bangumiDetails.informationList["alias"] ?? "",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            )
                          )
                        ),

                      ]
                    ),
                    
                    BuildInfoBox(informationList: widget.bangumiDetails.informationList,type: widget.bangumiDetails.type)
                  ]
                )
              )
            )
    
            
          ]
        ),

        StarButton(bangumiDetails: widget.bangumiDetails),
    
        LayoutBuilder(
          builder: (_,constraint) {
            return BangumiRankBox(
              constraint: constraint,
              bangumiDetails: widget.bangumiDetails
            );
          }
        ),
    
        //Entry for Portial          
        InkResponse(
          onTap: () {
    
            showModalBottomSheet(
              backgroundColor: judgeDetailRenderColor(context,context.read<BangumiModel>().bangumiThemeColor).withValues(alpha: 0.8),
              constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width),
              context: context, //拥有model的有效context
              
              builder: (_){
                //因为showDialog/showModalBottomSheet 使用的context是独立在整个体系之外的
                //在 layout inspector 里能看到 此时它的层级关系是和 其他的Page一样直接属于materialApp的分支之下
                //因此只能直接这样处理了
                return MultiProvider(
                  providers: [
                    ChangeNotifierProvider.value(value: context.read<BangumiModel>()),
                    ChangeNotifierProvider.value(value: context.read<EpModel>())
                  ],
                  child: EasyRefresh(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: BuildEps(
                          subjectID: widget.bangumiDetails.id!, 
                          subjectName: widget.bangumiDetails.name,
                          informationList: widget.bangumiDetails.informationList,
                          portialMode: true,
                        )
                      )
                    )
                
                  ),
                );
    
              }
            );
          },
          child: SizedBox(
            height: 50,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.6)
                
              ),
              child: Padding(
                padding: PaddingH12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const ScalableText("放送详情"),
                  
                    Row(
                      
                      children: [

                        Selector<EpModel,num>(
                          selector: (_,epModel) => epModel.epsData.length,
                          shouldRebuild: (previous, next) => previous != next,
                          builder: (_,epCount,child){
    
                            final epModel = context.read<EpModel>();
    
                            int airedEps = 0;
    
                            if (
                              widget.bangumiDetails.informationList["air_weekday"] == null || 
                              convertAiredEps(widget.bangumiDetails.informationList["air_date"]) >= (epCount) ||
                              epCount > 500 //不确定长度
                            ){
                              return ScalableText("共$epCount集");
                            }
    
                            if(epCount != 0){
                              
                              if(epModel.epsData[epModel.epsData.length]?.airDate != null){
                                epModel.epsData.values.any((currentEpInfo){
                                  
                                  //debugPrint("airedEps:$airedEps");
    
                                  bool overlapAirDate = convertDateTime(currentEpInfo.airDate).difference(DateTime.now()) >= Duration.zero;
                                  overlapAirDate ? null : airedEps+=1;
    
                                  return overlapAirDate;
    
                                });
    
                              }
                            }
    
                            return ScalableText("$airedEps/$epCount");
                          }
                        ),

                        const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Icon(Icons.arrow_forward_ios,size: 16)
                        )
                      ]
                    )
                  
                  ]
                )
              )
            )
          )
        ),
          
        ConstrainedBox(
          constraints: const BoxConstraints.tightFor(width: double.infinity),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: BuildTags(tagsList: widget.bangumiDetails.tagsList)
          )
        )
    
      ]
    );
      
  }
}

class IntroLandscape extends StatelessWidget {
  const IntroLandscape({
    super.key,
    required this.bangumiDetails

  });

  final BangumiDetails bangumiDetails;

  @override
  Widget build(BuildContext context) {

    

    return Column(
      spacing: 12,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 6,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        
            Expanded(
              child: FittedBox(
                child: BuildDetailImages(
                  detailImageUrl: bangumiDetails.coverUrl,
                  imageID: bangumiDetails.id,
                  imageName: bangumiDetails.name,
                )
              )
            ),
            
            //Info
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  spacing: 12,
                  crossAxisAlignment: CrossAxisAlignment.start,
                
                  //detail——rating
                  children: [
                        
                    ListTile(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: '${bangumiDetails.name}'));
                        fadeToaster(context: context,message: "标题已复制,长按复制alias");
                      },
                      onLongPress: () {
                        Clipboard.setData(ClipboardData(text: '${bangumiDetails.informationList["alias"] ?? ""}'));
                        fadeToaster(context:context,message:"alias已复制");
                      },
                      title: ScalableText("${bangumiDetails.name}",style: const TextStyle(fontSize: 18)),
                      subtitle: ScalableText(bangumiDetails.informationList["alias"] ?? ""),
                      trailing: SizedBox(
                        width: 120,
                        child: StarButton(
                          bangumiDetails: bangumiDetails,
                        )
                      )
                    ),
                        
                    Row(
                      children: [
                        BuildInfoBox(informationList: bangumiDetails.informationList,type: bangumiDetails.type),
                    
                        const Spacer(),
                    
                        BangumiRankBox(bangumiDetails: bangumiDetails, constraint: const BoxConstraints(minWidth: 300,maxWidth: 400))
                      ]
                    ),
                        
                    BuildEps(
                      subjectID: bangumiDetails.id ?? 0,
                      subjectName: bangumiDetails.name,
                      informationList: bangumiDetails.informationList
                    ),
                        
                  ]
                )
              )
            )
        
            ]
        ),

        const Padding(
          padding: PaddingH12,
          child: ScalableText("标签",style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold)),
        ),
    
        //tags
        Padding(
          padding: PaddingH12,
          child: BuildTags(tagsList: bangumiDetails.tagsList)
        )
      ],
    
      
    );

  }
}



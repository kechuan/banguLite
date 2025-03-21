

import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/internal/custom_toaster.dart';
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
import 'package:bangu_lite/models/bangumi_details.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class BangumiDetailIntro extends StatelessWidget {
  const BangumiDetailIntro({
    super.key,
    required this.bangumiDetails
});

  final BangumiDetails bangumiDetails;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.orientationOf(context) == Orientation.portrait ?
    IntroPortrait(bangumiDetails: bangumiDetails) :
    IntroLandscape(bangumiDetails: bangumiDetails);
  }
}

class IntroPortrait extends StatelessWidget {
  const IntroPortrait({
    super.key,
    required this.bangumiDetails
});

  final BangumiDetails bangumiDetails;

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            //Pic
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  FittedBox(
                    child: BuildDetailImages(
                      detailImageUrl: bangumiDetails.coverUrl,
                      imageID: bangumiDetails.id
                    )
                  ),
              
                  const Padding(padding: PaddingV6)
                ]
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
                              Clipboard.setData(ClipboardData(text: '${bangumiDetails.name}'));
                              //showToast("标题已复制,长按复制alias",context:context);
                              fadeToaster(context: context,message: "标题已复制,长按复制alias");
                            },
                            onLongPress: () {
                              Clipboard.setData(ClipboardData(text: '${bangumiDetails.informationList["alias"] ?? ""}'));
                              fadeToaster(context:context,message:"alias已复制");
                            },
                            title: ScalableText("${bangumiDetails.name}",style: const TextStyle(fontSize: 18)),
                            subtitle: ScalableText(bangumiDetails.informationList["alias"] ?? "")
                          )
                        ),

                        StarButton(bangumiDetails: bangumiDetails)
                        

                      ]
                    ),
                    
                    BuildInfoBox(informationList: bangumiDetails.informationList,type: bangumiDetails.type)
                

					


                  ]
                )
              )
            )

            
          ]
        ),

        LayoutBuilder(
          builder: (_,constraint){
            return BangumiRankBox(
              constraint: constraint,
              bangumiDetails: bangumiDetails
            );
          }
        ),


        const Padding(padding: PaddingV6),

         //Entry for Portial
          
        InkResponse(
          onTap: () {

            //final EpModel epModel = context.read<EpModel>();
            showModalBottomSheet(
              constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width),
              context: context,
              
              builder: (_){
                //因为showDialog/showModalBottomSheet 使用的context是独立在整个体系之外的
                //在 layout inspector 里能看到 此时它的层级关系是和 其他的Page一样直接属于materialApp的分支之下
                //因此只能直接这样处理了
                return ChangeNotifierProvider.value(
                  value: context.watch<BangumiModel>(),
                  builder: (_,__) {
                    return ChangeNotifierProvider.value(
                      value: context.watch<EpModel>(),
                      builder: (_,__) {
                        return EasyRefresh(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: BuildEps(
                                subjectID: bangumiDetails.id!, 
                                informationList: bangumiDetails.informationList,
                                portialMode: true,
                              )
                            )
                          )
                      
                        );
                      }
                    );
                  }
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

                        Builder(
                          builder: (_){

                            final epModel = context.read<EpModel>();

                            int airedEps = 0;

                            if (
                              bangumiDetails.informationList["air_weekday"] == null || 
                              convertAiredEps(bangumiDetails.informationList["air_date"]) >= bangumiDetails.informationList["eps"] ||
                              bangumiDetails.informationList["eps"] > 500 //不确定长度
                            ){
                              return ScalableText("共${bangumiDetails.informationList["eps"]}集");
                            }

                            if(bangumiDetails.informationList["eps"] != 0){
                              
                              if(epModel.epsData[epModel.epsData.length]?.airDate != null){
                                epModel.epsData.values.any((currentEpInfo){
                                  
                                  //debugPrint("airedEps:$airedEps");

                                  bool overlapAirDate = convertDateTime(currentEpInfo.airDate).difference(DateTime.now()) >= Duration.zero;
                                  overlapAirDate ? null : airedEps+=1;

                                  return overlapAirDate;

                                });

                              }
                            }

                            return ScalableText("$airedEps/${bangumiDetails.informationList["eps"]}");
                            //return ScalableText("${convertAiredEps(bangumiDetails.informationList["air_date"])}/${bangumiDetails.informationList["eps"]}");
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
            child: BuildTags(tagsList: bangumiDetails.tagsList)
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Expanded(child: FittedBox(child: BuildDetailImages(detailImageUrl: bangumiDetails.coverUrl,imageID: bangumiDetails.id))),
        
        //Info
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
            
              //detail——rating
              children: [
    
                Padding(
                  padding: PaddingH6,
                    child: ListTile(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: '${bangumiDetails.name}'));
                        //showToast("标题已复制,长按复制alias",context:context);
                        fadeToaster(context: context,message: "标题已复制,长按复制alias");
                      },
                      onLongPress: () {
                        Clipboard.setData(ClipboardData(text: '${bangumiDetails.informationList["alias"] ?? ""}'));
                        fadeToaster(context:context,message:"alias已复制");
                      },
                      title: ScalableText("${bangumiDetails.name}",style: const TextStyle(fontSize: 18)),
                      subtitle: ScalableText(bangumiDetails.informationList["alias"] ?? ""),
                      trailing: StarButton(bangumiDetails: bangumiDetails)
                    )
                ),

                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      BuildInfoBox(informationList: bangumiDetails.informationList,type: bangumiDetails.type),
                  
                      const Spacer(),
                  
                      BangumiRankBox(bangumiDetails: bangumiDetails, constraint: const BoxConstraints(minWidth: 300,maxWidth: 400))
                    ]
                  )
                ),

                Padding(
                  padding: const EdgeInsets.all(12),
                  child: BuildEps(
                    subjectID: bangumiDetails.id ?? 0,
                    informationList: bangumiDetails.informationList
                  )
                ),

                //tags
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: BuildTags(tagsList: bangumiDetails.tagsList)
                )
                

              ]
            )
          )
        )
    
        ]
    );

  }
}



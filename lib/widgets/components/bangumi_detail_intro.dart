import 'dart:math';

import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/internal/event_bus.dart';
import 'package:bangu_lite/internal/hive.dart';
import 'package:bangu_lite/models/providers/ep_model.dart';
import 'package:bangu_lite/widgets/components/ep_select.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:bangu_lite/delegates/search_delegates.dart';
import 'package:bangu_lite/models/bangumi_details.dart';
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

    final ValueNotifier<bool> isStaredNotifier = ValueNotifier(MyHive.starBangumisDataBase.containsKey(bangumiDetails.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            //Pic
            Expanded(
              flex: 2,
              child: FittedBox(
                child: BuildDetailImages(
                  detailImageUrl: bangumiDetails.coverUri,
                  imageID: bangumiDetails.id
                ),
              )
            ),
    
            //Info
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(left:12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                
                  //detail——rating
                  children: [
        
                    ListTile(
                      title: Text("${bangumiDetails.name}",style: const TextStyle(fontSize: 18)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                              
                          Text(bangumiDetails.informationList["alias"] ?? ""),
                              
                          Wrap(
                            spacing: 12,
                            
                            alignment: WrapAlignment.spaceBetween,
                            children: [
                                          
                              Text(bangumiDetails.ratingList["rank"]!=0 ? 'Rank #${bangumiDetails.ratingList["rank"]}' : ""),
                    
                              Wrap(
                                alignment:WrapAlignment.spaceBetween,
                                children: [
                    
                                  Text(
                                    "Score ${bangumiDetails.ratingList["score"]?.toDouble()}",
                                    style: TextStyle(
                                      color: Color.fromRGBO(255-(255*((bangumiDetails.ratingList["score"] ?? 0)/10)).toInt(), (255*((bangumiDetails.ratingList["score"] ?? 0)/10).toInt()), 0, 1),
                                      fontWeight: FontWeight.bold
                                    )
                                  ),
                    
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 6),
                                    child: Text("${bangumiDetails.ratingList["total"]} vote(s)",style: const TextStyle(color: Colors.grey),),
                                  ),
                    
                    
                                ],
                              ),
                      
                            ],
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        onPressed: (){

                          //manage Function

                          if(isStaredNotifier.value){
                            MyHive.starBangumisDataBase.delete(bangumiDetails.id);
                            isStaredNotifier.value = false;
                          }

                          else{
                            MyHive.starBangumisDataBase.put(
                              bangumiDetails.id!, {
                                "name": bangumiDetails.name,
                                "coverUri": bangumiDetails.coverUri,
                                "eps": bangumiDetails.informationList["eps"],
                                "score": bangumiDetails.ratingList["score"],
                              }
                            );

                            isStaredNotifier.value = true;
                          }

                          bus.emit("star");
                          
                        
                      }, icon: ValueListenableBuilder(
                        valueListenable: isStaredNotifier,
                        builder: (_,isStared,child){
                          return isStared ? const Icon(Icons.star) : const Icon(Icons.star_outline);
                        }
                      )
                      
                      ),
                    ),

                    BuildInfoBox(informationList: bangumiDetails.informationList),
                
					//Entry for Portial

					InkResponse(
						onTap: () {

							showModalBottomSheet(
							//enableDrag: false,
							//backgroundColor: Theme.of(context).scaffoldBackgroundColor,
							constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width),
							context: context,
							
							builder: (_) => EasyRefresh(
								child: Center(
									child: BuildEps(
										subjectID: bangumiDetails.id!, 
										informationList: bangumiDetails.informationList,
										portialMode: true,
									),
								),

								
							),
						);

						},
						child: SizedBox(
							height: 50,
							child: Container(
								decoration: BoxDecoration(
									borderRadius: BorderRadius.circular(12),
									color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.6)
									
								),
								child: Padding(
									padding: PaddingH12,
									child: Row(
										mainAxisAlignment: MainAxisAlignment.spaceBetween,
										children: [
											const Text("放送详情"),
										
											Row(
												
												children: [

													Builder(
														builder: (_){
															if(
																bangumiDetails.informationList["air_weekday"] == null || 
																convertAiredEps(bangumiDetails.informationList["air_date"]) >= bangumiDetails.informationList["eps"] ||
																bangumiDetails.informationList["eps"] > 500 //不确定长度
															){
																return Text("共${bangumiDetails.informationList["eps"]}集");
															}


															return Text("${convertAiredEps(bangumiDetails.informationList["air_date"])}/${bangumiDetails.informationList["eps"]}");
														}
													),

													

													//bangumiDetails.informationList["eps"] < 100 ?
													//Text("${convertAiredEps(bangumiDetails.informationList["air_date"])}/${bangumiDetails.informationList["eps"]}") :
													//const Text("*/*"),

													const Padding(
														padding: EdgeInsets.only(left: 6),
														child: Icon(Icons.arrow_forward_ios,size: 16,),
													)
												]
											)
										
										],
									),
								),
							),
						),
					),

					


                  ],
                ),
              ),
            ),
          ],
        ),

        ConstrainedBox(
          constraints: const BoxConstraints.tightFor(width: double.infinity),
          child: BuildTags(tagsList: bangumiDetails.tagsList)
        ),
      ],
    );
      
  }
}

class IntroLandscape extends StatelessWidget {
  const IntroLandscape({
    super.key,
    required this.bangumiDetails,

  });

  final BangumiDetails bangumiDetails;

  @override
  Widget build(BuildContext context) {

    final ValueNotifier<bool> isStaredNotifier = ValueNotifier(MyHive.starBangumisDataBase.containsKey(bangumiDetails.id));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Expanded(child: FittedBox(child: BuildDetailImages(detailImageUrl: bangumiDetails.coverUri,imageID: bangumiDetails.id))),
        
        //Info
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
            
              //detail——rating
              children: [
    
                ListTile(
                  title: Text("${bangumiDetails.name}",style: const TextStyle(fontSize: 18)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
    
                      Text(bangumiDetails.informationList["alias"] ?? ""),
    
                      Wrap(
                        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        alignment: WrapAlignment.spaceBetween,
                        children: [
                                      
                          Text(bangumiDetails.ratingList["rank"]!=0 ? 'Rank #${bangumiDetails.ratingList["rank"]}' : ""),
                            
                          Row(
                            children: [
                              Text(
                                "Score ${bangumiDetails.ratingList["score"]?.toDouble()}",
                                style: TextStyle(
                                  color: Color.fromRGBO(255-(255*((bangumiDetails.ratingList["score"] ?? 0)/10)).toInt(), (255*((bangumiDetails.ratingList["score"] ?? 0)/10).toInt()), 0, 1),
                                  fontWeight: FontWeight.bold
                                )
                              ),
                                      
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: Text("${bangumiDetails.ratingList["total"]} vote(s)",style: const TextStyle(color: Colors.grey),),
                              ),
                                      
                            ],
                          ),
                                      
                        ],
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    onPressed: (){

                        //manage Function

                        if(isStaredNotifier.value){
                          MyHive.starBangumisDataBase.delete(bangumiDetails.id);
                          isStaredNotifier.value = false;
                        }

                        else{
                          MyHive.starBangumisDataBase.put(
                            bangumiDetails.id!, {
                              "name": bangumiDetails.name,
                              "coverUri": bangumiDetails.coverUri,
                              "eps": bangumiDetails.informationList["eps"],
                              "score": bangumiDetails.ratingList["score"],
                            }
                          );

                          isStaredNotifier.value = true;
                        }

                        bus.emit("star");
                        
                      
                    }, 
                    
                    icon: ValueListenableBuilder(
                      valueListenable: isStaredNotifier,
                        builder: (_,isStared,__) => isStared ? const Icon(Icons.star) : const Icon(Icons.star_outline)
                    )
                  
                  ),
                ),

                BuildInfoBox(informationList: bangumiDetails.informationList),

                BuildEps(
                  subjectID: bangumiDetails.id ?? 0,
                  informationList: bangumiDetails.informationList,
                ),

                //tags
                BuildTags(tagsList: bangumiDetails.tagsList)
                

              ],
            ),
          ),
        ),
    
        ],
    );

  }
}

class BuildTags extends StatelessWidget {
  const BuildTags({
    super.key,
    required this.tagsList
  });

  final Map tagsList;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Builder(
        builder: (_){
          if(tagsList.isNotEmpty){
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: List.generate(tagsList.length, (index){
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(width: 0.5,color: const Color.fromARGB(255, 219, 190, 213))
                    ),
                    child: TextButton(
                      child: Text("${tagsList.keys.elementAt(index)} ${tagsList.values.elementAt(index)}"),
                      onPressed: () {
                        showSearch(
                          context: context,
                          delegate: CustomSearchDelegate(),
                          query: tagsList.keys.elementAt(index)
                        );
                      },
                      
                    )
                  );
                })
              ,
            );
          }
      
          return const Text("暂无Tags信息");
        }
      ),
    );
  }
}

class BuildDetailImages extends StatelessWidget {
  const BuildDetailImages({
    super.key,
    this.detailImageUrl,
    this.imageID
  });

  final String? detailImageUrl;
  final int? imageID;

  @override
  Widget build(BuildContext context) {
    return detailImageUrl != null ?

      CachedNetworkImage(
        
        imageUrl: detailImageUrl!,
        imageBuilder: (_,imageProvider){
          
          ColorScheme.fromImageProvider(provider: imageProvider).then((coverScheme){
            debugPrint("parse Picture:${coverScheme.primary}");
            bus.emit("imageColor",{imageID!:coverScheme.primary});
          });
      
          return Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.orientationOf(context) == Orientation.landscape ? 300 : 200,
              minWidth: MediaQuery.orientationOf(context) == Orientation.landscape ? 200 : 133,
            ),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.contain,
              ),
              borderRadius: BorderRadius.circular(16)
            ),
          );
        },
        progressIndicatorBuilder: (_, __, progress) {
        
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.grey,
            ),
      
            constraints: BoxConstraints(
              minHeight: MediaQuery.orientationOf(context) == Orientation.landscape ? 300 : 200,
              minWidth: MediaQuery.orientationOf(context) == Orientation.landscape ? 200 : 133,
            ),
            
            child: const Center(
              child: Text("loading..."),
            ),
          );
        
        },
      )
    :  
	
	Image.asset(
		'assets/icons/icon.png',
		width: max(MediaQuery.sizeOf(context).height*1/4,MediaQuery.sizeOf(context).width*1/6),
		height: max(MediaQuery.sizeOf(context).height*1/4,MediaQuery.sizeOf(context).width*1/6),
	);
	
  }
}

class BuildInfoBox extends StatelessWidget{

  const BuildInfoBox({
    super.key,
    required this.informationList
  });

  final Map<String, dynamic> informationList;

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("总集数: ${informationList["eps"]}",style: const TextStyle(fontWeight: FontWeight.bold),),
          Text("更新日期: ${informationList["air_weekday"]}",style: const TextStyle(fontWeight: FontWeight.bold),)
        ],
      ),
    );
  }
  
}

class BuildEps extends StatelessWidget {
  const BuildEps({
    super.key,
    required this.subjectID,
    required this.informationList,
	this.portialMode
  });

  final int subjectID;
  final Map<String, dynamic> informationList;
  final bool? portialMode;

  @override
  Widget build(BuildContext context) {

    int totalEps = informationList["eps"] ?? 0;
    int airedEps = convertAiredEps(informationList["air_date"]);

    return ChangeNotifierProvider(
    			create: (_) => EpModel(subjectID: subjectID,selectedEp: 1),
    			builder: (context,child) {
    
    		  return Padding(
    			padding: const EdgeInsets.all(12),
    			child: Builder(
    			  builder: (_){
    
    					if(totalEps == 0) return const SizedBox.shrink();
    
    					return EpSelect(
    						totalEps: totalEps,
    						airedEps: airedEps,
    						portialMode: portialMode,
							name: informationList["alias"],
    					);
    
    			  //return Wrap(
    			  //  direction : Axis.horizontal,
    			  //  spacing: 12,
    			  //  runSpacing: 12,
    			  //  children: List.generate(
    			  //    min(100,totalEps),
    			  //    (index){
    			
    			  
    			  //        int currentEp = index;
    			  
    			  //        Color currentEpsColor = Colors.white;
    			  
    			  //        //放送中
    			  //        if(airedEps <= totalEps){ 
    			  //          if(airedEps == currentEp) currentEpsColor = const Color.fromARGB(255, 219, 245, 223);
    			  //          if(airedEps > currentEp)  currentEpsColor = const Color.fromARGB(255, 217, 231, 255);
    			  //        }
    				
    			  //        //已完结
    			  //        else{
    			  //          currentEpsColor = const Color.fromARGB(255, 217, 231, 255);
    			  //        }
    				
    			  //        return Container(
    			  //          decoration: BoxDecoration(
    			  //            border: Border(
    			  //              top: const BorderSide(),
    			  //              left: const BorderSide(),
    			  //              right: const BorderSide(),
    			  //              bottom: BorderSide(
    			  //                width: 3, 
    			  //                color: convertAiredEps(informationList["air_date"]) >= index ? Colors.blueAccent : Colors.grey,
    			  //              ),
    			  //            ),
    			  //            color: currentEpsColor
    							
    						  
    			  //          ),
    						
    			  //          child: SizedBox(
    			  //            height: 30,
    			  //            width: 30,
    			  //            child: InkResponse(
    			  //              containedInkWell: true,
    			  //              onTap: (){
    			  
    			  
    			  //               Navigator.pushNamed(
    			  //                context, Routes.subjectEp,
    			  //                arguments: {
    			  //                  "subjectID":subjectID,
    			  //                  "totalEps": totalEps,
    			  //                  "epModel": context.read<EpModel>(),
    			  //                }
    			  //              );
    			  
    							
    							  
    			  //              },
    			  
    			  //              //需求FittedBox 适配 三位数以上集数 以及 展开 或者 页面翻开
    			  //              child: Center(
    			  //                child: Text("${currentEp+1}")
    			  
    								
    			  //                )
    							
    			  //            ),
    			  //          ),
    			  //        );
    					
    			  //      }
    			  //    )
    			  //  );
    				  
    
    			  
    			
    				}
    				
    			  )
    		  );
    		}
    );
  }
}
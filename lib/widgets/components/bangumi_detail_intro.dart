import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:bangu_lite/delegates/search_delegates.dart';
import 'package:bangu_lite/models/bangumi_details.dart';


class BangumiDetailIntro extends StatelessWidget {
  const BangumiDetailIntro({
    super.key,
    required this.bangumiDetails
  });

  final BangumiDetails bangumiDetails;

  @override
  Widget build(BuildContext context) {

    if(MediaQuery.orientationOf(context) == Orientation.portrait){

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              //Pic
              Expanded(
                flex: 2,
                child: BuildDetailImages(detailImageUrl: bangumiDetails.coverUri)
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
                        trailing: IconButton(onPressed: (){}, icon: const Icon(Icons.star_outline)),
                      ),

                      BuildInfoBox(informationList: bangumiDetails.informationList),
                  


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

    //landsacape

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Expanded(child: BuildDetailImages(detailImageUrl: bangumiDetails.coverUri)),
        
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
                  trailing: IconButton(onPressed: (){}, icon:  Icon(Icons.star_outline)),
                ),


                BuildInfoBox(informationList: bangumiDetails.informationList),

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
              children: [
      
                ...List.generate(tagsList.length, (index){
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
      
              ],
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
    this.detailImageUrl
  });

  final String? detailImageUrl;

  @override
  Widget build(BuildContext context) {
    return detailImageUrl != null ?

      CachedNetworkImage(
        
        imageUrl: detailImageUrl!,
        imageBuilder: (_,imageProvider){
          
          //ColorScheme.fromImageProvider(provider: imageProvider).then((coverScheme){ 感觉不是很有用
          //  debugPrint("parse Picture:${coverScheme.primary}");
          //});
      
          return Container(
            constraints:  BoxConstraints(
              minHeight: MediaQuery.orientationOf(context) == Orientation.landscape ? 300 : 200,
              minWidth: MediaQuery.orientationOf(context) == Orientation.landscape ? 200 : 133,
            ),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.contain,
              ),
              borderRadius: BorderRadius.circular(24)
            ),
          );
        },
        progressIndicatorBuilder: (_, __, progress) {
        
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
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
    :  FlutterLogo(
      size: max(MediaQuery.sizeOf(context).height*1/4,MediaQuery.sizeOf(context).width*1/6),
    );
  }
}

class BuildInfoBox extends StatelessWidget{

  const BuildInfoBox({
    super.key,
    required this.informationList
  });

  final Map<String, String> informationList;

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(8.0),
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
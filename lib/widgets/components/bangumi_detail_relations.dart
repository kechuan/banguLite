import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/models/providers/relation_model.dart';
import 'package:bangu_lite/widgets/fragments/cached_image_loader.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BangumiDetailRelations extends StatelessWidget {
  const BangumiDetailRelations({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: Padding16,
      child: Consumer<RelationModel>(
        builder: (_,relationModel,child) {

          bool isRelationsEmpty =  
            relationModel.contentListData.isEmpty ||
            relationModel.contentListData.first.relationID == 0
          ;

          return SizedBox(
            height: isRelationsEmpty ? 100 : 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
          
                const ScalableText("相关条目",style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold)),
          
                Expanded(
                  child: LayoutBuilder(
                    builder: (_,constraint) {

                      if(isRelationsEmpty){
                        return const Center(
                          child: ScalableText("该番剧暂无相关条目..."),
                        );
                      }
      
                      return ListView.builder(
                        shrinkWrap: true,
                        itemExtent: 200,
                        itemCount: relationModel.contentListData.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (_,index){
      
                          return Padding(
                            padding: PaddingH6,
                            child: Tooltip(
                              message: "${relationModel.contentListData[index].description}",
                              child: ListTile(
                                //注意 CachedImageLoader 需要明确的约束 而ListTile的约束不明确
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    Routes.subjectDetail,
                                    arguments: {"subjectID":relationModel.contentListData[index].subjectDetail?.id},
                                  );
                                },
                                title: SizedBox(
                                  height: 180,
                                  child: CachedImageLoader(
                                    imageUrl: relationModel.contentListData[index].subjectDetail?.coverUrl,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: PaddingV12,
                                  child: Column(
                                    spacing: 6,
                                    children: [
                                      SizedBox(
                                        height: constraint.maxHeight - 200,
                                        child: ScalableText(
                                          "${relationModel.contentListData[index].subjectDetail?.name}",
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      ScalableText("${relationModel.contentListData[index].name}",style: const TextStyle(color: Colors.grey),),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      );
                    
                    }
                  ),
                ),
              
              ],
            ),
          );
        }
      ),
    );
  }
}
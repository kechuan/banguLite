import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/models/providers/relation_model.dart';
import 'package:bangu_lite/widgets/fragments/cached_image_loader.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class BangumiDetailRelations extends StatelessWidget {
  const BangumiDetailRelations({
    super.key,
  });

  

  @override
  Widget build(BuildContext context) {

    final relationModel =  context.read<RelationModel>();

    return Padding(
      padding: Padding12,
      child: SizedBox(
        height: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
      
            const ScalableText("相关番剧",style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold)),
      
            Expanded(
              child: LayoutBuilder(
                builder: (_,constraint) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemExtent: 200,
                    itemCount: relationModel.subjectRelationData.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (_,index){
                      return Padding(
                        padding: PaddingH12,
                        child: Tooltip(
                          message: "${relationModel.subjectRelationData[index].description}",
                          child: ListTile(
                            //注意 CachedImageLoader 需要明确的约束 而ListTile的约束不明确
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                Routes.subjectDetail,
                                arguments: {"subjectID":relationModel.subjectRelationData[index].subjectDetail?.id},
                              );
                            },
                            title: SizedBox(
                              height: 180,
                              child: CachedImageLoader(
                                imageUrl: relationModel.subjectRelationData[index].subjectDetail?.coverUrl,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Column(
                                spacing: 6,
                                children: [
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxHeight: constraint.maxHeight - 200 //180+top:16
                                    ),
                                    child: ScalableText(
                                      "${relationModel.subjectRelationData[index].subjectDetail?.name}",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  ScalableText("${relationModel.subjectRelationData[index].name}"),
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
      ),
    );
  }
}
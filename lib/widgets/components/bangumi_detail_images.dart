import 'dart:math';

import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/models/providers/bangumi_model.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/fragments/unvisible_response.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

    final bangumiModel = context.read<BangumiModel>();

    bool darkMode = judgeDarknessMode(context);

    return detailImageUrl != null ?

      CachedNetworkImage(
        imageUrl: detailImageUrl!,
        imageBuilder: (_,imageProvider){
      
          if(bangumiModel.imageColor==null){
            ColorScheme.fromImageProvider(provider: imageProvider).then((coverScheme){
      
              debugPrint("parse Picture:${coverScheme.primary}");
              bangumiModel.getThemeColor(coverScheme.primary,darkMode: darkMode);
            });
          }
      
          return UnVisibleResponse(
            onTap: () {
              Navigator.pushNamed(
                context,
                Routes.photoView,
                arguments: {"imageProvider":imageProvider},
              );

            },
            child: Container(
              constraints: BoxConstraints(
                minHeight: MediaQuery.orientationOf(context) == Orientation.landscape ? 300 : 200,
                minWidth: MediaQuery.orientationOf(context) == Orientation.landscape ? 200 : 133,
              ),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageProvider,
                  //fit: BoxFit.contain,
                  fit: BoxFit.fill,
                ),
                borderRadius: BorderRadius.circular(16)
              ),
            ),
          );
        },
        errorWidget: (context, url, error) {
          return Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.orientationOf(context) == Orientation.landscape ? 300 : 200,
              minWidth: MediaQuery.orientationOf(context) == Orientation.landscape ? 200 : 133,
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.grey.withValues(alpha: 0.5),
              ),
            child: const Center(child: ScalableText("Image Not Available")),
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
              child: ScalableText("loading..."),
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

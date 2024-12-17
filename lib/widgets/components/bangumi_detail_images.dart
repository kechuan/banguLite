import 'dart:math';

import 'package:bangu_lite/models/providers/bangumi_model.dart';
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

    return detailImageUrl != null ?

      CachedNetworkImage(
        
        imageUrl: detailImageUrl!,
        imageBuilder: (_,imageProvider){

          if(bangumiModel.bangumiThemeColor==null){
            ColorScheme.fromImageProvider(provider: imageProvider).then((coverScheme){
              debugPrint("parse Picture:${coverScheme.primary}");
              bangumiModel.getThemeColor(coverScheme.primary,darkMode: Theme.of(context).brightness == Brightness.dark);
            });
          }

          return Container(
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
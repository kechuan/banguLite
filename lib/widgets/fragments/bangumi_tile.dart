import 'package:flutter/material.dart';
import 'package:flutter_bangumi/widgets/fragments/cached_image_loader.dart';

class BangumiTile extends ListTile {
  const BangumiTile({
    super.key,
    //super.title,

    required this.imageSize,

    this.imageUrl,
    this.bangumiTitle,

    super.trailing,
    super.subtitle,
    super.onTap
  });

  final String? imageUrl;
  final Size imageSize;
  final String? bangumiTitle;


  @override
  Widget build(BuildContext context) {
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20 //padding 1 * 2
      ),   
      title: Row(
        children: [
          
          SizedBox(
            height: imageSize.height,
            width: imageSize.width, // size 1
            child: CachedImageLoader(
              imageUrl: imageUrl,
            )
          ),
    
          Padding(
            padding: const EdgeInsets.only(left: 24), //padding 2
            child: SizedBox(
              height: 150,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 50,
                    maxWidth: ( MediaQuery.sizeOf(context).width - imageSize.width - 24 - 40 ), //calculate
                    
                    
                  ),
                  child: Text(
                    bangumiTitle ?? "name",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )
                ))
            ),
          ),
          
        ],
      ),
    
      subtitle: subtitle,
      trailing: trailing,
      onTap: onTap,
    
    );
  }
}
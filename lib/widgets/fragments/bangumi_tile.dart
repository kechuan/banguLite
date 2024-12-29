import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:flutter/material.dart';
import 'package:bangu_lite/widgets/fragments/cached_image_loader.dart';

class BangumiListTile extends ListTile {
  const BangumiListTile({
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
    
          Expanded(
            child: LayoutBuilder(
              builder: (_,constraint) {
                return Padding(
                  padding: const EdgeInsets.only(left: 24), //padding 2
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: imageSize.height ,
                      maxWidth: constraint.maxWidth - imageSize.width, //calculate
                      
                    ),
                    child: ScalableText(
                      bangumiTitle ?? "name",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )
                  ),
                );
              }
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

class BangumiGridTile extends StatelessWidget {
    const BangumiGridTile({
      super.key,
      
      this.imageUrl,
      this.bangumiTitle,
      this.onTap, 
      
    });

    final String? imageUrl;
    final String? bangumiTitle;

    final void Function()? onTap;
  
  @override
  Widget build(BuildContext context) {

    return GridTile(
        
      footer: ListTile(
        title: Center(
          child: ScalableText(
            bangumiTitle ?? "loading",
            maxLines: 2,
            style: const TextStyle(color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
        )
      ),
    
      child: Stack(
          children: [
                                          
            Positioned.fill(
              child: CachedImageLoader(imageUrl: imageUrl),
            ),
                                          
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin:Alignment.bottomCenter,
                    end:Alignment(0, 0.2),
                    
                    colors:[Color.fromARGB(255, 35, 35, 35),Colors.transparent]
                  ),
                ),
              )
            ),
                                                      
            Positioned.fill(
              child: InkResponse(
                containedInkWell: true,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: onTap,
              )
            )
        
          ],
        ),

    );
  }
}
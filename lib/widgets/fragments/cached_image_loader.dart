import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CachedImageLoader extends StatelessWidget {
  const CachedImageLoader({
    super.key,
    this.imageUrl,
    this.photoViewStatus
  });

  final String? imageUrl;
  final bool? photoViewStatus;

  @override
  Widget build(BuildContext context) {

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
          border: Border.all(width: 1)
        ),
        child: Builder(
          builder: (_){

            if(imageUrl!=null){

              DateTime loadStartTime = DateTime.now();

              return CachedNetworkImage(
                imageUrl: imageUrl!,
                imageBuilder: (_,imageProvider){
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(24)
                    ),
                  );
                },

                errorWidget: (_, url, error) {

                  return DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: Colors.grey.withValues(alpha: 0.5),
                    ),
                    child: const Center(child: ScalableText("Image not available")),
                  );

                },
                
                progressIndicatorBuilder: (_, url, progress) {
              
                  bool showProgressIndicator = false;
              
                  if(DateTime.now().millisecondsSinceEpoch - loadStartTime.millisecondsSinceEpoch > 5000){
                     showProgressIndicator = true;
                  }
                  //debugPrint("url: $url , progress:${progress}");
              
                  return DecoratedBox(                              
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.grey,
                    ),
                    
                    child: Center(
                      child: ScalableText("loading... ${showProgressIndicator ? "${((progress.progress ?? 0.0)*100).toStringAsFixed(2)}%" : ""}"), //loading
                    ),
                  );
                },
              );
            }
        
            else{
              return Center(child: Image.asset("assets/icons/icon.png")); //null 
            }
          }
        )
    );
  }

  void photoView(BuildContext context,ImageProvider imageProvider){
    Navigator.pushNamed(
      context,
      Routes.photoView,
      arguments: {"imageProvider":imageProvider},
    );
  }
}


                                                  
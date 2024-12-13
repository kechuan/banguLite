import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CachedImageLoader extends StatelessWidget {
  const CachedImageLoader({
    super.key,
    this.imageUrl,
  });

  final String? imageUrl;

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
                      borderRadius: BorderRadius.circular(16)
                    ),
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
                      child: Text("loading... ${showProgressIndicator ? progress : ""}"), //loading
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
}


                                                  
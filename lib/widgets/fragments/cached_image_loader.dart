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
                  //debugPrint("url: $url , progress:${progress.progress}/${progress.totalSize}");

                  return DecoratedBox(                              
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.grey,
                    ),
                    
                    child: const Center(
                      child: Text("loading..."), //loading
                    ),
                  );
                },
              );
            }
        
            else{
              return const Center(child: FlutterLogo()); //null 
            }
          }
        )
    );
  }
}


                                                  
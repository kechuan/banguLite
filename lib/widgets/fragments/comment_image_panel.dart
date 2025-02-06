
import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/internal/get_task_information.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/fragments/unvisible_response.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CommentImagePanel extends StatefulWidget {
  const CommentImagePanel({
    super.key,
    required this.imageUrl,
  });

  final String imageUrl;

  @override
  State<CommentImagePanel> createState() => _CommentImagePanelState();
}

class _CommentImagePanelState extends State<CommentImagePanel> {

  Future? loadInformationFuture;
  RequestByteInformation pictureRequestInformation = RequestByteInformation();
  ValueNotifier<bool> imageLoadNotifier = ValueNotifier(false);

  //final int size;
  @override
  Widget build(BuildContext context) {

    loadInformationFuture ??= loadByteInformation(widget.imageUrl);
    
    return FutureBuilder(
      future: loadInformationFuture,
      builder: (_,snapshot) {

        switch(snapshot.connectionState){

          case ConnectionState.done:{
            if(snapshot.hasData){
              if(snapshot.data!=null){

                RequestByteInformation pictureRequestInformation = snapshot.data;

                //pictureRequestInformation.printInformation();

                bool isValid = pictureRequestInformation.contentLength != null;

                return Card(
                  shadowColor: Colors.white,
                  elevation: 6,
                  child: UnVisibleResponse(
                    onTap: (){
                      if(!isValid) return;
                      imageLoadNotifier.value = true;
                    },
                    child: ValueListenableBuilder(
                      valueListenable: imageLoadNotifier,
                      builder: (_,imageLoadNotifier,child) {
                  
                        if(imageLoadNotifier == false){
                          return SizedBox(
                            height: 200,
                            width: 200,
                            child: Column(
                              
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Spacer(),

                                Expanded(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 200),
                                    child: ScalableText(
                                      !isValid ? "图片无法加载" : "点击查看图片",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: !isValid ? Colors.grey : null),
                                    )
                                  ),
                                ),


                                ...?!isValid ? [
                                  ScalableText(pictureRequestInformation.statusMessage ?? ""),
                                  const Padding(padding: PaddingV12),
                                  
                                ] : null,

                                ...?isValid ? [
                                  const Padding(padding: PaddingV6),
                                  ScalableText("size: ${convertTypeSize(pictureRequestInformation.contentLength ?? 0)}"),
                                  const Padding(padding: PaddingV6),
                                  ScalableText("type: ${pictureRequestInformation.contentType}"),
                                  const Padding(padding: PaddingV6),
                                ] : null
             
                              ],
                            ),
                          );
                        }


                  
                        return CachedNetworkImage(
                          imageUrl: widget.imageUrl,
                          //fit: BoxFit.cover,
                          imageBuilder: (_, imageProvider) {
                            return UnVisibleResponse(
                              onTap: (){
                                  Navigator.pushNamed(
                                  context,
                                  Routes.photoView,
                                  arguments: {"imageProvider":imageProvider},
                                );
                              },
                              child: Image(image: imageProvider)
                            );
                          },
                        );
             
                        //return CachedImageLoader(imageUrl: widget.imageUrl,photoViewStatus:true); 
                        //problem: not work with DecorationImage
                        
                      }
                    ),
                  ),
                );
              }
            }
          }

          
          default : return const Card(
            child: SizedBox(
              height: 200,
              width: 200,
              child: Center(
                child: CircularProgressIndicator()
              ),
            )
          );
            
        }


        return const Card(
          child: SizedBox(
            height: 200,
            width: 200,
            child: Center(
              child: CircularProgressIndicator()
            ),
          )
        );

        



      }
    );
  }
}
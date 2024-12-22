
import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/internal/get_task_information.dart';
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
                              
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 200),
                                  child: Text(
                                    !isValid ? "图片无法加载" : "点击查看图片",
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: !isValid ? Colors.grey : null),
                                  )
                                ),

                                ...?isValid ? [
                                  const Padding(padding: PaddingV6),
                                  Text("size: ${convertTypeSize(pictureRequestInformation.contentLength ?? 0)}"),
                                  const Padding(padding: PaddingV6),
                                  Text("type: ${pictureRequestInformation.contentType}"),
                                ] : null
             
                              ],
                            ),
                          );
                        }
                  
                        return CachedNetworkImage(imageUrl: widget.imageUrl);
                        
                      }
                    ),
                  ),
                );
              }
            }
          }

          
          default : return const Card(child: Center(child: CircularProgressIndicator(),));
            
        }


        return const CircularProgressIndicator();

        



      }
    );
  }
}
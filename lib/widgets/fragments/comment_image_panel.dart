
import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/internal/utils/convert.dart';
import 'package:bangu_lite/internal/request_task_information.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/fragments/unvisible_response.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


const excludeImageFormatted = [
  "avif",
];

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

  @override
  Widget build(BuildContext context) {

    final indexModel = context.read<IndexModel>();

    loadInformationFuture ??= loadByteInformation(widget.imageUrl);

    RequestByteInformation? pictureRequestInformation;
    
    return FutureBuilder(
      future: loadInformationFuture,
      builder: (_,snapshot) {

        switch(snapshot.connectionState){

          case ConnectionState.done:{

            pictureRequestInformation = snapshot.data;

             bool isValid = 
              pictureRequestInformation?.contentLength != null ||
              excludeImageFormatted.contains(pictureRequestInformation?.contentType?.split("/")[1]) == true
            ;

            if(isValid && indexModel.userConfig.isManuallyImageLoad == false){
              debugPrint("loadStatus: ${indexModel.userConfig.isManuallyImageLoad}");
              imageLoadNotifier.value = true;
            }

            return Card(
              shadowColor: Colors.white,
              elevation: 6,
              child: UnVisibleResponse(
                onTap: (){
                  if(!isValid){
                    Navigator.pushNamed(
                      context,
                      Routes.webview,
                      arguments: {"url":widget.imageUrl},
                    );
                  }

                  else{
                    imageLoadNotifier.value = true;
                  }
                  
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

                            (!isValid) ? Padding(
                              padding: PaddingV12,
                              child: Column(
                                spacing: 12,
                                children: [
                                  const ScalableText("点击跳转以查看图片",style: TextStyle(fontWeight: FontWeight.bold)),
                                  ScalableText("link: ${widget.imageUrl}",maxLines: 3,overflow: TextOverflow.ellipsis,textAlign: TextAlign.center,),
                                ],
                              ),
                            ): const SizedBox.shrink(),
                            
                            isValid ? Padding(
                              padding: PaddingV6,
                              child: Column(
                                spacing: 12,
                                children: [
                                  ScalableText("size: ${convertTypeSize(pictureRequestInformation?.contentLength ?? 0)}"),
                                  ScalableText("type: ${pictureRequestInformation?.contentType}"),
                                ],
                              ),
                            ) : const SizedBox.shrink()
                            
                          ],
                        ),
                      );
                    }

                    return CachedNetworkImage(
                      imageUrl: widget.imageUrl,
                      httpHeaders: HttpApiClient.broswerHeader,
                      progressIndicatorBuilder: (context, url, progress){ 
          
                        return LoadingCard(
                          progress: "${((progress.progress ?? 0.0)*100).toStringAsFixed(2)}%",
                        );

                      },
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
                    
                  }
                ),
              ),
            );

          }

          default: {}
            
        }

        return const LoadingCard();

      }
    );
  }
}

class LoadingCard extends StatelessWidget {
  const LoadingCard({
    super.key,
    this.progress
  });

  final String? progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: 200,
      child: Center(
        child: Column(
          spacing: 16,
          mainAxisAlignment: MainAxisAlignment.center,
      
          children: [
      
            const CircularProgressIndicator(),
      
            ScalableText(progress ?? ""),
      
          ],
        ),
      ),
    );
  }
}
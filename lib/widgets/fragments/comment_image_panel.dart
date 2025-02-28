
import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/internal/get_task_information.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/fragments/unvisible_response.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

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

    final indexModel = context.read<IndexModel>();

    loadInformationFuture ??= loadByteInformation(widget.imageUrl);
    
    return FutureBuilder(
      future: loadInformationFuture,
      builder: (_,snapshot) {

        switch(snapshot.connectionState){

          case ConnectionState.done:{
            if(snapshot.hasData && snapshot.data!=null){

                RequestByteInformation pictureRequestInformation = snapshot.data;

                bool isValid = pictureRequestInformation.contentLength != null;

                debugPrint("loadStatus: ${indexModel.userConfig.isManuallyImageLoad}");

                if(isValid && indexModel.userConfig.isManuallyImageLoad == false){
                  imageLoadNotifier.value = true;
                }

                return Card(
                  shadowColor: Colors.white,
                  elevation: 6,
                  child: UnVisibleResponse(
                    onTap: (){
                      if(!isValid){
                        canLaunchUrlString(widget.imageUrl).then((result){
                          result ? launchUrlString(widget.imageUrl): null;
                          return;
                        });
                      }
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

                                (!isValid) ? Padding(
                                  padding: PaddingV12,
                                  child: Column(
                                    spacing: 12,
                                    children: [
                                      const ScalableText("打开外部浏览器以查看图片"),
                                      ScalableText("link: ${widget.imageUrl}"),
                                    ],
                                  ),
                                ): const SizedBox.shrink(),
                                
                                isValid ? Padding(
                                  padding: PaddingV6,
                                  child: Column(
                                    spacing: 12,
                                    children: [
                                      ScalableText("size: ${convertTypeSize(pictureRequestInformation.contentLength ?? 0)}"),
                                      ScalableText("type: ${pictureRequestInformation.contentType}"),
                                    ],
                                  ),
                                ) : const SizedBox.shrink()
                                
                              ],
                            ),
                          );
                        }

                        return CachedNetworkImage(
                          imageUrl: widget.imageUrl,
                          progressIndicatorBuilder: (context, url, progress) => const LoadingCard(),
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
          }

          default: {}
            
        }

        return const LoadingCard();

      }
    );
  }
}

class LoadingCard extends StatelessWidget {
  const LoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 200,
      width: 200,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
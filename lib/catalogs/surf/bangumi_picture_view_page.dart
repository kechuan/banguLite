import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:bangu_lite/internal/custom_toaster.dart';
import 'package:bangu_lite/internal/hive.dart';
import 'package:bangu_lite/internal/utils/convert.dart';
import 'package:bangu_lite/widgets/dialogs/inital_image_storage_dialog.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:docman/docman.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

@FFRoute(name: '/photoView')

class BangumiPictureViewPage extends StatefulWidget {
  const BangumiPictureViewPage({
    super.key,
    required this.imageProvider,
    this.name
  });

  final ImageProvider imageProvider;
  final String? name;

  @override
  State<BangumiPictureViewPage> createState() => _BangumiPictureViewPageState();
}

class _BangumiPictureViewPageState extends State<BangumiPictureViewPage> {

  final imageViewController = PhotoViewController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: ScalableText(widget.name ?? "图片查看"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {

              invokeToaster({required String message})=> fadeToaster(context: context, message: message);

              invokeInitalStorageDialog() => initalImageStorageDialog(context);

              saveImageFile(
                targetWriteInPath: await getStoragePath(fallbackAction: invokeInitalStorageDialog),
                selectedDocFileData: await getImageBytesFromImageProvider(widget.imageProvider),
                name: widget.name
              ).then((result){
                result ? 
                invokeToaster(message: "已保存内容至目录中") : 
                invokeToaster(message: "保存失败") ;
              });

            },
          )
        ],
        backgroundColor: Colors.transparent,
      ),
      body:  Listener(
        onPointerSignal: (event) {
          if(event is PointerScrollEvent){

            if(event.scrollDelta.dy > 0){
              imageViewController.value = PhotoViewControllerValue(
                position: imageViewController.value.position,
                scale: (imageViewController.value.scale! - 0.1).clamp(0.1, (PhotoViewComputedScale.covered*2).multiplier),
                rotation: imageViewController.value.rotation,
                rotationFocusPoint: imageViewController.value.rotationFocusPoint
              );
            }

            else{
              
              imageViewController.value = PhotoViewControllerValue(
                position: imageViewController.value.position,
                scale: (imageViewController.value.scale! + 0.1).clamp(0.1, (PhotoViewComputedScale.covered*2).multiplier),                rotation: imageViewController.value.rotation,                rotationFocusPoint: imageViewController.value.rotationFocusPoint
              );

            }

          }


        },
        
        child: PhotoView(
          controller: imageViewController,
          minScale: 0.1,
          maxScale: PhotoViewComputedScale.covered*2,
          imageProvider: widget.imageProvider,
        )
        
      ),
    );
  }
}

// ImageProvider to Uint8List
Future<Uint8List?> getImageBytesFromImageProvider(ImageProvider imageProvider) async {
  final ImageStream stream = imageProvider.resolve(ImageConfiguration.empty);
  final Completer<Uint8List?> completer = Completer<Uint8List?>();

  
  late ImageStreamListener listener;

  listener = ImageStreamListener(
    //onImage(completed)
    (ImageInfo imageInfo, bool synchronousCall) async {
      final ui.Image image = imageInfo.image;
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png); // You can choose .jpeg or .png


      if (byteData != null) {
        completer.complete(byteData.buffer.asUint8List());
      } 
      
      else {
        completer.complete(null);
      }

      stream.removeListener(listener); // Clean up the listener
    },
    onError: (Object exception, StackTrace? stackTrace) {
      completer.complete(null);
      stream.removeListener(listener); // Clean up the listener
      debugPrint('Error loading image: $exception');
    },
  );

  stream.addListener(listener);

  return completer.future;
}

Future<String?> getStoragePath({Future<dynamic> Function()? fallbackAction}) async {


  if(Platform.isAndroid){
    final permissionsList = await DocManPermissionManager().list();

    if(permissionsList.isEmpty){
      return await fallbackAction?.call();
    }

    else{

      //重排(大到小)
      permissionsList.sort((pre, next) => next.time.compareTo(pre.time));
    
      //移除任何非最新的 permission(timestamp 依据 time: 1749049336872)
      if(permissionsList.length != 1){
        for(int index = 0; index < permissionsList.length; index++){
          if(index == 0) continue;
          DocManPermissionManager().release(permissionsList[index].uri);
        }
      }


      return permissionsList.first.uri;

    }
  }

  else{
    
    return MyHive.downloadImageDir!.path;
  }

  
}

Future<bool> saveImageFile({
  String? targetWriteInPath,
  Uint8List? selectedDocFileData,
  String? name
}) async {

	if( selectedDocFileData == null || targetWriteInPath == null) return false;
  if (targetWriteInPath.isEmpty)  return false;

  final createdTime = DateTime.now();

  final resultName = "${name ?? "image-${convertDigitNumString(createdTime.year)}-${convertDigitNumString(createdTime.month)}-${convertDigitNumString(createdTime.day)} ${convertDigitNumString(createdTime.hour)}-${convertDigitNumString(createdTime.minute)}-${convertDigitNumString(createdTime.second)}"}.png";

  if(Platform.isAndroid){

    final targetWriteDocument = await DocumentFile.fromUri(targetWriteInPath);


    if((targetWriteDocument?.isDirectory ?? false) && (targetWriteDocument?.canCreate ?? false)){

      targetWriteDocument!.createFile(
        name: resultName,
        bytes: selectedDocFileData
      );

      debugPrint("image $resultName created!");
      return true;
    }
  }


  else{
    Directory targetWriteDirectory = Directory(targetWriteInPath);

    targetWriteDirectory.createSync();

    File targetWriteFile = File("${targetWriteDirectory.path}${Platform.pathSeparator}$resultName");

    targetWriteFile.createSync();
    targetWriteFile.writeAsBytesSync(selectedDocFileData);

    return true;
  }


  return false;

}
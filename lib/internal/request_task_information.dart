import 'dart:async';

import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/internal/utils/convert.dart';
import 'package:bangu_lite/internal/utils/extract.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

class RequestByteInformation{

  String? contentLink;
  
  int? rangeStart;
  int? rangeEnd;
  int? contentLength;

  String? fileName = "pictureName";
  String? contentType;

  String? statusMessage;

  void printInformation() => debugPrint("contentLength:$contentLength fileName:$fileName contentType:$contentType");

}
  
int contentRangeByteParse(String bytesRangeValue){
  // "bytes 0-7/36" => "0-7/36" => "36"
  return int.parse(bytesRangeValue.split(" ")[1].split("/")[1]);
}


Future<RequestByteInformation> loadByteInformation(String imageUrl) async {
  RequestByteInformation pictureRequestInformation = RequestByteInformation();

  //二段流程
  Completer<RequestByteInformation> byteInformationCompleter = Completer();

  await HttpApiClient.client.head(
    imageUrl,
    options: Options(
      headers: HttpApiClient.broswerHeader,
    ))
    //短时请求
    .timeout(const Duration(seconds: 3))
    .then((response){

      if(response.data!=null){
		byteInformationCompleter.complete(extractPictureRequest(response,imageUrl));
      }

    }).catchError((error) async {
		await HttpApiClient.client.head(
			convertProxyImageUri(imageUrl),
			options: Options(
				headers: HttpApiClient.broswerHeader,
			))
			//最终请求
			.timeout(const Duration(seconds: 10))
			.then((response){
				byteInformationCompleter.complete(extractPictureRequest(response,convertProxyImageUri(imageUrl)));
			})
			.catchError((error){

				switch (error.type) {
					case DioExceptionType.badResponse: {
						debugPrint('${convertProxyImageUri(imageUrl)} 图片不存在或拒绝访问'); 
						pictureRequestInformation.statusMessage = "图片不存在或拒绝访问";
						break;
					}
					case DioExceptionType.connectionTimeout:
					case DioExceptionType.sendTimeout:
					case DioExceptionType.receiveTimeout: {
						debugPrint('${convertProxyImageUri(imageUrl)} 超时');
						pictureRequestInformation.statusMessage = "请求超时";
						break;
					}
				}

			
			byteInformationCompleter.complete(pictureRequestInformation);


        });
    });





  return byteInformationCompleter.future;
}
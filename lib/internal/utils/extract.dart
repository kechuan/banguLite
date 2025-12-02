import 'dart:async';
import 'dart:io';

import 'package:bangu_lite/internal/bangumi_define/timeline_const.dart';
import 'package:bangu_lite/internal/request_task_information.dart';
import 'package:bangu_lite/models/informations/subjects/comment_details.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

String extractNameCNData(Map datafield){
  if(datafield["nameCN"] == null) return datafield["name"];
  return datafield["nameCN"].isEmpty ? datafield["name"] : datafield["nameCN"];
}

Map<String, dynamic> extractBaseFields(Map<String, dynamic> data) {
  final resultFields = <String, dynamic>{};

  Set<dynamic> objectIDSet = {};
  Set<String> objectNameSet = {};
  Map<int,Set<String>>? commentReactions = {};

  void recursiveExtract(Map<String, dynamic> map) {
    for (final entry in map.entries) {
      final key = entry.key;
      final value = entry.value;

      if (detectNameList.contains(key)) {

          if(key == 'nickname'){
            //更改昵称 "nickname": {"before": "123","after": "456"}
            if(value is Map){
              objectNameSet.add(value["after"]);
              continue;
            }
          }
        
          if(key == 'name' || key == 'nameCN'){

            //Group 特化 跳转id由 idList 提供 name 直接抛弃,
            //example : {"name": "zyzl","title": "自娱自乐",...}

            //Unhandled Exception: type 'String' is not a subtype of type 'Iterable<dynamic>'

            // 因为API只接收 groupName 跳转 从而一己之力把 objectIDSet 的存储类型 从 int 更改为 dynamic
            if(map['name'] !=null && map['title'] !=null && map['icon'] != null){
              objectNameSet.add(map["title"]);
              objectIDSet.clear();
              objectIDSet.add(map['name']);
              continue;
            }

            String resultText = "";

            if(map['nameCN'] !=null ){
              resultText = 
                map["name"].isEmpty ? 'ep.${map["sort"]}' : 
                  map["nameCN"].isEmpty ? map["name"] : map["nameCN"]
                ;
            }

            

            else{
              resultText = map["name"];
            }

          
            objectNameSet.addAll({resultText});
          }

          else{
            objectNameSet.addAll({value});
          }
      }

      else if(detectIDList.contains(key)){
        int resultID = map[key];
        objectIDSet.addAll({resultID});

      }
      
      else if(detectPropList.contains(key)){

        switch (key) {

          case 'comment' || 'tsukkomi' || 'sign':{
            // [subject]"comment": 56, & "comment":"real user Comment"
            if(value is String && value.isNotEmpty){
              resultFields['comment'] = value;
            }
            
          }

          case 'reactions':{
            commentReactions = loadReactionDetails(value);
            resultFields[key] = commentReactions;
          }

          default:{
            resultFields[key] = value;
          }
            
  
        }
        
      }

      else if (value is Map<String, dynamic>) {
        recursiveExtract(value);
      } 

      else if (value is List) {
        for (final item in value) {
          if (item is Map<String, dynamic>) {
            recursiveExtract(item);
          }
        }
      }
    }

    resultFields['objectIDSet'] = objectIDSet;
    resultFields['objectNameSet'] = objectNameSet;


  }

  recursiveExtract(data);
  return resultFields;
}

Future<String?> extractFallbackToken(InAppWebViewController webViewController) async {

  Completer<String?> tokenCompleter = Completer();

  debugPrint('>>> Attempting to read token from DOM...');
    
    try {
      // Execute JavaScript to get the value of the hidden input
      // Use getElementsByName as the name is consistent
      // [0] gets the first element if multiple exist with the same name
      var token = await webViewController.evaluateJavascript(source: """
        (function() {
          var inputElement = document.getElementsByName('cf-turnstile-response')[0];
          if (inputElement && inputElement.value) {
            return inputElement.value;
          } else {
            return null; // Return null if element not found or value is empty
          }
        })();
      """);

      if (token != null && token.isNotEmpty) {
        debugPrint('>>> Successfully read token from DOM');
        tokenCompleter.complete(token);
      } 
      
      else {
        debugPrint('>>> Token input element not found or value is empty in DOM.');
      }
    } 
    
    catch (e) {
      debugPrint('>>> Error reading token from DOM: $e');
      tokenCompleter.complete();

    }

    return tokenCompleter.future;


}

RequestByteInformation extractPictureRequest(Response response,String imageUrl){
  return RequestByteInformation()
    ..contentLink = imageUrl
    ..fileName = response.headers.value("name")
    ..contentType = response.headers.value(HttpHeaders.contentTypeHeader)
    ..contentLength = int.parse(response.headers.value(HttpHeaders.contentLengthHeader) ?? "0")
    ..statusMessage = response.statusMessage
  ;
}

String extractBBCodeSelectableContent(List<InlineSpan> spans) {
  StringBuffer content = StringBuffer();

  for (InlineSpan span in spans) {
    if (span is TextSpan) {
      
      if (span.text != null) {
        content.write(span.text);
      }
      
      //递归计算子节点长度
      if (span.children != null) {
        for (final child in span.children!) {
          content.write(extractBBCodeSelectableContent([child]));
        }
      }
      
    } 
}
  
  return content.toString();
}
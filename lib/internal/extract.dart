import 'package:bangu_lite/internal/bangumi_define/timeline_const.dart';
import 'package:bangu_lite/models/comment_details.dart';

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
        
          if(key == 'name' || key == 'nameCN'){

            //Group 特化 跳转id由 idList 提供 name 直接抛弃,
            //example : {"name": "zyzl","title": "自娱自乐",...}

            // 因为API只接收 groupName 跳转 从而一己之力把 objectIDSet 的存储类型 从 int 更改为 dynamic
            if(map['name'] !=null && map['title'] !=null){
              objectNameSet.add(map["title"]);
              objectIDSet.addAll(map['name']);
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

          case 'comment' || 'tsukkomi':{
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

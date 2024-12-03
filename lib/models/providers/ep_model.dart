import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/ep_details.dart';
import 'package:flutter/material.dart';

class EpModel extends ChangeNotifier{
  
  EpModel({
    required this.subjectID,
    required this.selectedEp,
  });

  int subjectID;
  int selectedEp;
  

  final List epsData = [];

  final Map<int,List<EpCommentDetails>> epCommentData = {
    1:[
        EpCommentDetails()
          ..userId = 402032
          ..comment = "猫猫的过去全删了啊(bgm38)这段的猫猫直接崩溃掉嘞(bgm38)\n感觉这段还挺重要的，怎么连猫猫是芙蕾雅捡来的和被芙蕾雅主动扔了都没提(bgm38)"
          ..avatarUri = "https://lain.bgm.tv/pic/user/l/000/40/20/402032.jpg?r=1671767546&hd=1"
          ..nickName = "hikki-"
          ..sign = "天の光は全て星だ"
          ..commentTimeStamp = 1731590849

          ..repliedComment = [


            EpCommentDetails()
              ..userId = 123456
              ..comment = "这是一段回复语句"
              ..avatarUri = "https://lain.bgm.tv/pic/user/l/000/40/20/402032.jpg?r=1671767546&hd=1"
              ..nickName = "kechuan"
              ..sign = "这是一段回复签名"
              ..commentTimeStamp = 1731854334,

                      EpCommentDetails()
              ..userId = 123456
              ..comment = "这是一段回复语句"
              ..avatarUri = "https://lain.bgm.tv/pic/user/l/000/40/20/402032.jpg?r=1671767546&hd=1"
              ..nickName = "kechuan"
              ..sign = "这是一段回复签名"
              ..commentTimeStamp = 1731854334,

                        EpCommentDetails()
              ..userId = 123456
              ..comment = "这是一段回复语句"
              ..avatarUri = "https://lain.bgm.tv/pic/user/l/000/40/20/402032.jpg?r=1671767546&hd=1"
              ..nickName = "kechuan"
              ..sign = "这是一段回复签名"
              ..commentTimeStamp = 1731854334,
          ]

        ,

        EpCommentDetails()
          ..userId = 402032
          ..comment = "这是第二段评论"
          ..avatarUri = "https://lain.bgm.tv/pic/user/l/000/40/20/402032.jpg?r=1671767546&hd=1"
          ..nickName = "test2"
          ..sign = "天の光は全て星だ"
          ..commentTimeStamp = 1731590849

          ..repliedComment = [


            EpCommentDetails()
              ..userId = 123456
              ..comment = "这是一段回复语句"
              ..avatarUri = "https://lain.bgm.tv/pic/user/l/000/40/20/402032.jpg?r=1671767546&hd=1"
              ..nickName = "kechuan"
              ..sign = "这是一段回复签名"
              ..commentTimeStamp = 1731854334,

            EpCommentDetails()
              ..userId = 123456
              ..comment = "这是一段回复语句"
              ..avatarUri = "https://lain.bgm.tv/pic/user/l/000/40/20/402032.jpg?r=1671767546&hd=1"
              ..nickName = "kechuan"
              ..sign = "这是一段回复签名"
              ..commentTimeStamp = 1731854334,

            EpCommentDetails()
              ..userId = 123456
              ..comment = "这是一段回复语句"
              ..avatarUri = "https://lain.bgm.tv/pic/user/l/000/40/20/402032.jpg?r=1671767546&hd=1"
              ..nickName = "kechuan"
              ..sign = "这是一段回复签名"
              ..commentTimeStamp = 1731854334,
          ]

      ]
  }; 

  


  void updateSelectedEp(int newEp){
    if(newEp == selectedEp) return;

    selectedEp = newEp;
    notifyListeners();
  }


  //limit > 100 的条件判断 when...
  Future<void> getEpsInformation() async {

    await HttpApiClient.client.get(
      BangumiUrls.eps,
      queryParameters: 
        BangumiQuerys.epQuery
          //..["limit"] = 100
          ..["subject_id"] = subjectID
    ).then((response){
      if(response.data != null && response.data["data"] != null){
        
        List epsDataList = response.data["data"];

        epsData.addAll((epsDataList));

        notifyListeners(); //阶段一

        debugPrint("${epsDataList.length}");
      }
    });

  }

  Future<void> loadEps() async{

    //或者只接收 epIndex 也行 详细信息查找 EpsInformation 的 EpId 就可以了

      if(epsData.isEmpty){
        await getEpsInformation();
        if(epsData.isEmpty) return;
        debugPrint("eps info Load done.");
      }
    
      await HttpApiClient.client.get(
        BangumiUrls.epComment(epsData[selectedEp-1]["id"]),
        
      ).then((response){
        if(response.data != null){

          List epCommentList = response.data;

          List<EpCommentDetails> currentEpCommentList = [];

          for(Map currentEpCommentMap in epCommentList){
            EpCommentDetails currentEpComment = EpCommentDetails();

            currentEpComment
            ..comment = currentEpCommentMap["content"]
            ..commentTimeStamp = currentEpCommentMap["createdAt"]
              ..userId = currentEpCommentMap["user"]["id"]
              ..avatarUri = currentEpCommentMap["user"]["avatar"]["large"]
              ..nickName = currentEpCommentMap["user"]["nickname"]
              ..sign = currentEpCommentMap["user"]["sign"]
            ;

              if(currentEpCommentMap["replies"].isNotEmpty){

                List<EpCommentDetails> currentEpCommentRepliedList = [];

                for(Map currentEpCommentMap in currentEpCommentMap["replies"]){
                  EpCommentDetails currentEpRepliedComment = EpCommentDetails();

                  currentEpRepliedComment
                  ..comment = currentEpCommentMap["content"]
                  ..commentTimeStamp = currentEpCommentMap["createdAt"]
                    ..userId = currentEpCommentMap["user"]["id"]
                    ..avatarUri = currentEpCommentMap["user"]["avatar"]["large"]
                    ..nickName = currentEpCommentMap["user"]["nickname"]
                    ..sign = currentEpCommentMap["user"]["sign"]
                  ;

                  currentEpCommentRepliedList.add(currentEpRepliedComment);
               
                }

                currentEpComment.repliedComment = currentEpCommentRepliedList;

              }

            currentEpCommentList.add(currentEpComment);
          }

          epCommentData[selectedEp] = currentEpCommentList;

          debugPrint("subject ID: $subjectID - Ep.$selectedEp load done ");

          notifyListeners();

        }
      });

  }
  
}
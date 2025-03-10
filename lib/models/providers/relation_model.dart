import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/relation_details.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class RelationModel extends ChangeNotifier{
  RelationModel({
    required this.subjectID
  }){
    loadSubjectRelations();
  }

  final int subjectID;
  final List<RelationDetails> subjectRelationData = [];

  Future<void> loadSubjectRelations({int? offset = 0}) async {

    if(subjectID == 0) return;

    if(subjectRelationData.isNotEmpty){
      debugPrint("Relations already loaded");
      return;
    }

    try{

      await HttpApiClient.client.get(
        BangumiAPIUrls.relations(subjectID),
      ).then((response){
        if(response.data != null){

          if((response.data["total"] ?? 0) == 0){
            debugPrint("subject $subjectID has no relations");
            subjectRelationData.addAll([RelationDetails()..relationID = 0]);
          }

          else{
            subjectRelationData.addAll(loadRelationDetails(response.data));
          }

          notifyListeners();

        }


      });


    }

    on DioException catch(e){
      debugPrint("Request Error:${e.toString()}");
    }

  }

  


}
import 'package:bangu_lite/models/informations/subjects/bangumi_details.dart';
import 'package:bangu_lite/models/informations/subjects/base_info.dart';

class RelationDetails extends ContentInfo {
  RelationDetails();

  BangumiDetails? subjectDetail;

  String? description;

  factory RelationDetails.empty() => RelationDetails()..sourceID = 0;

}


List<RelationDetails> loadRelationDetails(
  Map<String,dynamic> bangumiRelationsData
){

	final List<RelationDetails> subejctRelationsList = [];

  List<dynamic> bangumiRelationsDataList = bangumiRelationsData["data"];

	for(Map subejctRelationsMap in bangumiRelationsDataList){
    RelationDetails currentRelationDetail = RelationDetails();

		currentRelationDetail
      ..subjectDetail = loadRelationsData(subejctRelationsMap["subject"])
      ..sourceID = subejctRelationsMap["relation"]["id"]
      ..contentTitle = subejctRelationsMap["relation"]["cn"]
      ..description = subejctRelationsMap["relation"]["desc"]
    ;

		subejctRelationsList.add(currentRelationDetail);
	} 

	 return subejctRelationsList;

}

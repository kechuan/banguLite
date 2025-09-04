import 'package:bangu_lite/models/informations/subjects/bangumi_details.dart';
import 'package:bangu_lite/models/informations/subjects/base_info.dart';

class RelationDetails extends BaseInfo{
  RelationDetails();

  BangumiDetails? subjectDetail;

  int? relatedID;
  String? name;
  String? description;

  factory RelationDetails.empty() => RelationDetails()..relatedID = 0;

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
      ..relatedID = subejctRelationsMap["relation"]["id"]
      ..relatedID = subejctRelationsMap["relation"]["id"]
      ..name = subejctRelationsMap["relation"]["cn"]
      ..description = subejctRelationsMap["relation"]["desc"]
    ;

		subejctRelationsList.add(currentRelationDetail);
	} 

	 return subejctRelationsList;

}

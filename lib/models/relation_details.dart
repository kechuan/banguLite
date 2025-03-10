import 'package:bangu_lite/models/bangumi_details.dart';

class RelationDetails{
  BangumiDetails? subjectDetail;

  int? relationID;
  String? name;
  String? description;

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
      ..relationID = subejctRelationsMap["relation"]["id"]
      ..relationID = subejctRelationsMap["relation"]["id"]
      ..name = subejctRelationsMap["relation"]["cn"]
      ..description = subejctRelationsMap["relation"]["desc"]
    ;

		subejctRelationsList.add(currentRelationDetail);
	} 

	 return subejctRelationsList;

}

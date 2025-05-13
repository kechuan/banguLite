import 'package:bangu_lite/models/informations/subjects/bangumi_details.dart';
import 'package:bangu_lite/models/informations/subjects/base_info.dart';

class RelationDetails extends BaseInfo{
  RelationDetails();

  BangumiDetails? subjectDetail;

  int? relationID;
  String? name;
  String? description;

  factory RelationDetails.empty() => RelationDetails()..relationID = 0;

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

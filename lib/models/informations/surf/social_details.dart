
class SocialDetails{
  String? name;
  String? url;
  String? tileColor;
  String? account;
}

List<SocialDetails> loadSocialDetails(List bangumiSocialDetailsDataList){
  final List<SocialDetails> socialDetails = [];

  for(var bangumiSocialDetailsData in bangumiSocialDetailsDataList){
    socialDetails.add(
      SocialDetails()
        ..name = bangumiSocialDetailsData["name"]
        ..url = bangumiSocialDetailsData["url"]
        ..tileColor = bangumiSocialDetailsData["color"]
        ..account = bangumiSocialDetailsData["account"]
    );
  }

  return socialDetails;
}
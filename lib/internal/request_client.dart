
import 'package:bangu_lite/internal/convert.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:github/github.dart';


class HttpApiClient{
  static final client = Dio();
  static BaseOptions clientOption = Dio().options;

  static Map<String,String> broswerHeader = {
    //"referer": 'https://www.bilibili.com',
    "User-Agent": 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36',

  };

  static void init(){
    HttpApiClient.clientOption.baseUrl = BangumiAPIUrls.baseUrl;
    HttpApiClient.clientOption.headers = HttpApiClient.broswerHeader;
    HttpApiClient.client.options = HttpApiClient.clientOption;
  }

}

class BangumiAPIUrls {
  static const String baseUrl = "https://api.bgm.tv";
  static const String baseResourceUrl = "https://lain.bgm.tv";

  static const String calendar = '$baseUrl/calendar';   

  static const String subject = '$baseUrl/v0/subjects';
  static const String eps = '$baseUrl/v0/episodes';
  static const String search = '$baseUrl/search/subject';

  static const String bangumiSubjectSort = '$baseUrl/v0/search/subjects';

  //以v1为代表的新api
  static const String newUrl = "https://next.bgm.tv";

  //subject
  static String comment(int subjectID) => '$newUrl/p1/subjects/$subjectID/comments';
  static String ep(int epID) => '$newUrl/p1/episodes/$epID';
  static String epComment(int epID) => '$newUrl/p1/episodes/$epID/comments';
  static String topics(int subjectID) => '$newUrl/p1/subjects/$subjectID/topics';
  static String topicComment(int topicID) => '$newUrl/p1/subjects/-/topics/$topicID';
  static String relations(int subjectID) => '$newUrl/p1/subjects/$subjectID/relations';
  static String reviews(int subjectID) => '$newUrl/p1/subjects/$subjectID/reviews';

  //user
  static String me = '$newUrl/p1/me';

  static String user(String username) => '$newUrl/p1/users/$username';
  static String userBlog(int blogID) => '$newUrl/p1/blogs/$blogID';
  static String userTimeline(String username) => '${user(username)}/timeline';
  
  static String blogComment(int blogID) => '${userBlog(blogID)}/comments';

  //user-relation
  static String addBlockList(String username) => '$newUrl/p1/blocklist/$username';
  static String removeBlockList(String username) => '$newUrl/p1/blocklist/$username';
  static String addFriend(String username) => '$newUrl/p1/friends/$username';
  static String removeFriend(String username) => '$newUrl/p1/friends/$username';


  //other
  static String imgur(String imageSuffix) => '$baseResourceUrl/pic/photo/l/$imageSuffix';
  static String imgurThumbnail(
    String imagePath,
    {
      int width = 0,
      int height = 0,
    }
  ) => '$baseResourceUrl/r/${width}x${height}/$imagePath';

}

class BangumiWebUrls{
  static const String baseUrl = "https://bangumi.tv";
  static const String relativeUrl = "https://bgm.tv";

  static String login() => '$baseUrl/login';

  static String subject(int subjectID) => '$baseUrl/subject/$subjectID';
  static String subjectComment(int subjectID) => '$baseUrl/subject/$subjectID/comments';
  static String subjectTopic(int topicID) => '$baseUrl/subject/topic/$topicID';

  static String ep(int epID) => '$baseUrl/ep/$epID';
  static String user(String username) => '$baseUrl/user/$username';
  static String userBlog(int blogID) => '$baseUrl/blog/$blogID';

  static String relativeSubject(int subjectID) => '$relativeUrl/subject/$subjectID';
  static String relativeSubjectComment(int subjectID) => '$relativeUrl/subject/$subjectID/comments';
  static String relativeSubjectTopic(int topicID) => '$relativeUrl/subject/topic/$topicID';
  static String relativeEp(int epID) => '$relativeUrl/ep/$epID';

  static String webAuthPage(){
    final entries =  BangumiQuerys.authorizationQuery().entries;
        
    final authParams = 
      entries.map((entry) =>'${entry.key}=${entry.value}')
      .toList()
      .join('&');

    return '${BangumiWebUrls.oAuth}?$authParams';
  }


  static const String oAuth = '$relativeUrl/oauth/authorize';
  static const String oAuthToken = '$relativeUrl/oauth/access_token';

}

class BangumiQuerys {

	static Map<String,String> authorizationQuery() => {
		"client_id":APPInformationRepository.bangumiAPPID,
		"response_type":"code",
		"chii_referer":APPInformationRepository.bangumiAuthCallbackUri.toString(),
		"client_secret":APPInformationRepository.bangumiAPPSecret,
	};

  	static Map<String,String> getAccessTokenQuery(
		String code,
	) => {
		"grant_type":'authorization_code',
		"client_id":APPInformationRepository.bangumiAPPID,
		"client_secret":APPInformationRepository.bangumiAPPSecret,
		"code":code,
		"redirect_uri":'banguLite://oauth/bgm_login?client_id=bgm369067d8f39dea8d4',
		"accept": "application/json"
	};

	static Map<String,String> bearerTokenAccessQuery(String accessToken) => {
		"Authorization": 'Bearer $accessToken',
		"accept": "application/json"
	};

	static Map<String,String> refreshTokenQuery(String refreshToken) => {
		"grant_type": 'refresh_token',
		"client_id":APPInformationRepository.bangumiAPPID,
		"client_secret":APPInformationRepository.bangumiAPPSecret,
		"refresh_token":refreshToken,
		"redirect_uri":'banguLite://oauth/bgm_login?client_id=bgm369067d8f39dea8d4',
		"accept": "application/json",
	};

	static Map<String,dynamic> searchQuery = {
		"type":2,
		"responseGroup":"small",
		"start":0,
		"max_results":10
	};


  static Map<String,int>  commentQuery = {"limit":10,"offset":0},
                          sortQuery = {"limit":10,"offset":0},
                          topicsQuery = {"limit":30,"offset":0},
                          epQuery = {"subject_id":0,"limit":100,"offset":0},
                          relationsQuery = {"type":2,"limit":20,"offset":0},
                          reviewsQuery = {"limit":20,"offset":0},
                          timelineQuery = {"limit":3}
  ;
                             

  
}

class BangumiDatas {

  //神奇的数据装载。。 rank方面的数据 还不如拆分成 minRank & maxRank 。。
  static Map<String,dynamic> get sortData => {
    "keyword": '',
    "sort": 'rank',
    "filter": {
      "type": [2],
      "tag": [],
      "rank": [">2", "<=99999"],
      "air_date": [">=2016-01-01","<${DateTime.now().toString().substring(0,10)}"],
      "rating": [">=5","<9"],
      "nsfw": false,
    }
  };
}

class APPInformationRepository{
  static const String link = "https://github.com/kechuan/banguLite/releases",
                      projectName = "banguLite",
                      packageName = "io.flutter.banguLite",
                      version = "0.6.1",
                      author = "kechuan"
  ;
  
  
  static const String bangumiAPPID = 'bgm369067d8f39dea8d4';
  static const String bangumiAPPSecret = 'e34be838faee529cb7df1bad76a66db3';

  static final Uri bangumiAuthCallbackUri = Uri.parse('bangulite://oauth/bgm_login?client_id=$bangumiAPPID');
}

Future<Release?> pullLatestRelease() async {

  final github = GitHub();
  Release? latestRelease;

  try {

    await github.repositories.getLatestRelease(RepositorySlug(APPInformationRepository.author, APPInformationRepository.projectName)).then((release){
      if(APPInformationRepository.version == release.tagName) return latestRelease;
      latestRelease = release;
    });

  } 
  
  catch (e) {
    debugPrint('获取 tags 时出错: $e');
  }

  return latestRelease; 

}

void downloadSticker() async {  
  await Future.wait(
    List.generate(
      126, (index){

        if(index == 0) return Future((){});

        String suffix = "gif"; 
        
        if(index < 24){
          suffix = "png";
          if(index == 11 || index == 23) suffix = "gif";
        }

        return HttpApiClient.client.download(
          "https://bgm.tv/img/smiles/${index > 23 ? "tv" : "bgm"}/${convertDigitNumString(index > 23 ? index-23 : index)}.$suffix",
          './assets/sticker/bangumiSticker/bgm${convertDigitNumString(index)}.gif',
        );
       
      }
    )
  );

}


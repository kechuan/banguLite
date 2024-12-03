
import 'package:dio/dio.dart';


class HttpApiClient{
  static final client = Dio();
  static BaseOptions clientOption = Dio().options;

  static Map<String,String> broswerHeader = {
    //"referer": 'https://www.bilibili.com',
    "User-Agent": 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36',

  };

  static void init(){
    HttpApiClient.clientOption.baseUrl = BangumiUrls.baseUrl;
    HttpApiClient.clientOption.headers = HttpApiClient.broswerHeader;
    HttpApiClient.client.options = HttpApiClient.clientOption;
  }

}

class BangumiUrls {
  static const String baseUrl = "https://api.bgm.tv";

  //static String get subject => '$baseUrl/subject';
  static String get calendar => '$baseUrl/calendar';

  static String get subject => '$baseUrl/v0/subjects';
  static String get eps => '$baseUrl/v0/episodes';

  static String get search => '$baseUrl/search/subject';


  static const String bangumiSubjectSort = '$baseUrl/v0/search/subjects';

  //以v1为代表的新api
  static const String newUrl = "https://next.bgm.tv";

  static String comment(int subjectID) => '$newUrl/p1/subjects/$subjectID/comments';
  static String epComment(int epID) => '$newUrl/p1/subjects/-/episode/$epID/comments';

}

class BangumiQuerys {

  static Map<String,dynamic> get searchQuery => {
    "type":2,
    "responseGroup":"small",
    "start":0,
    "max_results":10
  };


  static Map<String,int>  commentQuery = {"limit":10,"offset":0},
                          sortQuery = {"limit":10,"offset":0},
                          epQuery = {"subject_id":0,"limit":100,"offset":0}
                          ;
                             

  //神奇的数据装载。。 rank方面的数据 还不如拆分成 minRank & maxRank 。。
}

class BangumiDatas {
  static Map<String,dynamic> get sortData => {
    "keyword": '',
    "sort": "rank",
    "filter": {
      "type": [2],
      "tag": [],
      "rank": [">2", "<=99999"],
      "air_date": [">=2016-01-01","<2024-04-01"],
      "rating": [">=5","<9"],
      "nsfw": false,
    }
  };
}
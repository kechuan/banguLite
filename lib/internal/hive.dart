import 'dart:io';

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';


class MyHive {
  const MyHive._();

  //Hive需要什么?
  //需要一个具体的地方存储数据

  static late final Directory filesDir; //存储目录

//嗯。。首先是。。 Map{ 
//Storage Information ID : {name,totalCount,UpdateTime}, 
// then.. load page will check the ID. return the bangumiDetails
////}

  //static late final Box<MusicInformationRecord> musicInformationDataBase; //存储目标
  //static late final Box<List> playListDataBase; //存储目标
  //static late final Box<Duration?> playQueueDataBase;


  static late final Box<Map> starBangumisDataBase;


  static Future<void> init() async {

    if(Platform.isAndroid){

      //filesDir = Directory('storage/emulated/0/Download/flusic');
      //指向 /data/data/<package_name>/files
      filesDir = await getApplicationDocumentsDirectory();
    }
    
    else{
      filesDir = Directory('.${Platform.pathSeparator}');
    }
    
    Hive.init('${filesDir.path}${Platform.pathSeparator}hivedb');


    starBangumisDataBase = await Hive.openBox(HiveBoxKey.starBangumisDataBase);

  }

}

class HiveBoxKey {
  const HiveBoxKey._();

  //Dart 允许这么简便书写
  static const String starBangumisDataBase = 'starBangumisDataBase';
}


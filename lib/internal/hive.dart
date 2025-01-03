import 'dart:io';

import 'package:bangu_lite/hive/config_model.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:bangu_lite/hive/hive_registrar.g.dart';


class MyHive {
  const MyHive._();

  //Hive需要什么?
  //需要一个具体的地方存储数据

  static late final Directory filesDir; //存储目录
  static late final Directory cachedImageDir;
  static late final Directory? downloadDir;

  static late final Box<Map> starBangumisDataBase;
  static late final Box<AppConfig> appConfigDataBase;

  static Future<void> init() async {

    if(Platform.isAndroid){

      //指向 /data/data/<package_name>/files
      filesDir = await getApplicationDocumentsDirectory();

      downloadDir = await getDownloadsDirectory();

      //指向 /data/data/<package_name>/cache
      await getApplicationCacheDirectory().then((directory){
        cachedImageDir = Directory('${directory.path}${Platform.pathSeparator}libCachedImageData');
      });
      
      
    }
    
    else{

      //指向 exe运行同目录
      filesDir = Directory('.${Platform.pathSeparator}');

      //指向 X:\Users\<user_name>\AppData\Local\Temp\libCachedImageData
      await getTemporaryDirectory().then((directory){
        cachedImageDir = Directory('${directory.path}${Platform.pathSeparator}libCachedImageData');
      });

      downloadDir = await getDownloadsDirectory();

    }
    
    Hive
      ..init('${filesDir.path}${Platform.pathSeparator}hivedb')
      ..registerAdapters()
      
    ;


    starBangumisDataBase = await Hive.openBox(HiveBoxKey.starBangumisDataBase);
    appConfigDataBase = await Hive.openBox(HiveBoxKey.appConfigDataBase);

  }

}

class HiveBoxKey {
  const HiveBoxKey._();

  //Dart 允许这么简便书写
  static const String starBangumisDataBase = 'starBangumisDataBase',
                      appConfigDataBase = 'appConfigDataBase';
}

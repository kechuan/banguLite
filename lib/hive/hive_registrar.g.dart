// Generated by Hive CE
// Do not modify
// Check in to version control

import 'package:hive_ce/hive.dart';
import 'package:bangu_lite/hive/hive_adapters.dart';

extension HiveRegistrar on HiveInterface {
  void registerAdapters() {
    registerAdapter(AppConfigAdapter());
    registerAdapter(BangumiThemeColorAdapter());
    registerAdapter(ScaleTypeAdapter());
    registerAdapter(ThemeModeAdapter());
  }
}

import 'package:bangu_lite/internal/const.dart';

import 'package:bangu_lite/models/star_details.dart';
import 'package:bangu_lite/models/timeline_details.dart';
import 'package:bangu_lite/models/user_details.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'config_model.dart';

part 'hive_adapters.g.dart';

@GenerateAdapters(
  [
    AdapterSpec<AppConfig>(),
    AdapterSpec<AppThemeColor>(),
    AdapterSpec<ThemeMode>(),
    AdapterSpec<ScaleType>(),
    AdapterSpec<Color>(),
    AdapterSpec<StarBangumiDetails>(),
    AdapterSpec<UserInformation>(),
    AdapterSpec<LoginedUserInformations>(),
    AdapterSpec<TimelineDetails>()
  ]    
)
// Annotations must be on some element
// ignore: unused_element
void _() {}

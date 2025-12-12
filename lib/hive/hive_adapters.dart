import 'package:bangu_lite/internal/bangumi_define/bangumi_social_hub.dart';
import 'package:bangu_lite/internal/bangumi_define/content_status_const.dart';
import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/models/informations/subjects/comment_details.dart';

import 'package:bangu_lite/models/informations/local/star_details.dart';
import 'package:bangu_lite/models/informations/surf/surf_timeline_details.dart';
import 'package:bangu_lite/models/informations/surf/user_details.dart';
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
    AdapterSpec<BangumiSurfTimelineType>(),
    AdapterSpec<StarBangumiDetails>(),
    AdapterSpec<UserInformation>(),
    AdapterSpec<LoginedUserInformations>(),
    AdapterSpec<SurfTimelineDetails>(),
    AdapterSpec<CommentDetails>(),
    AdapterSpec<StarType>(),
    
  ]    
)
// Annotations must be on some element
// ignore: unused_element
void _() {}

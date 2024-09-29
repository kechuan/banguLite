

import 'package:bangu_lite/internal/hive.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bangu_lite/flutter_bangumi_routes.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/providers/bangumi_model.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:bangu_lite/routes/flutter_bangumi_route.dart';
import 'package:provider/provider.dart';

void main() async {

  if (kReleaseMode) {
      debugPrint = (String? message, {int? wrapWidth}) {};
    }

  //Dio初始化
  HttpApiClient.init();
  await MyHive.init();

  runApp(const MainApp());

}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BangumiModel()),
        ChangeNotifierProvider(create: (_) => IndexModel()),
      ],
      child: MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 140, 205, 244)),
          fontFamily: 'MiSansFont'
        ),
        initialRoute: Routes.index,
        
        onGenerateRoute: (RouteSettings settings) {
          return onGenerateRoute(
            settings: settings,
            getRouteSettings: getRouteSettings,
          );
        },

      
      ),
    );
  }
}

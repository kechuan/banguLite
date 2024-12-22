import 'dart:io';

import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/hive.dart';
import 'package:bangu_lite/internal/lifecycle.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:bangu_lite/routes/bangu_lite_route.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() async {

  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  // path_provider 初始化需要
  WidgetsFlutterBinding.ensureInitialized();

  HttpApiClient.init();
  await MyHive.init();

  if(Platform.isAndroid){
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,  // 使用 edgeToEdge 模式
    );

	SystemChrome.setSystemUIOverlayStyle(
		const SystemUiOverlayStyle(
			systemNavigationBarColor: Colors.transparent,
			systemNavigationBarDividerColor: Colors.transparent,
		),
	);
  }

  runApp(const MainApp());

}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(
      create: (_) => IndexModel(),
      child: Builder(
        builder: (context) {
          return MaterialApp(
            theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: BangumiThemeColor.sea.color),
                fontFamily: 'MiSansFont',
            ),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                fontFamily: 'MiSansFont',
                colorScheme: ColorScheme.dark(
                  primary: BangumiThemeColor.sea.color,
                  onPrimary: Colors.white, //unSelected颜色
                  secondary: Colors.white,
                  onSecondary:BangumiThemeColor.sea.color, //onSelected 的颜色
                  surface: Colors.black,
                  
                  outline: Colors.white,
                    
          
                )
              ),
              themeMode: context.watch<IndexModel>().themeMode,
              
            initialRoute: Routes.index,
            //navigatorObservers: [],
            navigatorObservers: [Lifecycle.lifecycleRouteObserver],
            onGenerateRoute: (RouteSettings settings) {
              return onGenerateRoute(
                settings: settings,
                getRouteSettings: getRouteSettings,
              );
            },
          
          
          );
        }
      ),
    );
  }
}

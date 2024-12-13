import 'dart:io';

import 'package:bangu_lite/internal/hive.dart';
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
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent
      )
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
      child: MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 140, 205, 244)),
          fontFamily: 'MiSansFont',
        ),
        initialRoute: Routes.index,
        //navigatorObservers: [],
        navigatorObservers: [RouteObserver<ModalRoute>()],
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


import 'dart:async';

import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';
import 'package:bangu_lite/widgets/index_landscape.dart';
import 'package:bangu_lite/widgets/index_portial.dart';
import 'package:flutter/services.dart';


@FFRoute(name: '/index')

class BangumiIndexPage extends StatelessWidget {
  BangumiIndexPage({super.key});

  final ValueNotifier<int> selectedPageIndexNotifier = ValueNotifier<int>(0);

  

  @override
  Widget build(BuildContext context) {
    bool readyQuitFlag = false;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (popStatus, result) async {
        debugPrint("popStaus:$popStatus, result:$result");

        if(!readyQuitFlag){

          readyQuitFlag = true;

          Future.delayed(const Duration(seconds: 3)).then((value){
            ScaffoldMessenger.maybeOf(context)?.clearSnackBars();
            readyQuitFlag = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor:Color.fromARGB(255, 140, 205, 244),
              content: Text("再返回一次以退出"),
            )
          );
          
        }

        else{
          await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        }

      },
      child: OrientationBuilder(
        builder: (_,orientation){
          return orientation == Orientation.portrait ?
          IndexPortial(selectedPageIndexNotifier: selectedPageIndexNotifier) :
          IndexLandscape(selectedPageIndexNotifier: selectedPageIndexNotifier);
        }
      ),
    );
  }
}

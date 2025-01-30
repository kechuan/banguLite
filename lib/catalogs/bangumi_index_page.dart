
import 'dart:async';

import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';
import 'package:bangu_lite/widgets/index_landscape.dart';
import 'package:bangu_lite/widgets/index_portial.dart';
import 'package:flutter/services.dart';

@FFRoute(name: '/index')

class BangumiIndexPage extends StatefulWidget {
  const BangumiIndexPage({super.key});

  @override
  State<BangumiIndexPage> createState() => _BangumiIndexPageState();
}

class _BangumiIndexPageState extends State<BangumiIndexPage> {
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

          final messager = ScaffoldMessenger.maybeOf(context);

          Future.delayed(const Duration(seconds: 3)).then((value){
            messager?.clearSnackBars();
            readyQuitFlag = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor:Color.fromARGB(240, 99, 188, 243),
              content: ScalableText("再返回一次以退出",style: TextStyle(color: Colors.black)),
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

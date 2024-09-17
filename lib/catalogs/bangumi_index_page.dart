
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bangumi/delegates/wrapSliverPersistentHeaderDelegate.dart';
import 'package:flutter_bangumi/widgets/index_landscape.dart';
import 'package:flutter_bangumi/widgets/index_portial.dart';


@FFRoute(name: '/index')

class BangumiIndexPage extends StatelessWidget {
  BangumiIndexPage({super.key});

  final ValueNotifier<int> selectedPageIndexNotifier = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (_,orientation){
        return orientation == Orientation.portrait ?
        IndexPortial(selectedPageIndexNotifier: selectedPageIndexNotifier) :
        IndexLandscape(selectedPageIndexNotifier: selectedPageIndexNotifier);
      }
    );
  }
}

class DatePersistentHeader extends StatelessWidget{

  const DatePersistentHeader({
    super.key,
    this.title,
    this.rowChild = const SizedBox.shrink(),
    this.focusNode
  });

  final String? title;

  final Widget rowChild;

  final FocusNode? focusNode;
  
  @override
  Widget build(BuildContext context){

    return SliverPersistentHeader(
      floating:true,
      delegate: WrapSliverPersistentHeaderDelegate(
        minExtent: 30,
        maxExtent: 30,
        onBuild: (_,shrinkOffset,overlapsContent){

          if(overlapsContent) {
            if(focusNode!=null){
              debugPrint("$shrinkOffset");
              if(shrinkOffset==30.0){
                focusNode!.unfocus();
              }
            }
            
            return const SizedBox.shrink();
          }

          return Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text(title??"",style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              rowChild
            ],
          );
        }
      )
    );

  }
}
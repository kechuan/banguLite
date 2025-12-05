import 'dart:math';

import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/catalogs/index/bangumi_star_page.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:bangu_lite/widgets/components/app_drawer.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:flutter/material.dart';
import 'package:bangu_lite/catalogs/index/bangumi_calendar_page.dart';
import 'package:bangu_lite/catalogs/index/bangumi_sort_page.dart';
import 'package:bangu_lite/delegates/search_delegates.dart';
import 'package:provider/provider.dart';

class IndexPortial extends StatefulWidget {
  const IndexPortial({
    super.key,
    required this.selectedPageIndexNotifier,
  });

  final ValueNotifier<int> selectedPageIndexNotifier;

  @override
  State<IndexPortial> createState() => _IndexPortialState();
}

class _IndexPortialState extends State<IndexPortial> {

  final PageController pageController = PageController();

  @override
  void initState() {
    widget.selectedPageIndexNotifier.addListener(() {
      pageController.animateToPage(widget.selectedPageIndexNotifier.value,duration: const Duration(milliseconds: 300),curve: Curves.easeOut);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final indexModel = context.read<IndexModel>();

    return ValueListenableBuilder(
      valueListenable: widget.selectedPageIndexNotifier,
      builder: (_,currentPageIndex,railLeading) {

        return Scaffold(
          drawerEnableOpenDragGesture: true,
          appBar: AppBar(
            //leading: const ToggleThemeModeButton(),
            leading:  Builder(
              builder: (context) {
                return IconButton(
                  onPressed: ()=>Scaffold.of(context).openDrawer(),
                  icon: const Icon(Icons.menu)
                );
              }
            ),
            flexibleSpace: const Column(
              children: [
                 Spacer(),
                 Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.live_tv_rounded,size: 32),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 12)),
                      ScalableText("BanguLite"),
                    ],
                  ),

                 Padding(padding: EdgeInsets.only(bottom: 12))
              
              ],
            ),
            
            actions: [
              IconButton(
                onPressed: ()=> showSearch(context: context,delegate: CustomSearchDelegate()),
                icon: const Icon(Icons.search)
              ),

              IconButton(
                onPressed: (){
                  indexModel.updateCachedSize();
                  Navigator.pushNamed(context,Routes.settings);
                },
                icon: const Icon(Icons.settings)
              )
            ],
          ),
          drawer: Drawer(
            width: min(350, MediaQuery.sizeOf(context).width*3/4),
            child: const AppDrawer()
          ),
          body: Builder(
            builder: (context) {
              return PopScope(
                onPopInvokedWithResult: (didPop, result) {
                  if(Scaffold.of(context).isDrawerOpen){
                    Scaffold.of(context).closeDrawer();
                    return;
                  }
                },
                child:PageView(
                  
                  controller: pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: const [
                    BangumiCalendarPage(),
                    BangumiSortPage(),
                    BangumiStarPage()
                  ],
                )
              );
            }
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: currentPageIndex,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.local_fire_department_outlined),
                selectedIcon: Icon(Icons.local_fire_department_rounded),
                label: '番剧',
              ),
      
              NavigationDestination(
                icon: Icon(Icons.filter_alt_outlined),
                selectedIcon: Icon(Icons.filter_alt),
                label: '筛选',
              ),

              NavigationDestination(
                icon: Icon(Icons.star_border),
                selectedIcon: Icon(Icons.star),
                label: '收藏',
              )
            ],
            //onDestinationSelected: (newIndex)=> selectedPageIndexNotifier.value = newIndex,
            onDestinationSelected: (newIndex){
              FocusScope.of(context).unfocus();

              
              widget.selectedPageIndexNotifier.value = newIndex;
            },
          ),
        );
    
      }
    );
  }
}
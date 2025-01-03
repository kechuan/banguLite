import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/catalogs/bangumi_star_page.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/fragments/toggle_theme_mode_button.dart';
import 'package:flutter/material.dart';
import 'package:bangu_lite/catalogs/bangumi_calendar_page.dart';
import 'package:bangu_lite/catalogs/bangumi_sort_page.dart';
import 'package:bangu_lite/delegates/search_delegates.dart';
import 'package:provider/provider.dart';

class IndexPortial extends StatelessWidget {
  const IndexPortial({
    super.key,
    required this.selectedPageIndexNotifier,
  });

  final ValueNotifier<int> selectedPageIndexNotifier;

  @override
  Widget build(BuildContext context) {

    final indexModel = context.read<IndexModel>();

    return ValueListenableBuilder(
      valueListenable: selectedPageIndexNotifier,
      builder: (_,currentPageIndex,railLeading) {

        return Scaffold(
          appBar: AppBar(
            leading: const ToggleThemeModeButton(),
            //leadingWidth: 0,
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
          body: IndexedStack(
            index: currentPageIndex,
            children: const [
              BangumiCalendarPage(),
              BangumiSortPage(),
              BangumiStarPage()
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: currentPageIndex,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.local_fire_department_outlined),
                selectedIcon: Icon(Icons.local_fire_department_rounded),
                label: "资讯",
              ),
      
              NavigationDestination(
                icon: Icon(Icons.filter_alt_outlined),
                selectedIcon: Icon(Icons.filter_alt),
                label: "筛选",
              ),

              NavigationDestination(
                icon: Icon(Icons.rss_feed_outlined),
                selectedIcon: Icon(Icons.rss_feed),
                label: "订阅",
              )
            ],
            onDestinationSelected: (newIndex)=> selectedPageIndexNotifier.value = newIndex,
          ),
        );
    
      }
    );
  }
}
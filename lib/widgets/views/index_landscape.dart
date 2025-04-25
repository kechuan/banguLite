import 'dart:math';

import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/catalogs/index/bangumi_star_page.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:bangu_lite/widgets/components/app_drawer.dart';
import 'package:bangu_lite/widgets/fragments/app_user_avatar.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/fragments/toggle_theme_mode_button.dart';
import 'package:flutter/material.dart';
import 'package:bangu_lite/catalogs/index/bangumi_calendar_page.dart';
import 'package:bangu_lite/catalogs/index/bangumi_sort_page.dart';
import 'package:bangu_lite/delegates/search_delegates.dart';
import 'package:provider/provider.dart';

class IndexLandscape extends StatelessWidget {
  const IndexLandscape({
    super.key,
    required this.selectedPageIndexNotifier,
  });

  final ValueNotifier<int> selectedPageIndexNotifier;

  @override
  Widget build(BuildContext context) {

    final ValueNotifier<bool> expandedMenuNotifier = ValueNotifier(false);

    final indexModel = context.read<IndexModel>();
    
    
    return ValueListenableBuilder(
      valueListenable: selectedPageIndexNotifier,
      builder: (_,currentPageIndex,railLeading) {


        return LayoutBuilder(
          builder: (_,constraint) {
            
            return Row(
              children: [
            
                NavigationRail(
                  groupAlignment: -1.0,
                  labelType: NavigationRailLabelType.all,
                  selectedIndex: currentPageIndex,
                  leading: railLeading!,
                  trailing: Builder(
                    builder: (_) {
                      
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        spacing: 32,
                        children: [

                          Padding(
                            padding: EdgeInsets.only(top: max(0,constraint.maxHeight-658))
                          ),

                          const SizedBox(
                            height: 30,
                            width: 30,
                            child: AppUserAvatar()
                          ),

                          const ToggleThemeModeButton(),
                      
                          InkResponse(
                            onTap: () {
                              indexModel.updateCachedSize();
                              Navigator.pushNamed(context,Routes.settings);
                            },
                            child: Icon(Icons.settings,size: min(30,MediaQuery.sizeOf(context).width/15)),
                          ),
                      
                      
                        ],
                      );
                    }
                  ),
                
                  destinations: const [
                        
                    NavigationRailDestination(
                      icon: Icon(Icons.local_fire_department_outlined),
                      selectedIcon: Icon(Icons.local_fire_department_rounded),
                      label: ScalableText('番剧')
                    ),
                        
                    NavigationRailDestination(
                      icon: Icon(Icons.filter_alt_outlined),
                      selectedIcon: Icon(Icons.filter_alt),
                      label: ScalableText('筛选')
                    ),
                
                    NavigationRailDestination(
                      icon: Icon(Icons.star_border),
                      selectedIcon: Icon(Icons.star),
                      label: ScalableText('收藏')
                    ),
                
                
                  ],
                  onDestinationSelected: (newIndex){
                    FocusScope.of(context).unfocus();
                    selectedPageIndexNotifier.value = newIndex;
                  }
                ),
            
                const VerticalDivider(width: 1),
            
                Expanded(
                  child: Stack(
                    children: [

                      IndexedStack(
                        index: currentPageIndex,
                        children: const [
                          BangumiCalendarPage(),
                          BangumiSortPage(),
                          BangumiStarPage()
                        ],
                      ),

                      ValueListenableBuilder(
                        valueListenable: expandedMenuNotifier,
                        builder: (_,menuExpandedStatus,menu) {
                          return AnimatedPositioned(
                            left: menuExpandedStatus ? 0 : -350,
                            width: min(350, MediaQuery.sizeOf(context).width*3/4),
                            height: MediaQuery.sizeOf(context).height,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                            child: menu!
                            
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Material(
                            color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.9),
                            child: const AppDrawer()
                          )
                        ),
                      )


                    ],
                  ),
                )
                
              ],
            );
          }
        );
      },
      child: Padding( 
        padding: const EdgeInsets.symmetric(vertical: 25),
        child: Column(
          spacing: 24,
          children: [

            const Column(
              
              children: [
                Icon(Icons.live_tv_rounded),
                ScalableText("BanguLite"),
              ],
            ),


            IconButton(
              onPressed: ()=> expandedMenuNotifier.value = !expandedMenuNotifier.value,
              icon: const Icon(Icons.menu)
            ),
            

            IconButton(
              onPressed: ()=> showSearch(
                context: context,
                delegate: CustomSearchDelegate()
              ),
              icon: const Icon(Icons.search)
            ),
              
          ],
        ),
      ),
      
      
    );
    
  }
}
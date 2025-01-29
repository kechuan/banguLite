import 'dart:math';

import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/catalogs/bangumi_star_page.dart';
import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/fragments/toggle_theme_mode_button.dart';
import 'package:flutter/material.dart';
import 'package:bangu_lite/catalogs/bangumi_calendar_page.dart';
import 'package:bangu_lite/catalogs/bangumi_sort_page.dart';
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

    final indexModel = context.read<IndexModel>();
    
    return ValueListenableBuilder(
      valueListenable: selectedPageIndexNotifier,
      builder: (_,currentPageIndex,railLeading) {
        return Row(
          children: [

            NavigationRail(
              groupAlignment: -0.5,
              labelType: NavigationRailLabelType.all,
              selectedIndex: currentPageIndex,
              
              leading: railLeading!,
              trailing: Column(
                children: [

                  const Padding(
                    padding: EdgeInsets.only(top: 120), //magic number
                    child: ToggleThemeModeButton(),
                  ),

                  const Padding(padding: PaddingV12),

                  InkResponse(
                    onTap: () {
                      
                      indexModel.updateCachedSize();
                      Navigator.pushNamed(context,Routes.settings);
                    },
                    child: Icon(Icons.settings,size: min(30,MediaQuery.sizeOf(context).width/15)),
                  ),


                ],
              ),
            
              destinations: const [
                    
                NavigationRailDestination(
                  icon: Icon(Icons.local_fire_department_outlined),
                  selectedIcon: Icon(Icons.local_fire_department_rounded),
                  label: ScalableText('资讯')
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
              child: IndexedStack(
                index: currentPageIndex,
                children: const [
                  BangumiCalendarPage(),
                  BangumiSortPage(),
                  BangumiStarPage()
                ],
              ),
            )
            
          ],
        );
      },
      child: 

       Padding( 
        padding: const EdgeInsets.symmetric(vertical: 50),
        child: Column(
          children: [
            const Icon(Icons.live_tv_rounded),
            const ScalableText("BanguLite"),

            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: IconButton(
                onPressed: ()=> showSearch(
                  context: context,
                  delegate: CustomSearchDelegate()
                ),
                icon: const Icon(Icons.search)
              ),
            ),
              
          ],
        ),
      ),
      
      
    );
    
  }
}
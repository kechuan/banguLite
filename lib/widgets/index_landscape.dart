import 'package:flutter/material.dart';
import 'package:bangu_lite/catalogs/bangumi_calendar_page.dart';
import 'package:bangu_lite/catalogs/bangumi_sort_page.dart';
import 'package:bangu_lite/delegates/search_delegates.dart';

class IndexLandscape extends StatelessWidget {
  const IndexLandscape({
    super.key,
    required this.selectedPageIndexNotifier,
  });

  final ValueNotifier<int> selectedPageIndexNotifier;

  @override
  Widget build(BuildContext context) {
    
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

              //trailing: Padding(
              //  padding: const EdgeInsets.only(top: 300),
              //  child: IconButton(
              //    onPressed: ()=> showSearch(
              //      context: context,
              //      delegate: CustomSearchDelegate()
              //    ),
              //    icon: const Icon(Icons.search)),
              //),
              destinations: const [
        
                NavigationRailDestination(
                  icon: Icon(Icons.local_fire_department_outlined),
                  selectedIcon: Icon(Icons.local_fire_department_rounded),
                  label: Text('资讯')
                ),
        
                NavigationRailDestination(
                  icon: Icon(Icons.receipt_long_rounded),
                  selectedIcon: Icon(Icons.receipt_long),
                  label: Text('筛选')
                ),

              ],
              onDestinationSelected: (newIndex) => selectedPageIndexNotifier.value = newIndex,
            ),

            const VerticalDivider(width: 1),

            Expanded(
              child: IndexedStack(
                index: currentPageIndex,
                children: const [
                  BangumiCalendarPage(),
                  BangumiSortPage(),
                ],
              ),
            )
            
          ],
        );
      },
      child: 

       Padding(           
        padding: const EdgeInsets.only(top: 50),
        child: Column(
          children: [
            const Icon(Icons.live_tv_rounded),
            const Text("BanguLite"),

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
import 'dart:math';

import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/catalogs/bangumi_star_page.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:bangu_lite/widgets/fragments/cached_image_loader.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/fragments/toggle_theme_mode_button.dart';
import 'package:bangu_lite/widgets/fragments/unvisible_response.dart';
import 'package:flutter/material.dart';
import 'package:bangu_lite/catalogs/bangumi_calendar_page.dart';
import 'package:bangu_lite/catalogs/bangumi_sort_page.dart';
import 'package:bangu_lite/delegates/search_delegates.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
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
    final accountModel = context.read<AccountModel>();
    
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

                          UnVisibleResponse(
                            onTap: () {
                              //if(accountModel.loginedUserInformations.userInformation?.userID != null){
                              //  Navigator.pushNamed(context,Routes.userPage,arguments: accountModel.loginedUserInformations.userInformation?.userID);
                              //}

                              //else{
                              //  Navigator.pushNamed(context,Routes.login,arguments: accountModel.loginedUserInformations.userInformation?.userID);
                              //}
                            },
                            child: SizedBox(
                              height: 30,
                              width: 30,
                              child: Builder(
                                builder: (_){
                                  if(accountModel.loginedUserInformations.userInformation?.avatarUrl != null){
                                    return CachedImageLoader(imageUrl: accountModel.loginedUserInformations.userInformation?.avatarUrl);
                                  }
                                  else{
                                    return Icon(MdiIcons.accountCircleOutline,size: 30);
                                  }
                                } 
                              )
                            ),
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
          }
        );
      },
      child: Padding( 
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
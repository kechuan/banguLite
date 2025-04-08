import 'dart:async';

import 'package:bangu_lite/internal/bangumi_define/content_status_const.dart';
import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/internal/search_handler.dart';
import 'package:bangu_lite/models/bangumi_details.dart';
import 'package:bangu_lite/widgets/fragments/bangumi_tile.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CustomSearchDelegate extends SearchDelegate<String>{

  ValueNotifier<SubjectType> searchTypesNotifier = ValueNotifier(SubjectType.anime);

  @override
  ThemeData appBarTheme(BuildContext context) {
    return super.appBarTheme(context).copyWith(
      inputDecorationTheme: const InputDecorationTheme()
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      Row(
        spacing: 6,
        children: [

          ValueListenableBuilder(
            valueListenable: searchTypesNotifier,
             builder: (_,currentSortType,child) {

               return SizedBox(
                width: 60,
                 child: PopupMenuButton<SubjectType>(
                  tooltip: "搜索类别",
                  initialValue: currentSortType,
                  position:PopupMenuPosition.under,
                  itemBuilder: (_) {
                    return List.generate(
                      SubjectType.values.length, 
                      (index) => PopupMenuItem(
                        value: SubjectType.values[index],
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(SubjectType.values[index].iconData),
                            Text(SubjectType.values[index].subjectName)
                          ],),
                      ),
                    );
                  },
                                    
                  onSelected: (selectedValue)=> searchTypesNotifier.value = selectedValue,
                                    
                  child: SizedBox(
                    height: 50,
                    child: Row(
                      
                      children: [
                    
                        Expanded(
                          child: Padding(
                            padding: PaddingH6,
                            child: Icon(searchTypesNotifier.value.iconData),
                          ),
                        ),
                    
                        const Icon(Icons.arrow_drop_down)
                    
                      ],
                    ),
                  ),
                                    
                  ),
               );
             }
           ),



          IconButton(onPressed: ()=> query = "", icon: const Icon(Icons.close)),
        ],
      ),

    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: ()=> close(context, ''),
      icon: const Icon(Icons.arrow_back)
    );
  }

  @override
  PreferredSizeWidget buildBottom(BuildContext context) {
    return const PreferredSize(
      preferredSize: Size.fromHeight(0.0),
      child: Divider(height: 2)
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {

    if(query.isEmpty){
      return const Center(child: ScalableText("沉舟侧畔千帆过 病树前头万木春"));
    }

    return FutureBuilder(
      future: Future.delayed(const Duration(milliseconds: 400)).then((value){debugPrint("input done. searching");}),
      builder: (_,inputSnapshot){
        
        switch(inputSnapshot.connectionState){
          case ConnectionState.done:{

            debugPrint("suggestion get result done.");

            return FutureBuilder( //requsetAPI
              future: sortSearchHandler(
                keyword:query,
                subjectType: 
                  searchTypesNotifier.value == SubjectType.all ? 
                  SubjectTypeExtension.subjectTypes :
                  [searchTypesNotifier.value.subjectType]
                ,
                

              ).then((result){
                debugPrint("done: search query: $query, result: $result");
                return result;
              }),
              builder: (_,searchSnapshot){

                debugPrint("suggestion render done.");
              
                switch(searchSnapshot.connectionState){

                  case ConnectionState.done:{

                    if(!searchSnapshot.hasData) return const Center(child: ScalableText("暂无信息"));

                     List<BangumiDetails> searchData = loadSearchData(searchSnapshot.data!.data);

                      for(BangumiDetails currentBangumi in searchData){
                        currentBangumi.name = convertAmpsSymbol(currentBangumi.name);
                      }

                      return ListView.separated(
                        itemCount: searchData.length,
                        itemBuilder: (_, index) {
                          
                          //前端处理法convertAmpsSymbol(bangumiDetails.name);
                          searchData[index].name = convertAmpsSymbol(searchData[index].name);

                          return ListTile(
                            title: ScalableText(searchData[index].name!),
                            onTap: () {
                              query = '${searchData[index].name}';
                              showResults(context);
                            },
                          );


                        },
                        separatorBuilder: (_, index) => const Divider(height: 2),
                        
                      );

                  }

                  case ConnectionState.waiting: return const Center(child: CircularProgressIndicator());

                  default: return const Center(child: CircularProgressIndicator());
                }
                
              }
            );
          
          }

          case ConnectionState.waiting: return const Center(child: CircularProgressIndicator());

          default: return const Center(child: CircularProgressIndicator());
        }
        
      }
    );

  }

  @override
  Widget buildResults(BuildContext context) {

    debugPrint("search results build");

    return FutureBuilder( //requsetAPI
      future: sortSearchHandler(
        keyword:query,
        subjectType: 
          searchTypesNotifier.value == SubjectType.all ? 
          SubjectTypeExtension.subjectTypes :
          [searchTypesNotifier.value.subjectType]
        ,
      ),
      builder: (_,searchSnapshot){

        switch(searchSnapshot.connectionState){

          case ConnectionState.done:{

            if(searchSnapshot.hasData){

              List<BangumiDetails> searchData = loadSearchData(searchSnapshot.data!.data);

              ValueNotifier<bool> isLoading = ValueNotifier<bool>(true);

              debugPrint("search result data:$searchData");

              return EasyRefresh(
                child: ValueListenableBuilder(
                  valueListenable: isLoading,
                  builder: (_,isLoading,child) {

                    return Skeletonizer(
                      enabled: isLoading,
                      child: child!,
                    );
                  
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    
                    itemCount: searchData.length,
                    itemBuilder: (_, index) {

                      WidgetsBinding.instance.addPostFrameCallback((timestamp){
                        isLoading.value = false;
                      });

                      return BangumiListTile(
                        imageSize: const Size(100, 150),
                        bangumiDetails: searchData[index],
                        

                        onTap: () {
                          Navigator.popAndPushNamed(
                            context,
                            Routes.subjectDetail,
                            arguments: {"subjectID":searchData[index].id}
                          );
                          
                        },
                        
                      );
                    },

                    separatorBuilder: (_, __) => const Divider(height: 2)
                    
                    
                  ),
                    
                ),
              );
            }

            return const Center(child: ScalableText("暂无信息"));

          }

          case ConnectionState.waiting: return const Center(child: CircularProgressIndicator());

          default: return const Center(child: CircularProgressIndicator());
        }
        
      }
    );

  }

}
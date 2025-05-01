
import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/internal/bangumi_define/bangumi_social_hub.dart';
import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/custom_toaster.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:bangu_lite/widgets/fragments/app_user_avatar.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/fragments/toggle_theme_mode_button.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {

    final accountModel = context.read<AccountModel>();
    final indexModel = context.read<IndexModel>();
    ValueNotifier<bool> isExpandedNotifier = ValueNotifier(true);

    return Padding(
      padding: Padding12+PaddingV24,
      child: EasyRefresh(
        child: SingleChildScrollView(
          child: Column(
            spacing: 24,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          
              const ScalableText("账号区域",style: TextStyle(fontSize: 14,color: Colors.grey)),
          
              Selector<AccountModel,bool>(
                selector: (context,accountModel)=>accountModel.isLogined(),
                builder: (_,loginedStatus,child) {
                  return Column(
                    children: [
          
                      ListTile(
                        
                        onTap: () {
                          
                          invokePushLogin() => Navigator.pushNamed(context, Routes.loginAuth,arguments: {'key':const Key('loginAuth')});
                      
                          Future.wait(
                            [
                              precacheImage(
                                const AssetImage('assets/icons/icon.png'),
                                context
                              ),
                      
                              precacheImage(
                                const AssetImage('assets/icons/bangumi_logo.png'),
                                context
                              ),
                            ]
                          ).then(
                            (_)=>invokePushLogin()
                          );
                                          
                        },
                        title: Row(
                          spacing: 12,
                          children: [
                        
                            Builder(builder: (_){
                              if(!loginedStatus){
                                return const SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: Icon(Icons.account_circle_outlined,size: 35)
                                );
                              }
                        
                              else{
                                return const SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: AppUserAvatar()
                                );
                              }
                            }),
                                          
                        
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ScalableText(AccountModel.loginedUserInformations.userInformation?.nickName ?? "游客模式",maxLines: 3,overflow: TextOverflow.ellipsis),
                                  ScalableText(loginedStatus ? "@${AccountModel.loginedUserInformations.userInformation?.userID}" : "登录以解锁在线模式",style: const TextStyle(fontSize: 12,color: Colors.grey)),
                                ],
                              ),
                            ),
    
                            if(loginedStatus)
                              ElevatedButton(
                                onPressed: ()=> accountModel.resetLoginStatus(),
                                child: const Row(
                                  children: [
                                    Icon(Icons.logout),
                                    Text("登出"),
                                  ],
                                )
                              )
                            
                          ],
                        ),
                                          
                       
                      ),


                      if(loginedStatus)
                        ...List.generate(
                          BangumiPrivateHubType.values.length, 
                          (index) => ListTile(
                            leading: Icon(BangumiPrivateHubType.values[index].iconData),
                            title: Text(BangumiPrivateHubType.values[index].typeName),
                            onTap: ()=>fadeToaster(context: context, message: "暂未开放"),
                          )
                        )

                    ],
                  );
                }
              ),
          
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: const ScalableText("Bangumi 广场",style: TextStyle(fontSize: 14,color: Colors.grey)),
                initiallyExpanded: true,
                trailing: ValueListenableBuilder(
                  valueListenable: isExpandedNotifier,
                  builder: (_,isExpanded,child)=> isExpanded ? const Icon(Icons.keyboard_arrow_down_outlined) : const Icon(Icons.keyboard_arrow_right_outlined),
                ),
                onExpansionChanged: (value) => isExpandedNotifier.value = value,
                
                  children: List.generate(
                    BangumiSocialHubType.values.length, 
                    (index) => ListTile(
                      leading: Icon(BangumiSocialHubType.values[index].iconData),
                      title: Text(BangumiSocialHubType.values[index].typeName),
                      onTap: (){

                        switch(BangumiSocialHubType.values[index]){
                          case BangumiSocialHubType.group:{
                            Navigator.pushNamed(context, Routes.groups);
                          }
                          case BangumiSocialHubType.timeline:{
                            Navigator.pushNamed(context, Routes.timeline);
                          }

                          case BangumiSocialHubType.history:{
                            debugPrint("暂未开放");
                            //Navigator.pushNamed(context, Routes.timeline);
                          }
                          
                           
                        }
                        
                        
                      },
                    )
                  )
                  
                ),
          
              const ScalableText("杂项",style: TextStyle(fontSize: 14,color: Colors.grey)),
          
              Column(
                children: [
              
                  const ToggleThemeModeButton(isDetailText: true),
              
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text("设置"),
                    onTap: (){
                      indexModel.updateCachedSize();
                      Navigator.pushNamed(context,Routes.settings);
                    },
                  )
                
                ],
              )
          
            ],
          ),
        ),
      ),
    );
  }
}
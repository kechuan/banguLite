import 'dart:math';

import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/internal/bangumi_define/bangumi_social_hub.dart';
import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/widgets/fragments/app_user_avatar.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {

    final accountModel = context.read<AccountModel>();

    return Drawer(
      width: min(350, MediaQuery.sizeOf(context).width*3/4),
      child: Padding(
        padding: Padding12+PaddingV24,
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
                        
                        invokePushLogin() => Navigator.pushNamed(context, Routes.loginAuth);
                    
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
                                        
                      
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ScalableText(accountModel.loginedUserInformations.userInformation?.nickName ?? "游客模式"),
                              //ScalableText("登录以解锁在线模式",style: TextStyle(fontSize: 12,color: Colors.grey)),
                              ScalableText(loginedStatus ? "@${accountModel.loginedUserInformations.userInformation?.userID}" : "登录以解锁在线模式",style: TextStyle(fontSize: 12,color: Colors.grey)),
                            ],
                          ),
                                        
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

                    ...List.generate(
                      BangumiPrivateHubType.values.length, 
                      (index) => ListTile(
                        leading: Icon(BangumiPrivateHubType.values[index].iconData),
                        title: Text(BangumiPrivateHubType.values[index].typeName),
                        //onTap: ()=>Navigator.pushNamed(context, Routes.socialHub,arguments: BangumiPrivateHubType.values[_]),
                      )
                    )
                  
                  ],
                );
              }
            ),

            const Divider(),

            const ScalableText("Bangumi 广场",style: TextStyle(fontSize: 14,color: Colors.grey)),
            
            Expanded(
              child: ListView(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children: [
                  ...List.generate(
                      BangumiSocialHubType.values.length, 
                      (index) => ListTile(
                        leading: Icon(BangumiSocialHubType.values[index].iconData),
                        title: Text(BangumiSocialHubType.values[index].typeName),
                        //onTap: ()=>Navigator.pushNamed(context, Routes.socialHub,arguments: BangumiPrivateHubType.values[_]),
                      )
                    )
                ]
              )
            ),
        
            Divider(),
        
          ],
        ),
      ),
    );
  }
}
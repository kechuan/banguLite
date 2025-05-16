import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/internal/custom_bbcode_tag.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/widgets/fragments/cached_image_loader.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';


import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';
import 'package:provider/provider.dart';


@FFRoute(name: '/loginAuth')
class BangumiAuthPage extends StatelessWidget {
  const BangumiAuthPage({
    super.key
  });

  @override
  Widget build(BuildContext context) {

    final accountModel = context.read<AccountModel>();
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: (){
            accountModel.isLogining = null;
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back)
        ),
        title: const Text('登入到Bangumi'),
      ),
      body: SafeArea(
        child: Column(
          spacing: 32,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
        
            Padding(
              padding: Padding16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 24,
                children: [
                    
                  Flexible(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: 80,
                        maxWidth: 100,
                        //maxHeight: 120 
                      ),
                      child: Image.asset(
                        'assets/icons/icon.png',
                        //height: 120,
                        //width: 120,
                      ),
                    ),
                  ),
                    
                   Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                     [
                      Transform.translate(
                        offset: const Offset(12, 0),
                        child: const Icon(Icons.arrow_forward_ios)
                      ),
                       const Icon(Icons.arrow_forward_ios),
                        Transform.translate(
                        offset: const Offset(-12, 0),
                        child: const Icon(Icons.arrow_forward_ios)
                      ),
                    ],
                                   ),
                    
                  Flexible(
                    child: Image.asset(
                      'assets/icons/bangumi_logo.png',
                    ),
                  ),
                    
                    
                ],
              ),
            ),
        
            Padding(
              padding: Padding16,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: judgeCurrentThemeColor(context).withValues(alpha: 0.2)
                ),
                child: Padding(
                  padding: Padding16,
                  child: BBCodeText(
                    data: 
                      '[center]本软件支持 [color=F1A8D6]Bangumi[/color] 登录,登录后即可透过本软件管理你的 [color=F1A8D6]Bangumi[/color] 账号,用于执行发帖、回帖、点赞、收藏等操作。[/center]\n'
                      '[center]当然即使 [b]不登录[/b]，你依旧可以像浏览未登录情况下的 [color=F1A8D6]Bangumi[/color] 网站一样使用本软件。[/center]'
                      '[center][s]除非访问API的服务炸了。[/s][/center]'
                    ,
                    stylesheet: BBStylesheet(
                      tags: allEffectTag,
                      defaultText: TextStyle(
                        height:2,
                        fontFamilyFallback: convertSystemFontFamily(),
                        fontSize: 16,
                        color: judgeDarknessMode(context) ? Colors.white : Colors.black,
                      )
                    ),
                  ),
                ),
              ),
            ),
        
            Selector<AccountModel, ({bool? isLogining,bool loginedStatus})> (
              selector: (_, accountModel) => (isLogining: accountModel.isLogining, loginedStatus: accountModel.isLogined()),
              builder: (_, loginData, __) {
        
                Widget? leadingWidget;
                String resultText = '';
                Widget resultIcon = const SizedBox.shrink();
        
                switch(loginData.isLogining){
                  
                  case null:{
        
                    if(loginData.loginedStatus){
                      final accountModel = context.read<AccountModel>();
        
                      leadingWidget = Row(
                        spacing: 12,
                        children: [
        
                          const ScalableText('当前登录用户:'),
        
                          SizedBox(
                            height: 25,
                            width: 25,
                            child: CachedImageLoader(
                              imageUrl: AccountModel.loginedUserInformations.userInformation?.avatarUrl
                            ),
                          ),
        
                          ScalableText('${AccountModel.loginedUserInformations.userInformation?.nickName}'),
        
                          ElevatedButton(
                            onPressed: ()=> accountModel.logout(),
                            child: const Row(
                              children: [
                                Icon(Icons.logout),
                                Text("登出"),
                              ],
                            )
                          )
        
                        ],
                      );
        
        
                    }
                    
                    resultIcon = const SizedBox.shrink();
                  }
                    
                    
                  case true:{
                    resultText = '正在等待外部浏览器验证';
                    resultIcon = const SizedBox(
                      height: 25,
                      width: 25,
                      child: CircularProgressIndicator()
                    );
                  }
                    
                    
                  case false:{
                    if(loginData.loginedStatus){
                      final accountModel = context.read<AccountModel>();
        
                      leadingWidget = Row(
                        spacing: 12,
                        children: [
        
                          SizedBox(
                            height: 25,
                            width: 25,
                            child: CachedImageLoader(
                              imageUrl: AccountModel.loginedUserInformations.userInformation?.avatarUrl
                            ),
                          ),
        
                          ScalableText('${AccountModel.loginedUserInformations.userInformation?.nickName} 已验证成功'),
        
                          ElevatedButton(
                            onPressed: ()=> accountModel.logout(),
                            child: const Row(
                              children: [
                                Icon(Icons.logout),
                                Text("登出"),
                              ],
                            )
                          )
        
        
                        ],
                      );
        
                      
                      
                    }
        
                    else{
                      resultText = '验证会话已过期 请再次重试';
                      resultIcon = const Icon(Icons.refresh);
                    }
                  }
                }
        
                return Row(
                  spacing: 12,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
        
                    leadingWidget ?? const SizedBox.shrink(),
        
                    ScalableText(resultText),
                                
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: resultIcon
                    )
                  ],
                );
                
              }
              
            ),
        
        
            Selector<AccountModel, ({bool? isLogining,bool loginedStatus})> (
              selector: (_, accountModel) => (isLogining: accountModel.isLogining, loginedStatus: accountModel.isLogined()),
              builder: (_, loginData, __) {
        
                final resultColor = loginData.isLogining == true ? Colors.grey : const Color.fromARGB(255, 238, 201, 226);
        
                String resultText = loginData.loginedStatus ? "返回主页" : "登入";
        
                return Container(
                  width: MediaQuery.sizeOf(context).width*2/3,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    
                  ),
                  child: ElevatedButton(
                    style:  ButtonStyle(
                      elevation: const WidgetStatePropertyAll(0),
                      padding: const WidgetStatePropertyAll(EdgeInsets.zero),
                      backgroundColor:  WidgetStatePropertyAll(resultColor),
                    ),
                    onPressed: (){
        
                      if(loginData.loginedStatus){
                        Navigator.popAndPushNamed(context,Routes.index);
                      }
        
                      else{
                        accountModel.login();
                      }
        
        
                    },
                    child: ScalableText(resultText)
                  ),
                );
              }
            ),
        
            const ScalableText("*登录操作将会在外部打开浏览器操作完成",style: TextStyle(color: Colors.grey),),
        
        
          ],
        ),
      ),
    );
    
  }
}
import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/widgets/fragments/cached_image_loader.dart';
import 'package:bangu_lite/widgets/fragments/unvisible_response.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class AppUserAvatar extends StatelessWidget {
  const AppUserAvatar({
    super.key,
    this.onTap,
  });

  final Function()? onTap;

  @override
  Widget build(BuildContext context) {

    return UnVisibleResponse(
        onTap: onTap ?? () {
      
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
        child: Selector<AccountModel,LoginStatus>(
          selector: (_, accountModel) => accountModel.accountLoginStatus,
          shouldRebuild: (pre,next)=> true,
          builder: (_,__,child){
            if(AccountModel.loginedUserInformations.userInformation?.avatarUrl != null){
              return CachedImageLoader(imageUrl: AccountModel.loginedUserInformations.userInformation?.avatarUrl);
            }
            else{
              return Icon(MdiIcons.accountCircleOutline,size: 30);
            }
          } 
        ),
      );
  }
}
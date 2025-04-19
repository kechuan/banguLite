import 'package:bangu_lite/bangu_lite_routes.dart';
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
    final accountModel = context.read<AccountModel>(); 

    return UnVisibleResponse(
        onTap: onTap ?? () {
      
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
        child: Selector<AccountModel,bool>(
          selector: (_, accountModel) => accountModel.isLogined(),
          builder: (_,isLogined,child){
            if(accountModel.loginedUserInformations.userInformation?.avatarUrl != null){
              return CachedImageLoader(imageUrl: accountModel.loginedUserInformations.userInformation?.avatarUrl);
            }
            else{
              return Icon(MdiIcons.accountCircleOutline,size: 30);
            }
          } 
        ),
      );
  }
}
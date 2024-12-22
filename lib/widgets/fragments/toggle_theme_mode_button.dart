import 'dart:math';

import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ToggleThemeModeButton extends StatelessWidget {
  const ToggleThemeModeButton({
    super.key,
    this.onThen
  });

  final void Function()? onThen;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: (){

        final indexModel = context.read<IndexModel>();

        if(indexModel.themeMode == ThemeMode.dark || Theme.of(context).brightness == Brightness.dark){
          indexModel.updateThemeMode(ThemeMode.light);
        }
        else{
          indexModel.updateThemeMode(ThemeMode.dark);
        }

        if(onThen != null) onThen!();
          
      },
      child: Selector<IndexModel,ThemeMode>(
        selector: (_, indexModel) => indexModel.themeMode,
        shouldRebuild: (previous, next) => previous!=next,
        builder: (_, currentTheme, child){
          return Icon(
            //currentTheme == ThemeMode.dark ? 
            Theme.of(context).brightness == Brightness.dark ? 
            Icons.dark_mode_outlined :
            Icons.wb_sunny_outlined
            ,size: min(30,MediaQuery.sizeOf(context).width/15));
        },
      ),
    );
  }
}
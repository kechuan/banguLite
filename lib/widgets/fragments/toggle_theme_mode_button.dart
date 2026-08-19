import 'dart:math';

import 'package:bangu_lite/internal/utils/judge.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ToggleThemeModeButton extends StatelessWidget {
  const ToggleThemeModeButton({
    super.key,
    this.isDescriptionDisplay = false,
    this.onThen
  });

  final void Function()? onThen;
  final bool isDescriptionDisplay;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      containedInkWell: true,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {

        final indexModel = context.read<IndexModel>();

        if (indexModel.userConfig.themeMode == ThemeMode.dark || judgeDarknessMode(context)) {
          indexModel.updateThemeMode(ThemeMode.light);
        }
        else {
          indexModel.updateThemeMode(ThemeMode.dark);
        }

        onThen?.call();

      },
      child: Selector<IndexModel, ThemeMode>(
        selector: (_, indexModel) => indexModel.userConfig.themeMode!,

        builder: (_, currentTheme, child) {

          if (isDescriptionDisplay == true) {
            return ListTile(
              leading: Icon(
                judgeDarknessMode(context) ? 
                Icons.dark_mode_outlined :
                Icons.wb_sunny_outlined,
                size: min(30, MediaQuery.sizeOf(context).width / 15)
              ),
              title: const Text("切换主题模式"),
            );
          }

          else {
            return Icon(
              judgeDarknessMode(context) ? 
              Icons.dark_mode_outlined :
              Icons.wb_sunny_outlined,
              size: min(30, MediaQuery.sizeOf(context).width / 15)
            );
          }

        },
      ),
    );
  }
}

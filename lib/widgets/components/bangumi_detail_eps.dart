import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/widgets/components/ep_select.dart';
import 'package:flutter/widgets.dart';

class BuildEps extends StatelessWidget {
  const BuildEps({
    super.key,
    required this.subjectID,
    required this.informationList,
	  this.portialMode,
    this.outerContext
  });

  final int subjectID;
  final Map<String, dynamic> informationList;
  final bool? portialMode;
  final BuildContext? outerContext;

  @override
  Widget build(BuildContext context) {

    int totalEps = informationList["eps"] ?? 0;
    int airedEps = convertAiredEps(informationList["air_date"]);

    return totalEps == 0 ? 
      const SizedBox.shrink() :
      EpSelect(
        totalEps: totalEps,
        airedEps: airedEps,
        name: informationList["alias"],
        portialMode: portialMode,
        //outerContext: outerContext,
      );
  }
}

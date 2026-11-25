import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/dialogs/warp_season_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bangu_lite/internal/max_number_input_formatter.dart';

class DateRangeSelect extends StatelessWidget {
  const DateRangeSelect({
    super.key,
    required this.dateRangeEditingController,
    this.initMonth,
    this.onMonthChanged,
  });

  final TextEditingController dateRangeEditingController;
  final int? initMonth;
  final ValueChanged<int?>? onMonthChanged;

  @override
  Widget build(BuildContext context) {

    return Row(
      children: [
        
        SizedBox(
          width: 50,
          child: TextField(

            controller: dateRangeEditingController,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              border: InputBorder.none
            ),

            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              MaxValueFormatter(DateTime.now().year)
            ],
            
          ),
        ),

        ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: 24,
            maxWidth: 24,
          ),
          child: PopupMenuButton(
            
            padding: const EdgeInsets.all(0),
            initialValue: DateTime.now().year,
            icon: const Icon(Icons.arrow_drop_down),
            onSelected: (value) => dateRangeEditingController.text = value.toString(),
            constraints: const BoxConstraints(maxHeight: 200),

            itemBuilder: (_){
              final currentYear = DateTime.now().year;
              final yearCount = (currentYear - bangumiBaseYear + 1).clamp(1, 100);
              return List.generate(
                yearCount, (index){
                  return PopupMenuItem(
                      height: 50,
                      value: currentYear - index,
                      child: ScalableText("${currentYear - index}"),
                    );
                }
              );
            }
          ),
        ),

        const ScalableText("年"),

        SizedBox(
          width: 50,
          child: DropdownButtonFormField(
            isExpanded: true,
            isDense: true,
            menuMaxHeight: (kMinInteractiveDimension*3),
            initialValue: initMonth,
            items: [
              ...List.generate(
                12, (index){
                  return DropdownMenuItem(
                    value: index+1,
                    child: Align(
                      alignment: const Alignment(0.5,0),
                      child: ScalableText("${index+1}")
                    ),
                  );
                }
              )
            ], 
            onChanged: onMonthChanged,
          ),
        ),

        const ScalableText("月"),
      ],
    );
    
  }
}
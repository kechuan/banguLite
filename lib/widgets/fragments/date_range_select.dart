import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bangu_lite/internal/event_bus.dart';
import 'package:bangu_lite/internal/max_number_input_formatter.dart';

class DateRangeSelect extends StatelessWidget {
  const DateRangeSelect({
    super.key,
    required this.dateRangeEditingController,
  });

  final TextEditingController dateRangeEditingController;

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
                    
            itemBuilder: (_){
              return [
                ...List.generate(
                  12, (index){
          
                    if( index % 2 == 1) return const PopupMenuDivider();
          
                    return PopupMenuItem(
                      
                      value: DateTime.now().year - (index~/2),
                      child: ScalableText("${ DateTime.now().year - (index~/2) }"),
                    );
                  }
                )
              ];
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
            onChanged: (item) => bus.emit(key,item),
          ),
        ),

        const ScalableText("月"),
      ],
    );
    
  }
}
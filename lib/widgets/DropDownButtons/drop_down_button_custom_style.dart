import 'package:flutter/material.dart';

import '../DropDownButtonMenuItems/tag_drop_down_button_menu_item.dart';

// ignore: must_be_immutable
class DropDownButtonCustomStyle extends StatefulWidget {
  DropDownButtonCustomStyle({
    Key? key,
    required this.selectedValue,
    required this.tableRows,
    required this.columnNameIdValue,
    required this.columnNameTextValue,
    required this.onValueSelectedFunction,
  }) : super(key: key);
  int? selectedValue;
  final List<Map<String, dynamic>> tableRows;
  final String columnNameIdValue;
  final String columnNameTextValue;
  final Function onValueSelectedFunction;

  @override
  State<DropDownButtonCustomStyle> createState() =>
      _DropDownButtonCustomStyleState();
}

class _DropDownButtonCustomStyleState extends State<DropDownButtonCustomStyle> {
  List<DropdownMenuItem<dynamic>> itemListAsDropdownMenuItems = [];

  @override
  void initState() {
    super.initState();
    for (var tableRow in widget.tableRows) {
      final String _text = tableRow[widget.columnNameTextValue];
      final int _value = tableRow[widget.columnNameIdValue];
      itemListAsDropdownMenuItems.add(
        DropdownMenuItem(
          value: _value,
          child: DropDownButtonMenuItemChild(text: _text),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<dynamic>(
      value: widget.selectedValue,
      items: itemListAsDropdownMenuItems,
      onChanged: (selectedValue) {
        setState(() {
          widget.selectedValue = selectedValue;
          widget.onValueSelectedFunction(selectedValue);
        });
      },
    );
  }
}

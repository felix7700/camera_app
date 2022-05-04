import 'package:flutter/material.dart';

import '../DropDownButtonMenuItems/tag_drop_down_button_menu_item.dart';
import '../../db_manager.dart';

class AlertDialogSelectTag extends StatefulWidget {
  const AlertDialogSelectTag(
      {Key? key, required this.tagsData, required this.onTagSelectedFunction})
      : super(key: key);
  final List<Map<String, dynamic>> tagsData;
  final Function onTagSelectedFunction;

  @override
  State<AlertDialogSelectTag> createState() => _AlertDialogSelectTagState();
}

class _AlertDialogSelectTagState extends State<AlertDialogSelectTag> {
  List<DropdownMenuItem<dynamic>> tagsListAsDropdownMenuItems = [];
  final DbManager _dbManager = DbManager.instance;
  int _selectedTagId = 1;

  @override
  void initState() {
    super.initState();
    for (var tagData in widget.tagsData) {
      final int _value = tagData[_dbManager.tagsColumnnameTagID];
      final String _text = tagData[_dbManager.tagsColumnnameTagName];
      tagsListAsDropdownMenuItems.add(
        DropdownMenuItem(
          value: _value,
          child: DropDownButtonMenuItemChild(text: _text),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nach Tag filtern'),
      content: SingleChildScrollView(
        child: DropdownButton<dynamic>(
          value: _selectedTagId,
          items: tagsListAsDropdownMenuItems,
          onChanged: (selectedTagId) {
            setState(() {
              _selectedTagId = selectedTagId;
            });
          },
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Abbrechen'),
          onPressed: () {
            debugPrint('Tagauswahl abgebrochen');
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Ok'),
          onPressed: () {
            widget.onTagSelectedFunction(selectedTagId: _selectedTagId);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

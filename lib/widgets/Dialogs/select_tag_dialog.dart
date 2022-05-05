import 'package:camera_app/widgets/DropDownButtons/drop_down_button_custom_style.dart';
import 'package:flutter/material.dart';

import '../../db_manager.dart';

class SelectTagDialog extends StatefulWidget {
  SelectTagDialog(
      {Key? key, required this.tagsData, required this.onTagSelectedFunction})
      : super(key: key);
  final List<Map<String, dynamic>> tagsData;
  final Function onTagSelectedFunction;
  int selectedTagId = 1;

  @override
  State<SelectTagDialog> createState() => _SelectTagDialogState();
}

class _SelectTagDialogState extends State<SelectTagDialog> {
  List<DropdownMenuItem<dynamic>> tagsListAsDropdownMenuItems = [];
  final DbManager _dbManager = DbManager.instance;

  void setSelectedTagId(int selectedTagId) {
    widget.selectedTagId = selectedTagId;
    debugPrint('setSelectedTagId()  ' + selectedTagId.toString());
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
        'build AlertDialog  DropDownButtonCustomStyle  widget.selectedTagId: ' +
            widget.selectedTagId.toString());
    return AlertDialog(
      title: const Text('Nach Tag filtern'),
      content: SingleChildScrollView(
        child: Row(
          children: [
            const Text('Tag:'),
            DropDownButtonCustomStyle(
              columnNameIdValue: _dbManager.tagsColumnnameTagID,
              columnNameTextValue: _dbManager.tagsColumnnameTagName,
              selectedValue: widget.selectedTagId,
              tableRows: widget.tagsData,
              onValueSelectedFunction: setSelectedTagId,
            ),
          ],
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
            widget.onTagSelectedFunction(selectedTagId: widget.selectedTagId);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

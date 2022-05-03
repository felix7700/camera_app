import 'package:flutter/material.dart';

import '../db_manager.dart';

class AddNewTagCard extends StatelessWidget {
  AddNewTagCard({Key? key, required this.addNewTagFunction}) : super(key: key);
  final Function addNewTagFunction;
  final categoryNameTextEditingController = TextEditingController();
  final _formKeyCategoryNameInput = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Container(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Form(
                key: _formKeyCategoryNameInput,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      autofocus: true,
                      decoration: const InputDecoration(labelText: 'Hashtag'),
                      controller: categoryNameTextEditingController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Bitte einen Hashtag eingeben!';
                        }
                        if (value.length > 20) {
                          return 'Maximal 20 Zeichen!';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              TextButton(
                child: const Text(
                  'Tag hinzufügen',
                  style: TextStyle(color: Colors.purple),
                ),
                onPressed: () {
                  if (_formKeyCategoryNameInput.currentState!.validate()) {
                    debugPrint('submitData()');
                    DbManager dbManager = DbManager.instance;
                    Map<String, dynamic> newTagRow = {
                      dbManager.tagsColumnnameTagName:
                          categoryNameTextEditingController.text
                    };
                    addNewTagFunction(newTagRow: newTagRow);
                    Navigator.of(context).pop();
                  }
                  if (_formKeyCategoryNameInput.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tag wurde hinzugefügt'),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

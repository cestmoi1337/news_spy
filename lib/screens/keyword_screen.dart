import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import '../providers/keyword_provider.dart';

class KeywordScreen extends StatefulWidget {
  @override
  _KeywordScreenState createState() => _KeywordScreenState();
}

class _KeywordScreenState extends State<KeywordScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _keywordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final keywordProvider = Provider.of<KeywordProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Keywords'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            FormBuilder(
              key: _formKey,
              child: Column(
                children: [
                  FormBuilderTextField(
                    name: 'keyword',
                    controller: _keywordController,
                    decoration: InputDecoration(
                      labelText: 'Keyword',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a keyword';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        keywordProvider.addKeyword(_keywordController.text);
                        _keywordController.clear();
                      }
                    },
                    child: Text('Add Keyword'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: keywordProvider.keywords.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(keywordProvider.keywords[index].keyword),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _editKeywordDialog(context, index, keywordProvider);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            keywordProvider.removeKeyword(index);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editKeywordDialog(
      BuildContext context, int index, KeywordProvider keywordProvider) {
    final _editKeywordController = TextEditingController(
      text: keywordProvider.keywords[index].keyword,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Keyword'),
          content: FormBuilder(
            child: FormBuilderTextField(
              name: 'editKeyword',
              controller: _editKeywordController,
              decoration: InputDecoration(
                labelText: 'Keyword',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a keyword';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_editKeywordController.text.isNotEmpty) {
                  keywordProvider.updateKeyword(
                      index, _editKeywordController.text);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }
}

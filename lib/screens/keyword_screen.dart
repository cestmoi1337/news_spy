import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import '../providers/keyword_provider.dart';

class KeywordScreen extends StatefulWidget {
  @override
  _KeywordScreenState createState() => _KeywordScreenState();
}

class _KeywordScreenState extends State<KeywordScreen> {
  final _formKey =
      GlobalKey<FormBuilderState>(); // Global key to manage the form
  final _keywordController =
      TextEditingController(); // Controller to manage text input for adding keywords

  @override
  Widget build(BuildContext context) {
    final keywordProvider =
        Provider.of<KeywordProvider>(context); // Access the KeywordProvider

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Keywords'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            FormBuilder(
              key: _formKey, // Key to manage the form state
              child: Column(
                children: [
                  FormBuilderTextField(
                    name: 'keyword',
                    controller:
                        _keywordController, // Controller for the keyword input field
                    decoration: InputDecoration(
                      labelText: 'Keyword', // Input label
                      border:
                          OutlineInputBorder(), // Adds a border to the input field
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a keyword'; // Validator for empty input
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        keywordProvider
                            .addKeyword(_keywordController.text); // Add keyword
                        _keywordController
                            .clear(); // Clear the input field after adding
                      }
                    },
                    child: Text('Add Keyword'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Expanded(
              // Expanded widget allows the list to take up remaining space
              child: ListView.builder(
                itemCount:
                    keywordProvider.keywords.length, // Number of keywords
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(keywordProvider
                        .keywords[index].keyword), // Display keyword
                    trailing: Row(
                      mainAxisSize: MainAxisSize
                          .min, // Minimize row size to fit buttons only
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit), // Edit icon button
                          onPressed: () {
                            _editKeywordDialog(context, index,
                                keywordProvider); // Open edit dialog
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete), // Delete icon button
                          onPressed: () {
                            keywordProvider
                                .removeKeyword(index); // Remove keyword
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

  // Function to display a dialog for editing the keyword
  void _editKeywordDialog(
      BuildContext context, int index, KeywordProvider keywordProvider) {
    final _editKeywordController = TextEditingController(
      text: keywordProvider.keywords[index]
          .keyword, // Pre-fill the text field with the current keyword
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Keyword'), // Title of the dialog
          content: FormBuilder(
            child: FormBuilderTextField(
              name: 'editKeyword',
              controller:
                  _editKeywordController, // Controller for the edit field
              decoration: InputDecoration(
                labelText: 'Keyword', // Input label
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a keyword'; // Validator for empty input
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog without saving
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_editKeywordController.text.isNotEmpty) {
                  keywordProvider.updateKeyword(
                      index, _editKeywordController.text); // Update the keyword
                  Navigator.of(context).pop(); // Close the dialog after saving
                }
              },
              child: Text('Save'), // Button to save changes
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _keywordController
        .dispose(); // Dispose the controller when the widget is removed
    super.dispose();
  }
}
